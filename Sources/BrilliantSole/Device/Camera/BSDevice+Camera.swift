//
//  BSDevice+Camera.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 5/27/25.
//

import Combine
import Foundation

public extension BSDevice {
    // MARK: - setup

    internal func setupCameraManager() {}

    // MARK: - isCameraAvailable

    var isCameraAvailable: Bool { sensorTypes.contains(.camera) }

    // MARK: - cameraStatus

    var cameraStatus: BSCameraStatus { cameraManager.cameraStatus }
    var cameraStatusPublisher: AnyPublisher<BSCameraStatus, Never> { cameraManager.cameraStatusPublisher }
    var cameraFinishedFocusingPublisher: AnyPublisher<Void, Never> { cameraManager.finishedFocusingPublisher }

    // MARK: - cameraCommand

    func takePicture(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.takePicture(sendImmediately: sendImmediately)
    }

    func focusCamera(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.focus(sendImmediately: sendImmediately)
    }

    func stopCamera(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.stop(sendImmediately: sendImmediately)
    }

    func wakeCamera(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.wake(sendImmediately: sendImmediately)
    }

    func sleepCamera(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.sleep(sendImmediately: sendImmediately)
    }

    func toggleCameraWake(sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.toggleWake(sendImmediately: sendImmediately)
    }

    // MARK: - cameraConfiguration

    var cameraConfiguration: BSCameraConfiguration { cameraManager.cameraConfiguration }
    var cameraConfigurationPublisher: AnyPublisher<BSCameraConfiguration, Never> { cameraManager.cameraConfigurationPublisher }

    var cameraConfigurationTypes: [BSCameraConfigurationType] { cameraManager.configurationTypes }

    func setCameraConfiguration(_ configuration: BSCameraConfiguration, sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.setConfiguration(configuration, sendImmediately: sendImmediately)
    }

    func getCameraConfigurationValue(_ type: BSCameraConfigurationType) -> BSCameraConfigurationValue? {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return nil
        }
        return cameraManager.getConfigurationValue(type)
    }

    func setCameraConfigurationValue(_ type: BSCameraConfigurationType, value: BSCameraConfigurationValue, sendImmediately: Bool = true) {
        guard isCameraAvailable else {
            logger?.error("camera is not available")
            return
        }
        cameraManager.setConfigurationValue(type, value: value, sendImmediately: sendImmediately)
    }

    // MARK: - cameraData

    var cameraHeaderProgress: Float { cameraManager.headerProgress }
    var cameraHeaderProgressPublisher: AnyPublisher<Float, Never> {
        cameraManager.headerProgressPublisher
    }

    var cameraImageProgress: Float { cameraManager.imageProgress }
    var cameraImageProgressPublisher: AnyPublisher<Float, Never> {
        cameraManager.imageProgressPublisher
    }

    var cameraFooterProgress: Float { cameraManager.footerProgress }
    var cameraFooterProgressPublisher: AnyPublisher<Float, Never> {
        cameraManager.footerProgressPublisher
    }

    // MARK: - cameraImage

    var cameraImagePublisher: AnyPublisher<Data, Never> {
        cameraManager.imagePublisher
    }
}
