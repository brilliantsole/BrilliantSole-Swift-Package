//
//  BSUdpClient+Messaging.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/7/25.
//

import Foundation
import Network

extension BSUdpClient {
    // MARK: - sending

    func startSending() {
        let hostNW = NWEndpoint.Host(ipAddress)
        let portNW = NWEndpoint.Port(rawValue: sendPort)!

        connection = NWConnection(host: hostNW, port: portNW, using: .udp)
        connection?.stateUpdateHandler = { [weak self] newState in
            guard let self = self else { return }
            logger?.debug("newState \(String(describing: newState))")
            switch newState {
            case .ready:
                logger?.debug("connected to \(self.ipAddress):\(self.sendPort)")
                self.startPinging()
            case .failed(let error):
                logger?.error("Connection failed: \(error), retrying...")
                self.scheduleReconnect(delay: 2.0, isListener: false)
            case .preparing:
                break
            default:
                logger?.debug("uncaught newState \(String(describing: newState))")
            }
        }
        connection?.start(queue: .global())
    }

    // MARK: - receiving

    func startReceiving() {
        do {
            let port = NWEndpoint.Port(rawValue: receivePort)!
            listener = try NWListener(using: .udp, on: port)

            listener?.newConnectionHandler = { [weak self] connection in
                connection.start(queue: .global())
                self?.receiveMessage(connection)
            }

            listener?.stateUpdateHandler = { [weak self] state in
                guard let self = self else { return }
                if case .failed(let error) = state {
                    logger?.error("Listener failed: \(error), restarting...")
                    self.scheduleReconnect(delay: 2.0, isListener: true)
                }
            }

            listener?.start(queue: .global())
            logger?.debug("Listening on port \(self.receivePort)")
        } catch {
            logger?.error("Failed to start UDP listener: \(error)")
            scheduleReconnect(delay: 2.0, isListener: true)
        }
    }

    func scheduleReconnect(delay: TimeInterval, isListener: Bool) {
        reconnectTask?.cancel()
        reconnectTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if isListener {
                logger?.debug("Restarting UDP listener...")
                self.startReceiving()
            } else {
                logger?.debug("Reconnecting UDP sender...")
                self.startSending()
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + delay, execute: reconnectTask!)
    }

    private func receiveMessage(_ connection: NWConnection) {
        connection.receiveMessage { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let data, isComplete {
                onUdpData(data)
            }
            if let error {
                logger?.error("Receive error: \(error)")
            }
            self.receiveMessage(connection)
        }
    }

    private func onUdpData(_ data: Data) {
        logger?.debug("received udpData (\(data.count) bytes)")
        stopWaitingForPong()
        parseMessages(data) { udpMessageType, udpMessageData in
            self.onUdpMessage(type: udpMessageType, data: udpMessageData)
        }
        sendPendingMessages()
        sendPendingUdpMessages()
        if isConnected {
            waitForPong()
        }
    }

    private func onUdpMessage(type: BSUdpMessageType, data: Data) {
        logger?.debug("received udpMessage \(type.name) (\(data.count) bytes)")
        switch type {
        case .ping:
            pong()
        case .pong:
            break
        case .setRemoteReceivePort:
            parseRemoteReceivePort(data)
        case .serverMessage:
            parseServerData(data)
        }
    }
}
