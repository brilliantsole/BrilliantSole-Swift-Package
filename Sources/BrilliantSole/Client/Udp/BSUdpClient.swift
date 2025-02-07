//
//  BSUdpClient.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/6/25.
//

import Foundation
import Network
import OSLog
import UkatonMacros

public final class BSUdpClient: BSBaseClient, @unchecked Sendable {
    static let _logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "BSUdpClient")
    override var logger: Logger { Self._logger }

    override func reset() {
        super.reset()
        didSetReceivePort = false
    }

    // MARK: - udp

    var connection: NWConnection?
    var listener: NWListener?
    var reconnectTask: DispatchWorkItem?

    public var host: String = "127.0.0.1" {
        didSet {
            if connectionStatus != .notConnected {
                logger.error("cannot change host while connected")
                host = oldValue
            } else if !isValidIpAddress(host) {
                logger.error("invalid host address")
                host = oldValue
            }
        }
    }

    private func isValidIpAddress(_ ip: String) -> Bool {
        let regex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
        return ip.range(of: regex, options: .regularExpression) != nil
    }

    public var sendPort: UInt16 = 3000 {
        didSet {
            if connectionStatus != .notConnected {
                logger.error("cannot change sendPort while connected")
                sendPort = oldValue
            } else if sendPort == 0 {
                logger.error("invalid sendPort number")
                sendPort = oldValue
            }
        }
    }

    public var receivePort: UInt16 = 3001 {
        didSet {
            if connectionStatus != .notConnected {
                logger.error("cannot change receivePort while connected")
                receivePort = oldValue
            } else if receivePort == 0 {
                logger.error("invalid receivePort number")
                receivePort = oldValue
            }
            setRemoteReceivePortMessage = createSetRemoteReceivePortMessage()
        }
    }

    var didSetReceivePort: Bool = false
    func parseRemoteReceivePort(_ data: Data) {
        guard let parsedReceivePort = UInt16.parse(data, littleEndian: false) else {
            return
        }
        logger.debug("parsedReceivePort \(parsedReceivePort)")

        guard parsedReceivePort == receivePort else {
            logger.error("invalid receivePort - expected \(self.receivePort) got \(parsedReceivePort)")
            return
        }
        logger.debug("successfully set receivePort")
        didSetReceivePort = true
        connectionStatus = .connected
    }

    // MARK: - connection

    override func connect(_continue: inout Bool) {
        super.connect(_continue: &_continue)
        guard _continue else { return }

        startReceiving()
        startSending()
    }

    override func disconnect(_continue: inout Bool) {
        super.disconnect(_continue: &_continue)
        guard _continue else { return }

        connection?.cancel()
        connection = nil
        listener?.cancel()
        listener = nil
        stopPinging()
        reconnectTask?.cancel()
        reconnectTask = nil
    }

    func scheduleReconnect(delay: TimeInterval, isListener: Bool) {
        reconnectTask?.cancel()
        reconnectTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if isListener {
                logger.debug("Restarting UDP listener...")
                self.startReceiving()
            } else {
                logger.debug("Reconnecting UDP sender...")
                self.startSending()
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: reconnectTask!)
    }

    // MARK: - ping

    private var pingTimer: Timer?
    static let pingInterval: TimeInterval = 2.0
    func startPinging() {
        if pingTimer?.isValid == true {
            stopPinging()
        }
        pingTimer = .scheduledTimer(timeInterval: Self.pingInterval, target: self, selector: #selector(ping), userInfo: nil, repeats: true)
    }

    func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    static let pingMessage: BSUdpMessage = .init(type: .ping)
    lazy var setRemoteReceivePortMessage: BSUdpMessage = createSetRemoteReceivePortMessage()
    private func createSetRemoteReceivePortMessage() -> BSUdpMessage {
        .init(type: .setRemoteReceivePort, data: receivePort.getData(littleEndian: false))
    }

    @objc private func ping() {
        let message: BSUdpMessage
        if didSetReceivePort {
            logger.debug("pinging")
            message = Self.pingMessage
        } else {
            logger.debug("setting remote receive port")
            message = setRemoteReceivePortMessage
        }
        sendUdpMessages([message])
    }

    // MARK: - pong

    private var pongTimer: Timer?
    static let pongInterval: TimeInterval = 3.0
    func waitForPong() {
        if pongTimer?.isValid == true {
            stopWaitingForPong()
        }
        logger.debug("waiting for pong...")
        pongTimer = .scheduledTimer(timeInterval: Self.pongInterval, target: self, selector: #selector(pongTimeout), userInfo: nil, repeats: true)
    }

    func stopWaitingForPong() {
        logger.debug("stopWaitingForPong")
        pongTimer?.invalidate()
        pongTimer = nil
    }

    @objc private func pongTimeout() {
        logger.debug("pongTimeout")
        disconnectedUnintentionally = true
        disconnect()
    }

    static let pongMessage: BSUdpMessage = .init(type: .pong)
    func pong() {
        logger.debug("ponging")
        sendUdpMessages([Self.pongMessage])
    }

    // MARK: - messaging

    override func sendMessageData(_ data: Data, sendImmediately: Bool = true) {
        super.sendMessageData(data, sendImmediately: sendImmediately)
        let udpMessage: BSUdpMessage = .init(type: .serverMessage, data: data)
        sendUdpMessages([udpMessage], sendImmediately: sendImmediately)
    }

    private func sendUdpMessages(_ udpMessages: [BSUdpMessage], sendImmediately: Bool = true) {
        logger.debug("requesting to send \(udpMessages.count) udp messages")
    }

    private func sendUdpData(_ data: Data) {
        connection?.send(content: data, completion: .contentProcessed { [unowned self] error in
            if let error {
                logger.error("send failed: \(error)")
                return
            }
            logger.debug("sent data")
        })
    }
}
