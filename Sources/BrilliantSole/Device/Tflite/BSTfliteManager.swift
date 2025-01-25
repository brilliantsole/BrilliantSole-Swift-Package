//
//  BSTfliteManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSTfliteManager: BSBaseManager<BSTfliteMessageType> {
    override class var requiredMessageTypes: [BSTfliteMessageType]? {
        [
            .getTfliteName,
            .getTfliteTask,
            .getTfliteSensorRate,
            .getTfliteSensorTypes,
            .isTfliteReady,
            .getTfliteCaptureDelay,
            .getTfliteThreshold,
            .getTfliteInferencingEnabled,
        ]
    }

    override func onRxMessage(_ messageType: BSTfliteMessageType, data: Data) {
        switch messageType {
        case .getTfliteName, .setTfliteName:
            parseTfliteName(data)
        case .getTfliteTask, .setTfliteTask:
            parseTfliteTask(data)
        case .getTfliteSensorRate, .setTfliteSensorRate:
            parseTfliteSensorRate(data)
        case .getTfliteSensorTypes, .setTfliteSensorTypes:
            parseTfliteSensorTypes(data)
        case .isTfliteReady:
            print("FILL")
        case .getTfliteCaptureDelay, .setTfliteCaptureDelay:
            print("FILL")
        case .getTfliteThreshold, .setTfliteThreshold:
            print("FILL")
        case .getTfliteInferencingEnabled, .setTfliteInferencingEnabled:
            print("FILL")
        case .tfliteInference:
            print("FILL")
        }
    }

    // MARK: - tfliteName

    let tfliteNameSubject: CurrentValueSubject<String, Never> = .init("")
    var tfliteName: String {
        get { tfliteNameSubject.value }
        set {
            tfliteNameSubject.value = newValue
            logger.debug("updated tfliteName to \(newValue)")
        }
    }

    func parseTfliteName(_ data: Data) {
        let newTfliteName: String = .parse(data)
        logger.debug("parsed tfliteName \(newTfliteName)")
        tfliteName = newTfliteName
    }

    func setTfliteName(_ newTfliteName: String, sendImmediately: Bool = true) {
        guard newTfliteName != tfliteName else {
            logger.debug("redundant tfliteName assignment \(newTfliteName)")
            return
        }
        logger.debug("setting tfliteName \(newTfliteName)")
        createAndSendMessage(.setTfliteName, data: newTfliteName.data, sendImmediately: sendImmediately)
    }

    // MARK: - tfliteTask

    let tfliteTaskSubject: CurrentValueSubject<BSTfliteTask, Never> = .init(.classification)
    var tfliteTask: BSTfliteTask {
        get { tfliteTaskSubject.value }
        set {
            tfliteTaskSubject.value = newValue
            logger.debug("updated tfliteTask to \(newValue.name)")
        }
    }

    func parseTfliteTask(_ data: Data) {
        guard let newTfliteTask = BSTfliteTask.parse(data) else {
            return
        }
        logger.debug("parsed tfliteTask \(newTfliteTask.name)")
        tfliteTask = newTfliteTask
    }

    func setTfliteTask(_ newTfliteTask: BSTfliteTask, sendImmediately: Bool = true) {
        guard newTfliteTask != tfliteTask else {
            logger.debug("redundant tfliteTask assignment \(newTfliteTask.name)")
            return
        }
        logger.debug("setting tfliteTask \(newTfliteTask.name)")
        createAndSendMessage(.setTfliteTask, data: newTfliteTask.data, sendImmediately: sendImmediately)
    }

    // MARK: - tfliteSensorRate

    let tfliteSensorRateSubject: CurrentValueSubject<BSSensorRate, Never> = .init(._0ms)
    var tfliteSensorRate: BSSensorRate {
        get { tfliteSensorRateSubject.value }
        set {
            tfliteSensorRateSubject.value = newValue
            logger.debug("updated tfliteSensorRate to \(newValue.name)")
        }
    }

    func parseTfliteSensorRate(_ data: Data) {
        guard let newTfliteSensorRate = BSSensorRate.parse(data) else {
            return
        }
        logger.debug("parsed tfliteSensorRate \(newTfliteSensorRate.name)")
        tfliteSensorRate = newTfliteSensorRate
    }

    func setTfliteSensorRate(_ newTfliteSensorRate: BSSensorRate, sendImmediately: Bool = true) {
        guard newTfliteSensorRate != tfliteSensorRate else {
            logger.debug("redundant tfliteSensorRate assignment \(newTfliteSensorRate.name)")
            return
        }
        logger.debug("setting tfliteSensorRate \(newTfliteSensorRate.name)")
        createAndSendMessage(.setTfliteSensorRate, data: newTfliteSensorRate.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - tfliteSensorTypes

    let tfliteSensorTypesSubject: CurrentValueSubject<BSTfliteSensorTypes, Never> = .init(.init())
    var tfliteSensorTypes: BSTfliteSensorTypes {
        get { tfliteSensorTypesSubject.value }
        set {
            tfliteSensorTypesSubject.value = newValue
            logger.debug("updated tfliteSensorTypes to \(newValue)")
        }
    }

    func parseTfliteSensorTypes(_ data: Data) {
        guard let newTfliteSensorTypes = BSTfliteSensorTypes.parse(data) else {
            return
        }
        logger.debug("parsed tfliteSensorTypes \(newTfliteSensorTypes)")
        tfliteSensorTypes = newTfliteSensorTypes
    }

    func setTfliteSensorTypes(_ newTfliteSensorTypes: BSTfliteSensorTypes, sendImmediately: Bool = true) {
        guard newTfliteSensorTypes != tfliteSensorTypes else {
            logger.debug("redundant tfliteSensorTypes assignment \(newTfliteSensorTypes)")
            return
        }
        createAndSendMessage(.setTfliteSensorTypes, data: newTfliteSensorTypes.data, sendImmediately: sendImmediately)
    }

    // MARK: - isTfliteReady

    // MARK: - tfliteCaptureDelay

    // MARK: - tfliteThreshold

    // MARK: - tfliteInferencingEnabled

    // MARK: - tfliteInference
}
