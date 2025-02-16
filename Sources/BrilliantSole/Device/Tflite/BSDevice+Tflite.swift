//
//  BSDevice+Tflite.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/30/25.
//

import Combine

public extension BSDevice {
    // MARK: - setup

    internal func setupTfliteManager() {
        tfliteManager.tfliteNamePublisher.sink { tfliteName in
            self.tfliteNameSubject.send(( tfliteName))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteTaskPublisher.sink { tfliteTask in
            self.tfliteTaskSubject.send(( tfliteTask))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteSensorRatePublisher.sink { tfliteSensorRate in
            self.tfliteSensorRateSubject.send(( tfliteSensorRate))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteSensorTypesPublisher.sink { tfliteSensorTypes in
            self.tfliteSensorTypesSubject.send(( tfliteSensorTypes))
        }.store(in: &managerCancellables)

        tfliteManager.isTfliteReadyPublisher.sink { _ in
            self.checkIsTfliteReady()
        }.store(in: &managerCancellables)

        tfliteManager.tfliteThresholdPublisher.sink { tfliteThreshold in
            self.tfliteThresholdSubject.send(( tfliteThreshold))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteCaptureDelayPublisher.sink { tfliteCaptureDelay in
            self.tfliteCaptureDelaySubject.send(( tfliteCaptureDelay))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteInferencingEnabledPublisher.sink { tfliteInferencingEnabled in
            self.tfliteInferencingEnabledSubject.send(( tfliteInferencingEnabled))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteInferencePublisher.sink { inference in
            self.tfliteInferenceSubject.send(( inference))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteClassificationPublisher.sink { classification in
            self.tfliteClassificationSubject.send(( classification))
        }.store(in: &managerCancellables)
    }

    // MARK: - tfliteName

    var tfliteName: String { tfliteManager.tfliteName }

    // MARK: - tfliteTask

    var tfliteTask: BSTfliteTask { tfliteManager.tfliteTask }

    // MARK: - tfliteSensorRate

    var tfliteSensorRate: BSSensorRate { tfliteManager.tfliteSensorRate }

    // MARK: - tfliteSensorTypes

    var tfliteSensorTypes: BSTfliteSensorTypes { tfliteManager.tfliteSensorTypes }

    // MARK: - isTfliteReady

    private func checkIsTfliteReady() {
        isTfliteReady = tfliteManager.isTfliteReady && tfliteManager.tfliteFile != nil
    }

    // MARK: - tfliteCaptureDelay

    var tfliteCaptureDelay: BSTfliteCaptureDelay { tfliteManager.tfliteCaptureDelay }

    // MARK: - tfliteThreshold

    var tfliteThreshold: BSTfliteThreshold { tfliteManager.tfliteThreshold }

    // MARK: - tfliteInferencingEnabled

    var tfliteInferencingEnabled: Bool { tfliteManager.tfliteInferencingEnabled }

    func setTfliteInferencingEnabled(_ newTfliteInferencingEnabled: Bool, sendImmediately: Bool = true) {
        tfliteManager.setTfliteInferencingEnabled(newTfliteInferencingEnabled, sendImmediately: sendImmediately)
    }

    func enableTfliteInferencing(sendImmediately: Bool = true) {
        tfliteManager.enableTfliteInferencing(sendImmediately: sendImmediately)
    }

    func disableTfliteInferencing(sendImmediately: Bool = true) {
        tfliteManager.disableTfliteInferencing(sendImmediately: sendImmediately)
    }

    func toggleTfliteInferencingEnabled(sendImmediately: Bool = true) {
        tfliteManager.toggleTfliteInferencingEnabled(sendImmediately: sendImmediately)
    }

    // MARK: - sendTfliteModel

    var tfliteFile: BSTfliteFile? { tfliteManager.tfliteFile }
    func sendTfliteModel(_ newTfliteFile: inout BSTfliteFile) {
        guard let _ = newTfliteFile.getFileData() else {
            logger?.error("failed to get newTfliteFile data")
            return
        }
        var file = newTfliteFile as BSFile
        tfliteManager.sendTfliteFile(newTfliteFile, sendImmediately: false)
        let isSendingFile = fileTransferManager.sendFile(&file, sendImmediately: true)
        if !isSendingFile {
            checkIsTfliteReady()
        }
    }
}
