//
//  BSBarometerSensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Combine
import Foundation
import OSLog
import UkatonMacros

public typealias BSBarometerData = (barometer: BSBarometer, timestamp: BSTimestamp)
typealias BSBarometerSubject = PassthroughSubject<BSBarometerData, Never>
public typealias BSBarometerPublisher = AnyPublisher<BSBarometerData, Never>

@StaticLogger(disabled: true)
final class BSBarometerSensorDataManager: BSBaseSensorDataManager {
    override class var sensorTypes: Set<BSSensorType> { [.barometer] }

    override func parseSensorData(sensorType: BSSensorType, data: Data, timestamp: BSTimestamp, scalar: Float) {
        super.parseSensorData(sensorType: sensorType, data: data, timestamp: timestamp, scalar: scalar)
        switch sensorType {
        case .barometer:
            parseBarometer(data, timestamp: timestamp, scalar: scalar)
        default:
            break
        }
    }

    // MARK: - barometer

    private let barometerSubject: BSBarometerSubject = .init()
    var barometerPublisher: BSBarometerPublisher {
        barometerSubject.eraseToAnyPublisher()
    }

    private func parseBarometer(_ data: Data, timestamp: BSTimestamp, scalar: Float) {
        guard let barometer: BSBarometer = .parse(data, scalar: scalar) else { return }
        logger?.debug("barometer: \(barometer) \(timestamp)ms")
        barometerSubject.send((barometer, timestamp))
    }
}
