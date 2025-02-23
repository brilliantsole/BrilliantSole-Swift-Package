//
//  BSFirmwareManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/9/25.
//

import Combine
import CoreBluetooth
import iOSMcuManagerLibrary
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
class BSFirmwareManager: FirmwareUpgradeDelegate, McuMgrLogDelegate {
    // MARK: - firmwareUpgradeManager

    private var firmwareUpgradeManager: FirmwareUpgradeManager? {
        didSet {
            firmwareUpgradeManager?.logDelegate = self
        }
    }

    var isInProgress: Bool {
        firmwareUpgradeManager?.isInProgress() ?? false
    }

    var isPaused: Bool {
        firmwareUpgradeManager?.isPaused() ?? false
    }

    // MARK: - commands

    func upgradeFirmware(fileName: String = "firmware", fileExtension: String = "bin", bundle: Bundle = .main, peripheral: CBPeripheral) {
        guard !isInProgress else {
            logger?.debug("already upgrading")
            return
        }

        logger?.debug("updating firmware to \(fileName).\(fileExtension)")

        do {
            let bleTransport = McuMgrBleTransport(peripheral)
            firmwareUpgradeManager = FirmwareUpgradeManager(transport: bleTransport, delegate: self)
            guard let packageURL = bundle.url(forResource: fileName, withExtension: fileExtension) else {
                logger?.error("file \(fileName).\(fileExtension) not found")
                return
            }
            try firmwareUpgradeManager?.setUploadMtu(mtu: .init(mtu))
            let package = try McuMgrPackage(from: packageURL)
            let configuration: FirmwareUpgradeConfiguration = .init(estimatedSwapTime: 10.0, pipelineDepth: 2, upgradeMode: .confirmOnly)
            try firmwareUpgradeManager?.start(package: package, using: configuration)
        } catch {
            logger?.error("error updating firmware: \(error.localizedDescription)")
        }
    }

    func pause() {
        guard isInProgress else {
            logger?.debug("already not upgrading")
            return
        }
        firmwareUpgradeManager?.pause()
    }

    func cancel() {
        guard isInProgress else {
            logger?.debug("already not upgrading")
            return
        }
        firmwareUpgradeManager?.cancel()
    }

    func resume() {
        guard isPaused else {
            logger?.debug("already not paused")
            return
        }
        firmwareUpgradeManager?.resume()
    }

    // MARK: - publishers

    private let firmwareUpgradeDidStartSubject: PassthroughSubject<Void, Never> = .init()
    var firmwareUpgradeDidStartPublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidStartSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeStateDidChangeSubject: PassthroughSubject<(FirmwareUpgradeState, FirmwareUpgradeState), Never> = .init()
    var firmwareUpgradeStateDidChangePublisher: AnyPublisher<(FirmwareUpgradeState, FirmwareUpgradeState), Never> {
        firmwareUpgradeStateDidChangeSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidCompleteSubject: PassthroughSubject<Void, Never> = .init()
    var firmwareUpgradeDidCompletePublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidCompleteSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidFailSubject: PassthroughSubject<(FirmwareUpgradeState, any Error), Never> = .init()
    var firmwareUpgradeDidFailPublisher: AnyPublisher<(FirmwareUpgradeState, any Error), Never> {
        firmwareUpgradeDidFailSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidCancelSubject: PassthroughSubject<FirmwareUpgradeState, Never> = .init()
    var firmwareUpgradeDidCancelPublisher: AnyPublisher<FirmwareUpgradeState, Never> {
        firmwareUpgradeDidCancelSubject.eraseToAnyPublisher()
    }

    private let firmwareUploadProgressDidChangeSubject: PassthroughSubject<(Int, Int, Float, Date), Never> = .init()
    var firmwareUploadProgressDidChangePublisher: AnyPublisher<(Int, Int, Float, Date), Never> {
        firmwareUploadProgressDidChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - FirmwareUpgradeDelegate

    public func upgradeDidStart(controller: any FirmwareUpgradeController) {
        logger?.debug("firmware upgradeDidStart")
        firmwareUpgradeDidStartSubject.send()
    }

    public func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeStateDidChange from \(String(describing: previousState)) to \(String(describing: newState))")
        firmwareUpgradeStateDidChangeSubject.send((previousState, newState))
    }

    public func upgradeDidComplete() {
        logger?.debug("firmware upgradeDidComplete")
        firmwareUpgradeDidCompleteSubject.send()
    }

    public func upgradeDidFail(inState state: FirmwareUpgradeState, with error: any Error) {
        logger?.debug("firmware upgradeDidFail inState \(String(describing: state)): \(error.localizedDescription)")
        firmwareUpgradeDidFailSubject.send((state, error))
    }

    public func upgradeDidCancel(state: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeDidCancel state \(String(describing: state))")
        firmwareUpgradeDidCancelSubject.send(state)
    }

    public func uploadProgressDidChange(bytesSent: Int, imageSize: Int, timestamp: Date) {
        let progress = Float(bytesSent) / Float(imageSize)
        logger?.debug("firmware uploadProgressDidChange bytesSent: \(bytesSent), imageSize: \(imageSize), progress: \(progress * 100)% timestamp: \(timestamp)")
        firmwareUploadProgressDidChangeSubject.send((bytesSent, imageSize, progress, timestamp))
    }

    // MARK: - McuMgrLogDelegate

    func log(_ msg: String, ofCategory category: iOSMcuManagerLibrary.McuMgrLogCategory, atLevel level: iOSMcuManagerLibrary.McuMgrLogLevel) {
        switch level {
        case .debug:
            logger?.debug("\(String(describing: category)): \(msg)")
        case .verbose:
            logger?.debug("\(String(describing: category)): \(msg)")
        case .info:
            logger?.info("\(String(describing: category)): \(msg)")
        case .application:
            logger?.debug("\(String(describing: category)): \(msg)")
        case .warning:
            logger?.warning("\(String(describing: category)): \(msg)")
        case .error:
            logger?.error("\(String(describing: category)): \(msg)")
        }
    }

    func minLogLevel() -> iOSMcuManagerLibrary.McuMgrLogLevel {
        logger != nil ? .debug : .error
    }

    // MARK: - mtu

    var mtu: BSMtu = 0
}
