//
//  BSInformationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

public typealias BSMtu = UInt16
private let defaultMtu: BSMtu = 23

@StaticLogger(disabled: true)
final class BSInformationManager: BSBaseManager<BSInformationMessageType> {
    override class var requiredMessageTypes: [BSInformationMessageType]? {
        [
            .getMtu,
            .getId,
            .getName,
            .getDeviceType,
            .getCurrentTime
        ]
    }

    override func onRxMessage(_ messageType: BSInformationMessageType, data: Data) {
        switch messageType {
        case .getMtu:
            parseMtu(data)
        case .getId:
            parseId(data)
        case .getName, .setName:
            parseName(data)
        case .getDeviceType, .setDeviceType:
            parseDeviceType(data)
        case .getCurrentTime, .setCurrentTime:
            parseCurrentTime(data)
        }
    }

    override func reset() {
        super.reset()
        mtu = defaultMtu
//        id = ""
//        name = ""
//        deviceType = .leftInsole
        _currentTime = 0
    }

    // MARK: - mtu

    private let mtuSubject = CurrentValueSubject<BSMtu, Never>(defaultMtu)
    var mtuPublisher: AnyPublisher<BSMtu, Never> { mtuSubject.eraseToAnyPublisher() }
    private(set) var mtu: UInt16 {
        get { mtuSubject.value }
        set {
            logger?.debug("updated mtu to \(newValue)")
            mtuSubject.value = newValue
        }
    }

    func getMtu(sendImmediately: Bool = true) {
        logger?.debug("getting mtu")
        createAndSendMessage(.getMtu, sendImmediately: sendImmediately)
    }

    var maxMtuMessageLength: UInt16 { max(0, mtu - 3) }

    private func parseMtu(_ data: Data) {
        guard let newMtu = UInt16.parse(data) else { return }
        logger?.debug("parsed mtu: \(newMtu)")
        mtu = newMtu
    }

    // MARK: - id

    private let idSubject = CurrentValueSubject<String, Never>("")
    var idPublisher: AnyPublisher<String, Never> { idSubject.eraseToAnyPublisher() }
    private(set) var id: String {
        get { idSubject.value }
        set {
            logger?.debug("updated id to \(newValue)")
            idSubject.value = newValue
        }
    }

    func getId(sendImmediately: Bool = true) {
        logger?.debug("getting id")
        createAndSendMessage(.getId, sendImmediately: sendImmediately)
    }

    private func parseId(_ data: Data) {
        let newId: String = .parse(data)
        logger?.debug("parsed id: \(newId)")
        id = newId
    }

    // MARK: - name

    private let nameSubject = CurrentValueSubject<String, Never>("")
    var namePublisher: AnyPublisher<String, Never> { nameSubject.eraseToAnyPublisher() }
    private(set) var name: String {
        get { nameSubject.value }
        set {
            logger?.debug("updated name to \(newValue)")
            nameSubject.value = newValue
        }
    }

    func getName(sendImmediately: Bool = true) {
        logger?.debug("getting name")
        createAndSendMessage(.getName, sendImmediately: sendImmediately)
    }

    private func parseName(_ data: Data) {
        let newName: String = .parse(data)
        logger?.debug("parsed name: \(newName)")
        name = newName
    }

    func initName(_ newName: String) {
        logger?.debug("initializing name to \(newName)")
        name = newName
    }

    func setName(_ newName: String, sendImmediately: Bool = true) {
        guard newName != name else {
            logger?.debug("redundant name assignment \(newName)")
            return
        }
        logger?.debug("setting name \(newName)")
        createAndSendMessage(.setName, data: BSStringUtils.toBytes(newName, includeLength: false), sendImmediately: sendImmediately)
    }

    // MARK: - deviceType

    private let deviceTypeSubject = CurrentValueSubject<BSDeviceType, Never>(.leftInsole)
    var deviceTypePublisher: AnyPublisher<BSDeviceType, Never> {
        deviceTypeSubject.eraseToAnyPublisher()
    }

    private(set) var deviceType: BSDeviceType {
        get { deviceTypeSubject.value }
        set {
            logger?.debug("updated deviceType to \(newValue.name)")
            deviceTypeSubject.value = newValue
        }
    }

    func getDeviceType(sendImmediately: Bool = true) {
        logger?.debug("getting deviceType")
        createAndSendMessage(.getDeviceType, sendImmediately: sendImmediately)
    }

    private func parseDeviceType(_ data: Data) {
        guard let newDeviceType = BSDeviceType.parse(data) else {
            return
        }
        logger?.debug("parsed deviceType: \(newDeviceType.name)")
        deviceType = newDeviceType
    }

    func initDeviceType(_ newDeviceType: BSDeviceType) {
        logger?.debug("initializing deviceType to \(newDeviceType.name)")
        deviceType = newDeviceType
    }

    func setDeviceType(_ newDeviceType: BSDeviceType, sendImmediately: Bool = true) {
        guard newDeviceType != deviceType else {
            logger?.debug("redundant deviceType assignment \(newDeviceType.name)")
            return
        }
        logger?.debug("setting deviceType \(newDeviceType.name)")
        createAndSendMessage(.setDeviceType, data: newDeviceType.data, sendImmediately: sendImmediately)
    }

    // MARK: - currentTime

    private let currentTimeSubject = CurrentValueSubject<BSTimestamp, Never>(0)
    var currentTimePublisher: AnyPublisher<BSTimestamp, Never> {
        currentTimeSubject.eraseToAnyPublisher()
    }

    private var _currentTime: BSTimestamp = 0
    private(set) var currentTime: BSTimestamp {
        get { _currentTime }
        set {
            logger?.debug("updated currentTime to \(newValue)")
            _currentTime = newValue
            currentTimeSubject.value = newValue
            if currentTime == 0 {
                updateCurrentTime()
            }
        }
    }

    func getCurrentTime(sendImmediately: Bool = true) {
        logger?.debug("getting currentTime")
        createAndSendMessage(.getCurrentTime, sendImmediately: sendImmediately)
    }

    private func parseCurrentTime(_ data: Data) {
        guard let newCurrentTime = BSTimestamp.parse(data) else { return }
        logger?.debug("parsed currentTime: \(newCurrentTime)")
        currentTime = newCurrentTime
    }

    private func setCurrentTime(_ newCurrentTime: BSTimestamp, sendImmediately: Bool = true) {
        guard newCurrentTime != currentTime else {
            logger?.debug("redundant currentTime assignment \(newCurrentTime)")
            return
        }
        logger?.debug("setting currentTime \(newCurrentTime)")
        createAndSendMessage(.setCurrentTime, data: newCurrentTime.getData(), sendImmediately: sendImmediately)
    }

    private func updateCurrentTime(sendImmediately: Bool = true) {
        let newCurrentTime = getUtcTime()
        logger?.debug("updating currentTime to \(newCurrentTime)")
        setCurrentTime(newCurrentTime, sendImmediately: sendImmediately)
    }
}
