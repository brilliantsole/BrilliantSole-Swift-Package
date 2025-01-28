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

        tfliteFile = nil
    }

    // MARK: - tfliteFile

    public private(set) var tfliteFile: BSTfliteFile?
    func sendTfliteFile(_ newTfliteFile: BSTfliteFile, sendImmediately: Bool = true) {
        guard newTfliteFile !== tfliteFile else {
            logger.debug("redundant tfliteFile assignent \(newTfliteFile.tfliteName)")
            return
        }

        tfliteFile = newTfliteFile
        guard let tfliteFile else {
            logger.error("nil tfliteFile")
            return
        }
        setTfliteName(tfliteFile.tfliteName, sendImmediately: false)
        setTfliteTask(tfliteFile.task, sendImmediately: false)
        setTfliteCaptureDelay(tfliteFile.captureDelay, sendImmediately: false)
        setTfliteSensorRate(tfliteFile.sensorRate, sendImmediately: false)
        setTfliteThreshold(tfliteFile.threshold, sendImmediately: false)
        setTfliteSensorTypes(tfliteFile.sensorTypes, sendImmediately: sendImmediately)
    }

    // MARK: - tfliteName

    let tfliteNameSubject: CurrentValueSubject<String, Never> = .init("")
    var tfliteName: String {
        get { tfliteNameSubject.value }
        set {
            logger.debug("updated tfliteName to \(newValue)")
            tfliteNameSubject.value = newValue
        }
    }

    func getTfliteName(sendImmediately: Bool = true) {
        logger.debug("getting tfliteName")
        createAndSendMessage(.getTfliteName, sendImmediately: sendImmediately)
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
            logger.debug("updated tfliteTask to \(newValue.name)")
            tfliteTaskSubject.value = newValue
        }
    }

    func getTfliteTask(sendImmediately: Bool = true) {
        logger.debug("getting tfliteTask")
        createAndSendMessage(.getTfliteTask, sendImmediately: sendImmediately)
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
            logger.debug("updated tfliteSensorRate to \(newValue.name)")
            tfliteSensorRateSubject.value = newValue
        }
    }

    func getTfliteSensorRate(sendImmediately: Bool = true) {
        logger.debug("getting tfliteSensorRate")
        createAndSendMessage(.getTfliteSensorRate, sendImmediately: sendImmediately)
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
            logger.debug("updated tfliteSensorTypes to \(newValue)")
            tfliteSensorTypesSubject.value = newValue
        }
    }

    func getTfliteSensorTypes(sendImmediately: Bool = true) {
        logger.debug("getting tfliteSensorTypes")
        createAndSendMessage(.getTfliteSensorTypes, sendImmediately: sendImmediately)
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
            logger.debug("updated isTfliteReady to \(newValue)")
            isTfliteReadySubject.value = newValue
        }
    }

    func getIsTfliteReady(sendImmediately: Bool = true) {
        logger.debug("getting isTfliteReady")
        createAndSendMessage(.isTfliteReady, sendImmediately: sendImmediately)
    }

    func parseIsTfliteReady(_ data: Data) {
        let newIsTfliteReady: Bool = .parse(data)
        logger.debug("parsed isTfliteReady \(newIsTfliteReady)")
        isTfliteReady = newIsTfliteReady
    }

    // MARK: - tfliteCaptureDelay

    let tfliteCaptureDelaySubject: CurrentValueSubject<BSTfliteCaptureDelay, Never> = .init(0)
    var tfliteCaptureDelay: BSTfliteCaptureDelay {
        get { tfliteCaptureDelaySubject.value }
        set {
            logger.debug("updated tfliteCaptureDelay to \(newValue)")
            tfliteCaptureDelaySubject.value = newValue
        }
    }

    func getTfliteCaptureDelay(sendImmediately: Bool = true) {
        logger.debug("getting tfliteCaptureDelay")
        createAndSendMessage(.getTfliteCaptureDelay, sendImmediately: sendImmediately)
    }

    func parseTfliteCaptureDelay(_ data: Data) {
        let newTfliteCaptureDelay: BSTfliteCaptureDelay = .parse(data)
        logger.debug("parsed tfliteCaptureDelay \(newTfliteCaptureDelay)")
        tfliteCaptureDelay = newTfliteCaptureDelay
    }

    func setTfliteCaptureDelay(_ newTfliteCaptureDelay: BSTfliteCaptureDelay, sendImmediately: Bool = true) {
        guard newTfliteCaptureDelay != tfliteCaptureDelay else {
            logger.debug("redundant tfliteCaptureDelay assignment \(newTfliteCaptureDelay)")
            return
        }
        logger.debug("setting tfliteCaptureDelay to \(newTfliteCaptureDelay)")
        createAndSendMessage(.setTfliteCaptureDelay, data: newTfliteCaptureDelay.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - tfliteThreshold

    let tfliteThresholdSubject: CurrentValueSubject<BSTfliteThreshold, Never> = .init(0)
    var tfliteThreshold: BSTfliteThreshold {
        get { tfliteThresholdSubject.value }
        set {
            logger.debug("updated tfliteThreshold to \(newValue)")
            tfliteThresholdSubject.value = newValue
        }
    }

    func getTfliteThreshold(sendImmediately: Bool = true) {
        logger.debug("getting tfliteThreshold")
        createAndSendMessage(.getTfliteThreshold, sendImmediately: sendImmediately)
    }

    func parseTfliteThreshold(_ data: Data) {
        let newTfliteThreshold: BSTfliteThreshold = .parse(data)
        logger.debug("parsed tfliteThreshold: \(newTfliteThreshold)")
        tfliteThreshold = newTfliteThreshold
    }

    func setTfliteThreshold(_ newTfliteThreshold: BSTfliteThreshold, sendImmediately: Bool = true) {
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
            logger.debug("updated tfliteInferencingEnabled to \(newValue)")
            tfliteInferencingEnabledSubject.value = newValue
        }
    }

    func getTfliteInferencingEnabled(sendImmediately: Bool = true) {
        logger.debug("getting tfliteInferencingEnabled")
        createAndSendMessage(.getTfliteInferencingEnabled, sendImmediately: sendImmediately)
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

    typealias BSInference = ([Float], [String: Float]?, BSTimestamp)
    typealias BSClassification = (String, Float, BSTimestamp)

    let tfliteInferenceSubject: PassthroughSubject<BSInference, Never> = .init()
    let tfliteClassificationSubject: PassthroughSubject<BSClassification, Never> = .init()

    func parseTfliteInference(_ data: Data) {
        guard let tfliteFile else {
            logger.error("no tfliteFile defined")
            return
        }

        var offset: Data.Index = .zero

        let timestamp = parseTimestamp(data, at: &offset)
        logger.debug("timestamp: \(timestamp)ms")

        let inferenceData = data[offset...]
        let inferenceSize = 4
        guard (inferenceData.count % inferenceSize) == 0 else {
            logger.error("inferenceData length is not a multiple of \(inferenceSize) (got \(inferenceData.count)")
            return
        }

        let numberOfInferences = inferenceData.count / inferenceSize

        var inferenceMap: [String: Float]?
        if let tfliteClasses = tfliteFile.classes {
            if tfliteClasses.count == numberOfInferences {
                inferenceMap = .init()
            }
            else {
                logger.error("numberOfInferences doesn't match tfliteFile (expected \(tfliteClasses.count), got \(numberOfInferences)")
            }
        }

        var inference: [Float] = []
        var maxValue: Float = -Float.infinity
        var maxIndex: Int = -1
        var maxClassName: String?
        for offset in stride(from: 0, to: inferenceData.count, by: inferenceSize) {
            let index = inference.count
            let value: Float = .parse(inferenceData, at: offset)
            logger.debug("class #\(index) value: \(value)")
            inference.append(value)

            if var inferenceMap, let tfliteClasses = tfliteFile.classes {
                let className = tfliteClasses[index]
                inferenceMap[className] = value
                logger.debug("#\(index) \(className): \(value)")
                if tfliteTask == .classification {
                    if value > maxValue {
                        maxValue = value
                        maxIndex = index
                        maxClassName = className
                    }
                }
            }
        }
        logger.debug("parsed inference with \(inference.count) classes at \(timestamp)ms")

        tfliteInferenceSubject.send((inference, inferenceMap, timestamp))
        if tfliteTask == .classification, let maxClassName {
            logger.debug("maxClass \(maxClassName) (#\(maxIndex) with \(maxValue)")
            tfliteClassificationSubject.send((maxClassName, maxValue, timestamp))
        }
    }
}
