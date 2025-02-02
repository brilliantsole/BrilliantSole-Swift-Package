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

        tfliteManager.tfliteInferencePublisher.sink { inference in
            self.tfliteInferenceSubject.send((self, inference))
        }.store(in: &managerCancellables)

        tfliteManager.tfliteClassificationPublisher.sink { classification in
            self.tfliteClassificationSubject.send((self, classification))
        }.store(in: &managerCancellables)
    }

    // MARK: - isTfliteReady

    private func checkIsTfliteReady() {
        isTfliteReady = tfliteManager.isTfliteReady && tfliteManager.tfliteFile != nil
    }

    // MARK: - tfliteInferencingEnabled

    var tfliteInferencingEnabled: Bool {
        tfliteManager.tfliteInferencingEnabled
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
