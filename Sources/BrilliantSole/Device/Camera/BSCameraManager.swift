//
//  BSCameraManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

typealias BSCameraSizeType = UInt16
typealias BSCameraImageSizeType = UInt32

@StaticLogger(disabled: true)
final class BSCameraManager: BSBaseManager<BSCameraMessageType> {
    override class var requiredFollowUpMessageTypes: [BSCameraMessageType]? {
        [
            .cameraStatus,
            .getCameraConfiguration
        ]
    }

    override func onRxMessage(_ messageType: BSCameraMessageType, data: Data) {
        switch messageType {
        case .cameraStatus:
            parseCameraStatus(data)
        case .getCameraConfiguration, .setCameraConfiguration:
            parseCameraConfiguration(data)
        case .cameraData:
            parseCameraData(data)
        case .cameraCommand:
            break
        }
    }

    override func reset() {
        super.reset()
        cameraConfiguration.removeAll(keepingCapacity: true)

        headerSize = nil
        headerData = nil
        headerProgress = 0

        imageSize = nil
        imageData = nil
        imageProgress = 0

        footerSize = nil
        footerData = nil
        footerProgress = 0
    }

    // MARK: - cameraStatus

    private let cameraStatusSubject = CurrentValueSubject<BSCameraStatus, Never>(.idle)
    var cameraStatusPublisher: AnyPublisher<BSCameraStatus, Never> {
        cameraStatusSubject.eraseToAnyPublisher()
    }

    private let finishedFocusingSubject = PassthroughSubject<Void, Never>()
    var finishedFocusingPublisher: AnyPublisher<Void, Never> {
        finishedFocusingSubject.eraseToAnyPublisher()
    }

    private(set) var cameraStatus: BSCameraStatus {
        get { cameraStatusSubject.value }
        set {
            logger?.debug("updated cameraStatus to \(newValue.name)")
            if newValue == .idle, cameraStatus == .focusing {
                logger?.debug("finished focusing")
                finishedFocusingSubject.send()
            }
            cameraStatusSubject.value = newValue
        }
    }

    func getCameraStatus(sendImmediately: Bool = true) {
        logger?.debug("getting cameraStatus")
        createAndSendMessage(.cameraStatus, sendImmediately: sendImmediately)
    }

    private func parseCameraStatus(_ data: Data) {
        guard let newCameraStatus = BSCameraStatus.parse(data) else {
            return
        }
        logger?.debug("parsed cameraStatus: \(newCameraStatus.name)")
        cameraStatus = newCameraStatus
    }

    // MARK: - cameraConfiguration

    private let cameraConfigurationSubject = CurrentValueSubject<BSCameraConfiguration, Never>(.init())
    var cameraConfigurationPublisher: AnyPublisher<BSCameraConfiguration, Never> {
        cameraConfigurationSubject.eraseToAnyPublisher()
    }

    private(set) var cameraConfiguration: BSCameraConfiguration {
        get { cameraConfigurationSubject.value }
        set {
            logger?.debug("updated cameraConfiguration to \(newValue)")
            cameraConfigurationSubject.value = newValue
        }
    }

    private func parseCameraConfiguration(_ data: Data) {
        guard let newCameraConfiguration: BSCameraConfiguration = .parse(data) else {
            logger?.error("failed to parse cameraConfiguration")
            return
        }
        logger?.debug("parsed cameraConfiguration: \(newCameraConfiguration)")
        cameraConfiguration = newCameraConfiguration
    }

    func getCameraConfiguration(sendImmediately: Bool = true) {
        logger?.debug("getting cameraConfiguration")
        createAndSendMessage(.getCameraConfiguration, sendImmediately: sendImmediately)
    }

    func setConfiguration(_ newCameraConfiguration: BSCameraConfiguration, sendImmediately: Bool = true) {
        guard !newCameraConfiguration.isEmpty else {
            logger?.warning("ignoring empty cameraConfiguration")
            return
        }
        guard !newCameraConfiguration.isASubsetOf(cameraConfiguration) else {
            logger?.debug("newCameraConfiguration is a subset - not setting")
            return
        }
        var _newCameraConfiguration = newCameraConfiguration
        logger?.debug("sending setCameraConfiguration: \(_newCameraConfiguration)")
        createAndSendMessage(.setCameraConfiguration, data: _newCameraConfiguration.getData(), sendImmediately: sendImmediately)
    }

    func containsConfigurationType(_ type: BSCameraConfigurationType) -> Bool { configurationTypes.contains(type) }
    func getConfigurationValue(_ type: BSCameraConfigurationType) -> BSCameraConfigurationValue? { cameraConfiguration[type] }
    func setConfigurationValue(_ type: BSCameraConfigurationType, value: BSCameraConfigurationValue, sendImmediately: Bool = true) {
        guard containsConfigurationType(type) else {
            logger?.debug("camera doesn't contain configuratinType \(type.name)")
            return
        }
        guard let currentValue = getConfigurationValue(type), currentValue != value else {
            logger?.debug("type \(type.name) already has value \(value)")
            return
        }

        var newCameraConfiguration: BSCameraConfiguration = .init()
        newCameraConfiguration[type] = value
        logger?.debug("sending setCameraConfiguration: \(newCameraConfiguration)")
        setConfiguration(newCameraConfiguration, sendImmediately: sendImmediately)
    }

    var configurationTypes: [BSCameraConfigurationType] { cameraConfiguration.types }

    // MARK: - cameraCommand

    private func setCameraCommand(_ cameraCommand: BSCameraCommand, sendImmediately: Bool = true) {
        logger?.debug("setting cameraCommand \(cameraCommand.name)")
        createAndSendMessage(.cameraCommand, data: cameraCommand.data, sendImmediately: sendImmediately)
    }

    func takePicture(sendImmediately: Bool = true) {
        guard cameraStatus != .asleep else {
            logger?.warning("cannot take picture when asleep")
            return
        }
        imageProgress = 0
        setCameraCommand(.takePicture, sendImmediately: sendImmediately)
    }

    func focus(sendImmediately: Bool = true) {
        guard cameraStatus != .asleep else {
            logger?.warning("cannot focus when asleep")
            return
        }
        setCameraCommand(.focus, sendImmediately: sendImmediately)
    }

    func stop(sendImmediately: Bool = true) {
        setCameraCommand(.stop, sendImmediately: sendImmediately)
    }

    func sleep(sendImmediately: Bool = true) {
        guard cameraStatus != .asleep else {
            logger?.warning("camera already asleep")
            return
        }
        setCameraCommand(.sleep, sendImmediately: sendImmediately)
    }

    func wake(sendImmediately: Bool = true) {
        guard cameraStatus == .asleep else {
            logger?.warning("camera already awake")
            return
        }
        setCameraCommand(.wake, sendImmediately: sendImmediately)
    }

    func toggleWake(sendImmediately: Bool = true) {
        if cameraStatus == .asleep {
            wake(sendImmediately: sendImmediately)
        }
        else {
            sleep(sendImmediately: sendImmediately)
        }
    }

    // MARK: - cameraHeader

    private var headerSize: BSCameraSizeType? {
        didSet {
            headerData = .init()
            headerProgress = 0
        }
    }

    private var headerData: Data?

    private let headerProgressSubject = CurrentValueSubject<Float, Never>(0)
    var headerProgressPublisher: AnyPublisher<Float, Never> {
        headerProgressSubject.eraseToAnyPublisher()
    }

    private(set) var headerProgress: Float {
        get { headerProgressSubject.value }
        set {
            logger?.debug("updated headerProgress to \(newValue)")
            headerProgressSubject.value = newValue
        }
    }

    private var isHeaderComplete: Bool { headerProgress == 1 }

    // MARK: - cameraImage

    private var imageSize: BSCameraImageSizeType? {
        didSet {
            imageData = .init()
            imageProgress = 0
        }
    }

    private var imageData: Data?

    private let imageProgressSubject = CurrentValueSubject<Float, Never>(0)
    var imageProgressPublisher: AnyPublisher<Float, Never> {
        imageProgressSubject.eraseToAnyPublisher()
    }

    private(set) var imageProgress: Float {
        get { imageProgressSubject.value }
        set {
            logger?.debug("updated imageProgress to \(newValue)")
            imageProgressSubject.value = newValue
        }
    }

    private var isImageComplete: Bool { imageProgress == 1 }

    // MARK: - cameraFooter

    private var footerSize: BSCameraSizeType? {
        didSet {
            footerData = .init()
            footerProgress = 0
        }
    }

    private let footerProgressSubject = CurrentValueSubject<Float, Never>(0)
    var footerProgressPublisher: AnyPublisher<Float, Never> {
        footerProgressSubject.eraseToAnyPublisher()
    }

    private(set) var footerProgress: Float {
        get { footerProgressSubject.value }
        set {
            logger?.debug("updated footerProgress to \(newValue)")
            footerProgressSubject.value = newValue
        }
    }

    private var footerData: Data?
    private var isFooterComplete: Bool { footerProgress == 1 }

    // MARK: - cameraData

    private func parseCameraData(_ data: Data) {
        var offset: Data.Index = .zero
        parseMessages(data, messageCallback: { cameraDataType, data in
            self.parseCameraDataMessage(cameraDataType: cameraDataType, data: data)
        }, at: offset, parseMessageLengthAs2Bytes: true)
    }

    private func parseCameraDataMessage(cameraDataType: BSCameraDataType, data: Data) {
        logger?.debug("parsing cameraDataType \(cameraDataType.name) (\(data.count) bytes)")

        switch cameraDataType {
        case .headerSize:
            parseHeaderSize(data)
        case .header:
            parseHeader(data)
        case .imageSize:
            parseImageSize(data)
        case .image:
            parseImage(data)
        case .footerSize:
            parseFooterSize(data)
        case .footer:
            parseFooter(data)
        }
    }

    private func parseHeaderSize(_ data: Data) {
        guard let newHeaderSize: BSCameraSizeType = .parse(data) else { return }
        logger?.debug("parsed headerSize \(newHeaderSize)")
        headerSize = newHeaderSize
    }

    private func parseHeader(_ data: Data) {
        guard headerData != nil else {
            logger?.error("headerData is nil")
            return
        }
        headerData!.append(data)

        guard let count = headerData?.count, let total = headerSize else {
            logger?.error("failed to get headerData count and/or headerSize")
            return
        }
        logger?.debug("parsed \(count)/\(total) of header")

        headerProgress = Float(count) / Float(total)
        logger?.debug("headerProgress: \(self.headerProgress * 100)%")

        if isHeaderComplete {
            logger?.debug("finished receiving header data")
        }
    }

    private func parseImageSize(_ data: Data) {
        guard let newImageSize: BSCameraImageSizeType = .parse(data) else { return }
        logger?.debug("parsed imageSize \(newImageSize)")
        imageSize = newImageSize
    }

    private func parseImage(_ data: Data) {
        guard imageData != nil else {
            logger?.error("imageData is nil")
            return
        }
        imageData!.append(data)

        guard let count = imageData?.count, let total = imageSize else {
            logger?.error("failed to get imageData count and/or imageSize")
            return
        }
        logger?.debug("parsed \(count)/\(total) of image")

        imageProgress = Float(count) / Float(total)
        logger?.debug("imageProgress: \(self.imageProgress * 100)%")

        if isImageComplete {
            logger?.debug("finished receiving image data")
            if isFooterComplete {
                buildImage()
            }
        }
    }

    private func parseFooterSize(_ data: Data) {
        guard let newFooterSize: BSCameraSizeType = .parse(data) else { return }
        logger?.debug("parsed footerSize \(newFooterSize)")
        footerSize = newFooterSize
    }

    private func parseFooter(_ data: Data) {
        guard footerData != nil else {
            logger?.error("footerData is nil")
            return
        }
        footerData!.append(data)

        guard let count = footerData?.count, let total = footerSize else {
            logger?.error("failed to get footerData count and/or footerSize")
            return
        }
        logger?.debug("parsed \(count)/\(total) of footer")

        footerProgress = Float(count) / Float(total)
        logger?.debug("footerProgress: \(self.footerProgress * 100)%")

        if isFooterComplete {
            logger?.debug("finished receiving footer data")
            if isImageComplete {
                buildImage()
            }
        }
    }

    // MARK: - buldImage

    private let imageSubject: PassthroughSubject<Data, Never> = .init()
    var imagePublisher: AnyPublisher<Data, Never> {
        imageSubject.eraseToAnyPublisher()
    }

    private func buildImage() {
        guard let headerData, isHeaderComplete else {
            logger?.error("header is incomplete - cannot build image")
            return
        }
        guard let imageData, isImageComplete else {
            logger?.error("image is incomplete - cannot build image")
            return
        }
        guard let footerData, isFooterComplete else {
            logger?.error("footer is incomplete - cannot build image")
            return
        }

        var fullImageData = Data()
        fullImageData.append(headerData)
        fullImageData.append(imageData)
        fullImageData.append(footerData)

        logger?.debug("building image (\(fullImageData.count) bytes)")

        imageSubject.send(fullImageData)
    }
}
