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
        tfliteManager.isTfliteReadyPublisher.sink { _ in
            self.checkIsTfliteReady()
        }.store(in: &managerCancellables)
    }

    // MARK: - tfliteName

    var tfliteName: String { tfliteManager.tfliteName }
    var tfliteNamePublisher: AnyPublisher<String, Never> { tfliteManager.tfliteNamePublisher }

    // MARK: - tfliteTask

    var tfliteTask: BSTfliteTask { tfliteManager.tfliteTask }
    var tfliteTaskPublisher: AnyPublisher<BSTfliteTask, Never> { tfliteManager.tfliteTaskPublisher }

    // MARK: - tfliteSensorRate

    var tfliteSensorRate: BSSensorRate { tfliteManager.tfliteSensorRate }
    var tfliteSensorRatePublisher: AnyPublisher<BSSensorRate, Never> { tfliteManager.tfliteSensorRatePublisher }

    // MARK: - tfliteSensorTypes

    var tfliteSensorTypes: BSTfliteSensorTypes { tfliteManager.tfliteSensorTypes }
    var tfliteSensorTypesPublisher: AnyPublisher<BSTfliteSensorTypes, Never> { tfliteManager.tfliteSensorTypesPublisher }

    // MARK: - isTfliteReady

    private func checkIsTfliteReady() {
        isTfliteReady = tfliteManager.isTfliteReady && tfliteManager.tfliteFile != nil
    }

    // MARK: - tfliteCaptureDelay

    var tfliteCaptureDelay: BSTfliteCaptureDelay { tfliteManager.tfliteCaptureDelay }
    var tfliteCaptureDelayPublisher: AnyPublisher<BSTfliteCaptureDelay, Never> { tfliteManager.tfliteCaptureDelayPublisher }

    func setTfliteCaptureDelay(_ newCaptureDelay: BSTfliteCaptureDelay) {
        tfliteManager.setTfliteCaptureDelay(newCaptureDelay)
    }

    // MARK: - tfliteThreshold

    var tfliteThreshold: BSTfliteThreshold { tfliteManager.tfliteThreshold }
    var tfliteThresholdPublisher: AnyPublisher<BSTfliteThreshold, Never> { tfliteManager.tfliteThresholdPublisher }

    func setTfliteThreshold(_ newThreshold: BSTfliteThreshold) {
        tfliteManager.setTfliteThreshold(newThreshold)
    }

    // MARK: - tfliteInferencingEnabled

    var tfliteInferencingEnabled: Bool { tfliteManager.tfliteInferencingEnabled }
    var tfliteInferencingEnabledPublisher: AnyPublisher<Bool, Never> { tfliteManager.tfliteInferencingEnabledPublisher }

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
            flushMessages()
        }
    }

    // MARK: - inferencing

    var tfliteInferencePublisher: BSTfliteInferencePublisher { tfliteManager.tfliteInferencePublisher }
    var tfliteClassificationPublisher: BSTfliteClassificationPublisher { tfliteManager.tfliteClassificationPublisher }
}
