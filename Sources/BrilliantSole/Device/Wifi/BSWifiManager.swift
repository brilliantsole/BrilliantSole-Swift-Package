//
//  BSWifiManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
final class BSWifiManager: BSBaseManager<BSWifiMessageType> {
    override class var requiredMessageTypes: [BSWifiMessageType]? {
        [
            .isWifiAvailable
        ]
    }

    override class var requiredFollowUpMessageTypes: [BSWifiMessageType]? {
        [
            .getWifiSSID,
            .getWifiPassword,
            .getWifiConnectionEnabled,
            .isWifiConnected,
            .ipAddress,
            .isWifiSecure
        ]
    }

    override func onRxMessage(_ messageType: BSWifiMessageType, data: Data) {
        switch messageType {
            case .isWifiAvailable:
                parseIsWifiAvailable(data)
            case .getWifiSSID, .setWifiSSID:
                parseWifiSSID(data)
            case .getWifiPassword, .setWifiPassword:
                parseWifiPassword(data)
            case .getWifiConnectionEnabled, .setWifiConnectionEnabled:
                parseWifiConnectionEnabled(data)
            case .isWifiConnected:
                parseIsWifiConnected(data)
            case .ipAddress:
                parseIpAddress(data)
            case .isWifiSecure:
                parseIsWifiSecure(data)
        }
    }

    override func reset() {
        super.reset()
        isWifiAvailable = false
        wifiSSID = ""
        wifiPassword = ""
        wifiConnectionEnabled = false
        isWifiConnected = false
        ipAddress = nil
        isWifiSecure = false
    }

    // MARK: - isWifiAvailable

    private let isWifiAvailableSubject = CurrentValueSubject<Bool, Never>(false)
    var isWifiAvailablePublisher: AnyPublisher<Bool, Never> {
        isWifiAvailableSubject.eraseToAnyPublisher()
    }

    private(set) var isWifiAvailable: Bool {
        get { isWifiAvailableSubject.value }
        set {
            logger?.debug("updated isWifiAvailable to \(newValue)")
            isWifiAvailableSubject.value = newValue
        }
    }

    func getIsWifiAvailable(sendImmediately: Bool = true) {
        logger?.debug("getting isWifiAvailable")
        createAndSendMessage(.isWifiAvailable, sendImmediately: sendImmediately)
    }

    private func parseIsWifiAvailable(_ data: Data) {
        guard let newIsWifiAvailable = Bool.parse(data) else {
            return
        }
        logger?.debug("parsed isWifiAvailable: \(newIsWifiAvailable)")
        isWifiAvailable = newIsWifiAvailable
    }

    // MARK: - wifiSSID

    private let wifiSSIDSubject = CurrentValueSubject<String, Never>("")
    var wifiSSIDPublisher: AnyPublisher<String, Never> {
        wifiSSIDSubject.eraseToAnyPublisher()
    }

    private(set) var wifiSSID: String {
        get { wifiSSIDSubject.value }
        set {
            logger?.debug("updated wifiSSID to \(newValue)")
            wifiSSIDSubject.value = newValue
        }
    }

    func getWifiSSID(sendImmediately: Bool = true) {
        logger?.debug("getting wifiSSID")
        createAndSendMessage(.getWifiSSID, sendImmediately: sendImmediately)
    }

    private func parseWifiSSID(_ data: Data) {
        let newWifiSSID: String = .parse(data)
        logger?.debug("parsed wifiSSID: \(newWifiSSID)")
        wifiSSID = newWifiSSID
    }

    func setWifiSSID(_ newWifiSSID: String, sendImmediately: Bool = true) {
        guard newWifiSSID != wifiSSID else {
            logger?.debug("redundant wifiSSID assignment \(newWifiSSID)")
            return
        }
        logger?.debug("setting wifiSSID \(newWifiSSID)")
        createAndSendMessage(.setWifiSSID, data: BSStringUtils.toBytes(newWifiSSID, includeLength: false), sendImmediately: sendImmediately)
    }

    // MARK: - wifiPassword

    private let wifiPasswordSubject = CurrentValueSubject<String, Never>("")
    var wifiPasswordPublisher: AnyPublisher<String, Never> {
        wifiPasswordSubject.eraseToAnyPublisher()
    }

    private(set) var wifiPassword: String {
        get { wifiPasswordSubject.value }
        set {
            logger?.debug("updated wifiPassword to \(newValue)")
            wifiPasswordSubject.value = newValue
        }
    }

    func getWifiPassword(sendImmediately: Bool = true) {
        logger?.debug("getting wifiPassword")
        createAndSendMessage(.getWifiPassword, sendImmediately: sendImmediately)
    }

    private func parseWifiPassword(_ data: Data) {
        let newWifiPassword: String = .parse(data)
        logger?.debug("parsed wifiPassword: \(newWifiPassword)")
        wifiPassword = newWifiPassword
    }

    func setWifiPassword(_ newWifiPassword: String, sendImmediately: Bool = true) {
        guard newWifiPassword != wifiPassword else {
            logger?.debug("redundant wifiPassword assignment \(newWifiPassword)")
            return
        }
        logger?.debug("setting wifiPassword \(newWifiPassword)")
        createAndSendMessage(.setWifiPassword, data: BSStringUtils.toBytes(newWifiPassword, includeLength: false), sendImmediately: sendImmediately)
    }

    // MARK: - wifiConnectionEnabled

    private let wifiConnectionEnabledSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var wifiConnectionEnabledPublisher: AnyPublisher<Bool, Never> {
        wifiConnectionEnabledSubject.eraseToAnyPublisher()
    }

    private(set) var wifiConnectionEnabled: Bool {
        get { wifiConnectionEnabledSubject.value }
        set {
            logger?.debug("updated wifiConnectionEnabled to \(newValue)")
            wifiConnectionEnabledSubject.value = newValue
        }
    }

    func getWifiConnectionEnabled(sendImmediately: Bool = true) {
        logger?.debug("getting wifiConnectionEnabled")
        createAndSendMessage(.getWifiConnectionEnabled, sendImmediately: sendImmediately)
    }

    private func parseWifiConnectionEnabled(_ data: Data) {
        guard let newWifiConnectionEnabled = Bool.parse(data) else { return }
        logger?.debug("parsed wifiConnectionEnabled: \(newWifiConnectionEnabled)")
        wifiConnectionEnabled = newWifiConnectionEnabled
    }

    func setWifiConnectionEnabled(_ newWifiConnectionEnabled: Bool, sendImmediately: Bool = true) {
        guard newWifiConnectionEnabled != wifiConnectionEnabled else {
            logger?.debug("redundant wifiConnectionEnabled assignment \(newWifiConnectionEnabled)")
            return
        }
        guard isWifiAvailable else {
            logger?.error("wifi is not available")
            return
        }
        logger?.debug("setting wifiConnectionEnabled to \(newWifiConnectionEnabled)")
        createAndSendMessage(.setWifiConnectionEnabled, data: newWifiConnectionEnabled.data, sendImmediately: sendImmediately)
    }

    func enableWifiConnection(sendImmediately: Bool = true) {
        setWifiConnectionEnabled(true, sendImmediately: sendImmediately)
    }

    func disableWifiConnection(sendImmediately: Bool = true) {
        setWifiConnectionEnabled(false, sendImmediately: sendImmediately)
    }

    func toggleWifiConnection(sendImmediately: Bool = true) {
        setWifiConnectionEnabled(!wifiConnectionEnabled, sendImmediately: sendImmediately)
    }

    // MARK: - isWifiConnected

    private let isWifiConnectedSubject = CurrentValueSubject<Bool, Never>(false)
    var isWifiConnectedPublisher: AnyPublisher<Bool, Never> {
        isWifiConnectedSubject.eraseToAnyPublisher()
    }

    private(set) var isWifiConnected: Bool {
        get { isWifiConnectedSubject.value }
        set {
            logger?.debug("updated isWifiConnected to \(newValue)")
            isWifiConnectedSubject.value = newValue
        }
    }

    func getIsWifiConnected(sendImmediately: Bool = true) {
        logger?.debug("getting isWifiConnected")
        createAndSendMessage(.isWifiConnected, sendImmediately: sendImmediately)
    }

    private func parseIsWifiConnected(_ data: Data) {
        guard let newIsWifiConnected = Bool.parse(data) else {
            return
        }
        logger?.debug("parsed isWifiConnected: \(newIsWifiConnected)")
        isWifiConnected = newIsWifiConnected
    }

    // MARK: - ipAddress

    private let ipAddressSubject = CurrentValueSubject<String?, Never>(nil)
    var ipAddressPublisher: AnyPublisher<String?, Never> {
        ipAddressSubject.eraseToAnyPublisher()
    }

    private(set) var ipAddress: String? {
        get { ipAddressSubject.value }
        set {
            logger?.debug("updated ipAddress to \(newValue ?? "nil")")
            ipAddressSubject.value = newValue
        }
    }

    func getIpAddress(sendImmediately: Bool = true) {
        logger?.debug("getting ipAddress")
        createAndSendMessage(.ipAddress, sendImmediately: sendImmediately)
    }

    private func parseIpAddress(_ data: Data) {
        var newIpAddress: String?
        if data.bytes.count == 4 {
            newIpAddress = data.bytes.map { String($0) }.joined(separator: ".")
        }
        logger?.debug("parsed ipAddress: \(newIpAddress ?? "nil")")
        ipAddress = newIpAddress
    }

    // MARK: - isWifiSecure

    private let isWifiSecureSubject = CurrentValueSubject<Bool, Never>(false)
    var isWifiSecurePublisher: AnyPublisher<Bool, Never> {
        isWifiSecureSubject.eraseToAnyPublisher()
    }

    private(set) var isWifiSecure: Bool {
        get { isWifiSecureSubject.value }
        set {
            logger?.debug("updated isWifiSecure to \(newValue)")
            isWifiSecureSubject.value = newValue
        }
    }

    func getIsWifiSecure(sendImmediately: Bool = true) {
        logger?.debug("getting isWifiSecure")
        createAndSendMessage(.isWifiSecure, sendImmediately: sendImmediately)
    }

    private func parseIsWifiSecure(_ data: Data) {
        guard let newIsWifiSecure = Bool.parse(data) else {
            return
        }
        logger?.debug("parsed isWifiSecure: \(newIsWifiSecure)")
        isWifiSecure = newIsWifiSecure
    }
}
