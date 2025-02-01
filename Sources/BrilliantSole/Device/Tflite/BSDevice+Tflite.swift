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
        tfliteManager.isTfliteReadyPublisher.sink { [weak self] _ in
            self?.checkIsTfliteReady()
        }.store(in: &managerCancellables)
    }

    // MARK: - isTfliteReady

    internal func checkIsTfliteReady() {
        isTfliteReady = tfliteManager.isTfliteReady && tfliteManager.tfliteFile != nil
    }

    private(set) var isTfliteReady: Bool {
        get { isTfliteReadySubject.value }
        set {
            guard newValue != isTfliteReady else {
                logger.debug("redundant isTfliteReady \(newValue)")
                return
            }
            logger.debug("updating isTfliteReady \(newValue)")
            isTfliteReadySubject.value = newValue
        }
    }

    // MARK: - tfliteInferencingEnabled

    var tfliteInferencingEnabled: Bool {
        tfliteManager.tfliteInferencingEnabled
    }

    var tfliteInferencingEnabledPublisher: AnyPublisher<Bool, Never> {
        tfliteManager.tfliteInferencingEnabledPublisher
    }

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

    // MARK: - tfliteInference

    var tfliteInferencePublisher: AnyPublisher<BSInference, Never> {
        tfliteManager.tfliteInferencePublisher
    }

    // MARK: - tfliteClassification

    var tfliteClassificationPublisher: AnyPublisher<BSClassification, Never> {
        tfliteManager.tfliteClassificationPublisher
    }

    // MARK: - sendTfliteModel

    var tfliteFile: BSTfliteFile? { tfliteManager.tfliteFile }
    func sendTfliteModel(_ newTfliteFile: inout BSTfliteFile) {
        guard let _ = newTfliteFile.getFileData() else {
            logger.error("failed to get newTfliteFile data")
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
