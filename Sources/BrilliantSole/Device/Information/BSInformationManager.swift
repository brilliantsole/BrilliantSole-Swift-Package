//
//  BSInformationManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

@StaticLogger
class BSInformationManager: BSBaseManager<BSInformationMessageType> {
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
        mtu = 0
//        id = ""
//        name = ""
//        deviceType = .leftInsole
        currentTime = 0
    }

    // MARK: - mtu

    var mtuSubject = CurrentValueSubject<UInt16, Never>(0)
    var mtu: UInt16 {
        get { mtuSubject.value }
        set {
            mtuSubject.value = newValue
            logger.debug("updated mtu to \(newValue)")
        }
    }

    var maxMtuMessageLength: UInt16 { max(0, mtu - 3) }

    func parseMtu(_ data: Data) {
        let newMtu: UInt16 = .parse(data)
        logger.debug("parsed mtu: \(newMtu)")
        mtu = newMtu
    }

    // MARK: - id

    var idSubject = CurrentValueSubject<String, Never>("")
    private(set) var id: String {
        get { idSubject.value }
        set {
            idSubject.value = newValue
            logger.debug("updated id to \(newValue)")
        }
    }

    func parseId(_ data: Data) {
        let newId: String = .parse(data)
        logger.debug("parsed id: \(newId)")
        id = newId
    }

    // MARK: - name

    var nameSubject = CurrentValueSubject<String, Never>("")
    private(set) var name: String {
        get { nameSubject.value }
        set {
            nameSubject.value = newValue
            logger.debug("updated name to \(newValue)")
        }
    }

    func parseName(_ data: Data) {
        let newName: String = .parse(data)
        logger.debug("parsed name: \(newName)")
        name = newName
    }

    func initName(_ newName: String) {
        logger.debug("initializing name to \(newName)")
        name = newName
    }

    // MARK: - deviceType

    var deviceTypeSubject = CurrentValueSubject<BSDeviceType, Never>(.leftInsole)
    private(set) var deviceType: BSDeviceType {
        get { deviceTypeSubject.value }
        set {
            deviceTypeSubject.value = newValue
            logger.debug("updated deviceType to \(newValue.name)")
        }
    }

    func parseDeviceType(_ data: Data) {
        let rawDeviceType = data[0]
        guard let newDeviceType: BSDeviceType = .init(rawValue: rawDeviceType) else {
            logger.error("invalid raw deviceType \(rawDeviceType)")
            return
        }
        logger.debug("parsed deviceType: \(newDeviceType.name)")
        deviceType = newDeviceType
    }

    // MARK: - currentTime

    var currentTimeSubject = CurrentValueSubject<UInt32, Never>(0)
    private(set) var currentTime: UInt32 {
        get { currentTimeSubject.value }
        set {
            currentTimeSubject.value = newValue
            logger.debug("updated currentTime to \(newValue)")
            if currentTime == 0 {
                updateCurrentTime()
            }
        }
    }

    func parseCurrentTime(_ data: Data) {
        let newCurrentTime: UInt32 = .parse(data)
        logger.debug("parsed currentTime: \(newCurrentTime)")
        currentTime = newCurrentTime
    }

    func updateCurrentTime() {
        let newCurrentTime = getUtcTime()
        logger.debug("updating currentTime to \(newCurrentTime)...")
        let messages = createMessage(.setCurrentTime, data: newCurrentTime.data())
        sendTxMessages!([messages], false)
    }
}
