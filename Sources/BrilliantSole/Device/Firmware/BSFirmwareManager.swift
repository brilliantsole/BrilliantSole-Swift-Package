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

public typealias BSFirmwareUpgradeState = FirmwareUpgradeState

public typealias BSFirmwareUploadProgressDidChangeData = (bytesSent: Int, imageSize: Int, progress: Float, timestamp: Date)
typealias BSFirmwareUploadProgressDidChangeSubject = PassthroughSubject<BSFirmwareUploadProgressDidChangeData, Never>
public typealias BSFirmwareUploadProgressDidChangePublisher = AnyPublisher<BSFirmwareUploadProgressDidChangeData, Never>

public typealias BSFirmwareUpgradeDidFailData = (state: FirmwareUpgradeState, error: any Error)
typealias BSFirmwareUpgradeDidFailSubject = PassthroughSubject<BSFirmwareUpgradeDidFailData, Never>
public typealias BSFirmwareUpgradeDidFailPublisher = AnyPublisher<BSFirmwareUpgradeDidFailData, Never>

public typealias BSFirmwareUpgradeStateDidChangeData = (previousState: FirmwareUpgradeState, newState: FirmwareUpgradeState)
typealias BSFirmwareUpgradeStateDidChangeSubject = PassthroughSubject<BSFirmwareUpgradeStateDidChangeData, Never>
public typealias BSFirmwareUpgradeStateDidChangePublisher = AnyPublisher<BSFirmwareUpgradeStateDidChangeData, Never>

@StaticLogger(disabled: true)
class BSFirmwareManager: FirmwareUpgradeDelegate, McuMgrLogDelegate {
    // MARK: - firmwareUpgradeManager

    private var firmwareUpgradeManager: FirmwareUpgradeManager? {
        didSet {
            firmwareUpgradeManager?.logDelegate = self
        }
    }

    private(set) var firmwareUpgradeState: BSFirmwareUpgradeState = .none {
        didSet {
            guard firmwareUpgradeState != oldValue else {
                logger?.log("redundant firmwareUpgradeState \(String(describing: self.firmwareUpgradeState))")
                return
            }
            firmwareUpgradeStateSubject.send(firmwareUpgradeState)
            isInProgress = firmwareUpgradeManager?.isInProgress() ?? false
            isPaused = firmwareUpgradeManager?.isPaused() ?? false
            if firmwareUpgradeState == .reset {
                isFirmwareResetting = true
            }
        }
    }

    private(set) var isInProgress: Bool = false {
        didSet {
            guard isInProgress != oldValue else {
                logger?.log("redundant isInProgress \(self.isInProgress)")
                return
            }
            logger?.log("updated isInProgress \(self.isInProgress)")
            isFirmwareInProgressSubject.send(isInProgress)
        }
    }

    private(set) var isPaused: Bool = false {
        didSet {
            guard isPaused != oldValue else {
                logger?.log("redundant isPaused \(self.isPaused)")
                return
            }
            logger?.log("updated isPaused \(self.isPaused)")
            isFirmwarePausedSubject.send(isPaused)
        }
    }

    var isFirmwareResetting: Bool = false {
        didSet {
            guard isFirmwareResetting != oldValue else {
                logger?.log("redundant isFirmwareResetting \(self.isFirmwareResetting)")
                return
            }
            logger?.log("updated isFirmwareResetting \(self.isFirmwareResetting)")
            isFirmwareResettingSubject.send(isFirmwareResetting)
        }
    }

    func onPeripheralStateUpdate(_ state: CBPeripheralState) {
        if isFirmwareResetting, state == .connected {
            isFirmwareResetting = false
        }
    }

    // MARK: - commands

    func upgradeFirmware(url: URL, peripheral: CBPeripheral) {
        guard !isInProgress else {
            logger?.debug("already upgrading")
            return
        }

        logger?.debug("updating firmware to \(url.lastPathComponent)")

        do {
            let bleTransport = McuMgrBleTransport(peripheral)
            firmwareUpgradeManager = FirmwareUpgradeManager(transport: bleTransport, delegate: self)
            // try firmwareUpgradeManager?.setUploadMtu(mtu: .init(mtu))
            let package = try McuMgrPackage(from: url)
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

    private let isFirmwareResettingSubject: PassthroughSubject<Bool, Never> = .init()
    var isFirmwareResettingPublisher: AnyPublisher<Bool, Never> {
        isFirmwareResettingSubject.eraseToAnyPublisher()
    }

    private let isFirmwareInProgressSubject: PassthroughSubject<Bool, Never> = .init()
    var isFirmwareInProgressPublisher: AnyPublisher<Bool, Never> {
        isFirmwareInProgressSubject.eraseToAnyPublisher()
    }

    private let isFirmwarePausedSubject: PassthroughSubject<Bool, Never> = .init()
    var isFirmwarePausedPublisher: AnyPublisher<Bool, Never> {
        isFirmwarePausedSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidStartSubject: PassthroughSubject<Void, Never> = .init()
    var firmwareUpgradeDidStartPublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidStartSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeStateDidChangeSubject: BSFirmwareUpgradeStateDidChangeSubject = .init()
    var firmwareUpgradeStateDidChangePublisher: BSFirmwareUpgradeStateDidChangePublisher {
        firmwareUpgradeStateDidChangeSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeStateSubject: PassthroughSubject<BSFirmwareUpgradeState, Never> = .init()
    var firmwareUpgradeStatePublisher: AnyPublisher<BSFirmwareUpgradeState, Never> {
        firmwareUpgradeStateSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidCompleteSubject: PassthroughSubject<Void, Never> = .init()
    var firmwareUpgradeDidCompletePublisher: AnyPublisher<Void, Never> {
        firmwareUpgradeDidCompleteSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidFailSubject: BSFirmwareUpgradeDidFailSubject = .init()
    var firmwareUpgradeDidFailPublisher: BSFirmwareUpgradeDidFailPublisher {
        firmwareUpgradeDidFailSubject.eraseToAnyPublisher()
    }

    private let firmwareUpgradeDidCancelSubject: PassthroughSubject<FirmwareUpgradeState, Never> = .init()
    var firmwareUpgradeDidCancelPublisher: AnyPublisher<FirmwareUpgradeState, Never> {
        firmwareUpgradeDidCancelSubject.eraseToAnyPublisher()
    }

    private let firmwareUploadProgressDidChangeSubject: BSFirmwareUploadProgressDidChangeSubject = .init()
    var firmwareUploadProgressDidChangePublisher: BSFirmwareUploadProgressDidChangePublisher {
        firmwareUploadProgressDidChangeSubject.eraseToAnyPublisher()
    }

    // MARK: - FirmwareUpgradeDelegate

    public func upgradeDidStart(controller: any FirmwareUpgradeController) {
        logger?.debug("firmware upgradeDidStart")
        firmwareUpgradeDidStartSubject.send()
    }

    public func upgradeStateDidChange(from previousState: FirmwareUpgradeState, to newState: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeStateDidChange from \(String(describing: previousState)) to \(String(describing: newState))")
        firmwareUpgradeState = newState
        firmwareUpgradeStateDidChangeSubject.send((previousState, newState))
    }

    public func upgradeDidComplete() {
        logger?.debug("firmware upgradeDidComplete")
        firmwareUpgradeDidCompleteSubject.send()
    }

    public func upgradeDidFail(inState state: FirmwareUpgradeState, with error: any Error) {
        logger?.debug("firmware upgradeDidFail inState \(String(describing: state)): \(error.localizedDescription)")
        firmwareUpgradeDidFailSubject.send((state, error))
        firmwareUpgradeState = .none
    }

    public func upgradeDidCancel(state: FirmwareUpgradeState) {
        logger?.debug("firmware upgradeDidCancel state \(String(describing: state))")
        firmwareUpgradeDidCancelSubject.send(state)
        firmwareUpgradeState = state
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
