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
typealias BSPressureSubject = PassthroughSubject<BSPressureDataTuple, Never>
public typealias BSPressurePublisher = AnyPublisher<BSPressureDataTuple, Never>

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
    }

    // MARK: - pressureData

    private let pressureDataSubject = PassthroughSubject<BSPressureDataTuple, Never>()
    var pressureDataPublisher: AnyPublisher<BSPressureDataTuple, Never> {
        pressureDataSubject.eraseToAnyPublisher()
    }

    func parsePressureData(_ data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let pressureData = BSPressureData.parse(data, scalar: scalar, positions: pressurePositions, ranges: &pressureSensorRanges, centerOfPressureRange: &centerOfPressureRange) else {
            logger?.error("failed to parse pressure data")
            return
        }
        logger?.debug("pressureData: \(String(describing: pressureData)) (\(timestamp)ms")
        pressureDataSubject.send((pressureData, timestamp))
    }

    // MARK: - ranges

    var pressureSensorRanges: [BSRange] = .init()
    var centerOfPressureRange: BSCenterOfPressureRange = .init()

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
