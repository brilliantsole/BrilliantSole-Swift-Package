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
            parseIsTfliteReady(data)
        case .getTfliteCaptureDelay, .setTfliteCaptureDelay:
            parseTfliteCaptureDelay(data)
        case .getTfliteThreshold, .setTfliteThreshold:
            parseTfliteThreshold(data)
        case .getTfliteInferencingEnabled, .setTfliteInferencingEnabled:
            parseTfliteInferencingEnabled(data)
        case .tfliteInference:
            parseTfliteInference(data)
        }
    }

    override func reset() {
        super.reset()

        tfliteName = ""
        tfliteTask = .classification
        tfliteSensorRate = ._0ms
        tfliteSensorTypes = .init()
        isTfliteReady = false
        tfliteCaptureDelay = 0
        tfliteThreshold = 0
        tfliteInferencingEnabled = false
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
        logger.debug("setting tfliteSensorTypes to \(newTfliteSensorTypes)")
        createAndSendMessage(.setTfliteSensorTypes, data: newTfliteSensorTypes.data, sendImmediately: sendImmediately)
    }

    // MARK: - isTfliteReady

    let isTfliteReadySubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isTfliteReady: Bool {
        get { isTfliteReadySubject.value }
        set {
            isTfliteReadySubject.value = newValue
            logger.debug("updated isTfliteReady to \(newValue)")
        }
    }

    func parseIsTfliteReady(_ data: Data) {
        let newIsTfliteReady: Bool = .parse(data)
        logger.debug("parsed isTfliteReady \(newIsTfliteReady)")
        isTfliteReady = newIsTfliteReady
    }

    // MARK: - tfliteCaptureDelay

    let tfliteCaptureDelaySubject: CurrentValueSubject<UInt16, Never> = .init(0)
    var tfliteCaptureDelay: UInt16 {
        get { tfliteCaptureDelaySubject.value }
        set {
            tfliteCaptureDelaySubject.value = newValue
            logger.debug("updated tfliteCaptureDelay to \(newValue)")
        }
    }

    func parseTfliteCaptureDelay(_ data: Data) {
        let newTfliteCaptureDelay: UInt16 = .parse(data)
        logger.debug("parsed tfliteCaptureDelay \(newTfliteCaptureDelay)")
        tfliteCaptureDelay = newTfliteCaptureDelay
    }

    func setTfliteCaptureDelay(_ newTfliteCaptureDelay: UInt16, sendImmediately: Bool = true) {
        guard newTfliteCaptureDelay != tfliteCaptureDelay else {
            logger.debug("redundant tfliteCaptureDelay assignment \(newTfliteCaptureDelay)")
            return
        }
        logger.debug("setting tfliteCaptureDelay to \(newTfliteCaptureDelay)")
        createAndSendMessage(.setTfliteCaptureDelay, data: newTfliteCaptureDelay.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - tfliteThreshold

    let tfliteThresholdSubject: CurrentValueSubject<Float, Never> = .init(0)
    var tfliteThreshold: Float {
        get { tfliteThresholdSubject.value }
        set {
            tfliteThresholdSubject.value = newValue
            logger.debug("updated tfliteThreshold to \(newValue)")
        }
    }

    func parseTfliteThreshold(_ data: Data) {
        let newTfliteThreshold: Float = .parse(data)
        logger.debug("parsed tfliteThreshold: \(newTfliteThreshold)")
        tfliteThreshold = newTfliteThreshold
    }

    func setTfliteThreshold(_ newTfliteThreshold: Float, sendImmediately: Bool = true) {
        guard newTfliteThreshold != tfliteThreshold else {
            logger.debug("redundant tfliteThreshold assignment \(newTfliteThreshold)")
            return
        }
        logger.debug("setting tfliteThreshold to \(newTfliteThreshold)")
        createAndSendMessage(.setTfliteThreshold, data: newTfliteThreshold.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - tfliteInferencingEnabled

    let tfliteInferencingEnabledSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var tfliteInferencingEnabled: Bool {
        get { tfliteInferencingEnabledSubject.value }
        set {
            tfliteInferencingEnabledSubject.value = newValue
            logger.debug("updated tfliteInferencingEnabled to \(newValue)")
        }
    }

    func parseTfliteInferencingEnabled(_ data: Data) {
        let newTfliteInferencingEnabled: Bool = data.parse()
        logger.debug("parsed tfliteInferencingEnabled: \(newTfliteInferencingEnabled)")
        tfliteInferencingEnabled = newTfliteInferencingEnabled
    }

    func setTfliteInferencingEnabled(_ newTfliteInferencingEnabled: Bool, sendImmediately: Bool = true) {
        guard newTfliteInferencingEnabled != tfliteInferencingEnabled else {
            logger.debug("redundant tfliteInferencingEnabled assignment \(newTfliteInferencingEnabled)")
            return
        }
        guard isTfliteReady else {
            logger.error("tflite is not ready")
            return
        }
        logger.debug("setting tfliteInferencingEnabled to \(newTfliteInferencingEnabled)")
        createAndSendMessage(.setTfliteInferencingEnabled, data: newTfliteInferencingEnabled.data, sendImmediately: sendImmediately)
    }

    // MARK: - tfliteInference

    var tfliteFile: BSTfliteFile?

    typealias BSInference = ([Float], [String: Float]?, BSTimestamp)
    typealias BSClassification = (String, Float, BSTimestamp)

    let tfliteInferenceSubject: PassthroughSubject<BSInference, Never> = .init()
    let tfliteClassificationSubject: PassthroughSubject<BSClassification, Never> = .init()

    func parseTfliteInference(_ data: Data) {
        guard let tfliteFile else {
            logger.error("no tfliteFile defined")
            return
        }
        // FILL
    }
}
