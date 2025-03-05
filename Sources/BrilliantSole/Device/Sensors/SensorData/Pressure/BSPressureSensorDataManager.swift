//
//  BSPressureSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Combine
import Foundation
import OSLog
import UkatonMacros

public typealias BSPressureDataTuple = (pressure: BSPressureData, timestamp: BSTimestamp)
typealias BSPressureDataSubject = PassthroughSubject<BSPressureDataTuple, Never>
public typealias BSPressureDataPublisher = AnyPublisher<BSPressureDataTuple, Never>

@StaticLogger(disabled: true)
final class BSPressureSensorDataManager: BSBaseSensorDataManager {
    override class var sensorTypes: Set<BSSensorType> { [.pressure] }

    override func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        super.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        switch sensorType {
        case .pressure:
            parsePressureData(data, timestamp: timestamp, scalar: scalar)
        default:
            break
        }
    }

    override func reset() {
        super.reset()
        centerOfPressureRange.reset()
        for index in pressureSensorRanges.indices {
            pressureSensorRanges[index].reset()
        }
        normalizedSumRange.reset()
    }

    // MARK: - pressureData

    private let pressureDataSubject = BSPressureDataSubject()
    var pressureDataPublisher: BSPressureDataPublisher {
        pressureDataSubject.eraseToAnyPublisher()
    }

    private let centerOfPressureSubject = BSCenterOfPressureSubject()
    var centerOfPressurePublisher: BSCenterOfPressurePublisher {
        centerOfPressureSubject.eraseToAnyPublisher()
    }

    func parsePressureData(_ data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let pressureData = BSPressureData.parse(data, scalar: scalar, positions: pressurePositions, ranges: &pressureSensorRanges, centerOfPressureRange: &centerOfPressureRange, normalizedSumRange: &normalizedSumRange) else {
            logger?.error("failed to parse pressure data")
            return
        }
        logger?.debug("pressureData: \(String(describing: pressureData)) (\(timestamp)ms")
        pressureDataSubject.send((pressureData, timestamp))

        if let centerOfPressure = pressureData.centerOfPressure, let normalizedCenterOfPressure = pressureData.normalizedCenterOfPressure {
            centerOfPressureSubject.send((centerOfPressure, normalizedCenterOfPressure, timestamp))
        }
    }

    // MARK: - ranges

    var pressureSensorRanges: [BSRange] = .init()
    var centerOfPressureRange: BSCenterOfPressureRange = .init()
    var normalizedSumRange: BSRange = .init()

    // MARK: - pressurePositions

    private let pressurePositionsSubject = CurrentValueSubject<[BSPressureSensorPosition], Never>([])
    var pressurePositionsPublisher: AnyPublisher<[BSPressureSensorPosition], Never> {
        pressurePositionsSubject.eraseToAnyPublisher()
    }

    var pressurePositions: [BSPressureSensorPosition] {
        get { pressurePositionsSubject.value }
        set {
            logger?.debug("updated pressurePositions to \(newValue)")
            pressurePositionsSubject.value = newValue

            pressureSensorRanges = .init(repeating: .init(), count: pressurePositions.count)
            centerOfPressureRange.reset()
        }
    }

    var numberOfPressureSensors: Int { pressurePositions.count }
    static let pressurePositionScalar: Double = pow(2, -8)
    func parsePressurePositions(_ data: Data) {
        var newPressurePositions: [BSPressureSensorPosition] = []
        for index in stride(from: 0, to: data.count, by: 2) {
            let x = Double(data[data.startIndex + index])
            let y = Double(data[data.startIndex + index + 1])

            let pressurePosition: BSPressureSensorPosition = .init(x: x, y: y) * Self.pressurePositionScalar
            logger?.debug("pressurePosition \(newPressurePositions.count): \(pressurePosition)")
            newPressurePositions.append(pressurePosition)
        }
        logger?.debug("parsed pressurePositions: \(newPressurePositions)")
        pressurePositions = newPressurePositions
    }
}
