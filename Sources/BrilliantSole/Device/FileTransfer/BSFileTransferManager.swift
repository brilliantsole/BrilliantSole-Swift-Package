//
//  BSFileTransferManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

import Combine
import OSLog
import UkatonMacros

public typealias BSFileLength = UInt32

public typealias BSFileTransferData = ()

public typealias BSFileTransferProgressData = (fileType: BSFileType, fileTransferDirection: BSFileTransferDirection, progress: Float)
typealias BSFileTransferProgressSubject = PassthroughSubject<BSFileTransferProgressData, Never>
public typealias BSFileTransferProgressPublisher = AnyPublisher<BSFileTransferProgressData, Never>

public typealias BSFileTransferCompleteData = (fileType: BSFileType, fileTransferDirection: BSFileTransferDirection)
typealias BSFileTransferCompleteSubject = PassthroughSubject<BSFileTransferCompleteData, Never>
public typealias BSFileTransferCompletePublisher = AnyPublisher<BSFileTransferCompleteData, Never>

public typealias BSFileReceivedData = (fileType: BSFileType, data: Data)
typealias BSFileReceivedSubject = PassthroughSubject<BSFileReceivedData, Never>
public typealias BSFileReceivedPublisher = AnyPublisher<BSFileReceivedData, Never>

@StaticLogger(disabled: false)
final class BSFileTransferManager: BSBaseManager<BSFileTransferMessageType> {
    override class var requiredMessageTypes: [BSFileTransferMessageType]? {
        [.getMaxFileLength,
         .getFileTransferType,
         .getFileLength,
         .getFileChecksum,
         .getFileTransferStatus]
    }

    override func onRxMessage(_ messageType: BSFileTransferMessageType, data: Data) {
        switch messageType {
        case .getMaxFileLength:
            parseMaxFileLength(data)
        case .getFileTransferType, .setFileTransferType:
            parseFileTransferType(data)
        case .getFileLength, .setFileLength:
            parseFileLength(data)
        case .getFileChecksum, .setFileChecksum:
            parseChecksum(data)
        case .setFileTransferCommand:
            break
        case .getFileTransferStatus:
            parseFileTransferStatus(data)
        case .getFileTransferBlock:
            parseFileTransferBlock(data)
        case .setFileTransferBlock:
            break
        case .fileBytesTransferred:
            parseFileBytesTransferred(data)
        }
    }

    override func reset() {
        super.reset()
        maxFileLength = 0
        fileType = .tflite
        fileLength = 0
        fileChecksum = 0
        fileTransferStatus = .idle

        mtu = 0

        fileDataToReceive.removeAll(keepingCapacity: true)
        fileDataToSend = nil

        bytesTransferred = 0
        waitingToSendMoreData = false
    }

    // MARK: - maxFileLength

    private let maxFileLengthSubject: CurrentValueSubject<BSFileLength, Never> = .init(0)
    var maxFileLengthPublisher: AnyPublisher<BSFileLength, Never> {
        maxFileLengthSubject.eraseToAnyPublisher()
    }

    private(set) var maxFileLength: BSFileLength {
        get { maxFileLengthSubject.value }
        set {
            maxFileLengthSubject.value = newValue
            logger?.debug("updated maxFileLength to \(newValue)")
        }
    }

    func getMaxFileLength(sendImmediately: Bool = true) {
        logger?.debug("getting maxFileLength")
        createAndSendMessage(.getMaxFileLength, sendImmediately: sendImmediately)
    }

    private func parseMaxFileLength(_ data: Data) {
        guard let newMaxFileLength = BSFileLength.parse(data) else { return }
        logger?.debug("parsed maxFileLength \(newMaxFileLength)")
        maxFileLength = newMaxFileLength
    }

    // MARK: - fileTransferType

    private let fileTypeSubject: CurrentValueSubject<BSFileType, Never> = .init(.tflite)
    var fileTypePublisher: AnyPublisher<BSFileType, Never> {
        fileTypeSubject.eraseToAnyPublisher()
    }

    private(set) var fileType: BSFileType {
        get { fileTypeSubject.value }
        set {
            fileTypeSubject.value = newValue
            logger?.debug("updated fileType to \(newValue.name)")
        }
    }

    func getFileType(sendImmediately: Bool = true) {
        logger?.debug("getting fileTransferType")
        createAndSendMessage(.getFileTransferType, sendImmediately: sendImmediately)
    }

    private func parseFileTransferType(_ data: Data) {
        guard let newFileType = BSFileType.parse(data) else {
            return
        }
        logger?.debug("parsed fileType \(newFileType.name)")
        fileType = newFileType
    }

    func setFileTransferType(_ newFileType: BSFileType, sendImmediately: Bool = true) {
        guard fileType != newFileType else {
            logger?.debug("redundant fileType assignment \(newFileType.name)")
            return
        }
        createAndSendMessage(.setFileTransferType, data: newFileType.data, sendImmediately: sendImmediately)
    }

    // MARK: - fileLength

    private let fileLengthSubject: CurrentValueSubject<BSFileLength, Never> = .init(0)
    var fileLengthPublisher: AnyPublisher<BSFileLength, Never> {
        fileLengthSubject.eraseToAnyPublisher()
    }

    private(set) var fileLength: BSFileLength {
        get { fileLengthSubject.value }
        set {
            fileLengthSubject.value = newValue
            logger?.debug("updated fileLength to \(newValue)")
        }
    }

    func getFileLength(sendImmediately: Bool = true) {
        logger?.debug("getting fileLength")
        createAndSendMessage(.getFileLength, sendImmediately: sendImmediately)
    }

    private func parseFileLength(_ data: Data) {
        guard let newFileLength: BSFileLength = .parse(data) else { return }
        logger?.debug("parsed fileLength \(newFileLength)")
        fileLength = newFileLength
    }

    func setFileLength(_ newFileLength: BSFileLength, sendImmediately: Bool = true) {
        guard newFileLength != fileLength else {
            logger?.debug("redundant fileLength assignment \(newFileLength)")
            return
        }
        logger?.debug("setting fileLength to \(newFileLength) \(newFileLength.getData().bytes)")
        createAndSendMessage(.setFileLength, data: newFileLength.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - fileChecksum

    private let fileChecksumSubject: CurrentValueSubject<BSFileChecksum, Never> = .init(0)
    var fileChecksumPublisher: AnyPublisher<BSFileChecksum, Never> {
        fileChecksumSubject.eraseToAnyPublisher()
    }

    private(set) var fileChecksum: BSFileChecksum {
        get { fileChecksumSubject.value }
        set {
            fileChecksumSubject.value = newValue
            logger?.debug("updated checksum to \(newValue)")
        }
    }

    func getFileChecksum(sendImmediately: Bool = true) {
        logger?.debug("getting fileChecksum")
        createAndSendMessage(.getFileChecksum, sendImmediately: sendImmediately)
    }

    private func parseChecksum(_ data: Data) {
        guard let newFileChecksum = BSFileChecksum.parse(data) else { return }
        logger?.debug("parsed fileChecksum \(newFileChecksum)")
        fileChecksum = newFileChecksum
    }

    func setChecksum(_ newFileChecksum: BSFileChecksum, sendImmediately: Bool = true) {
        guard newFileChecksum != fileChecksum else {
            logger?.debug("redundant checksum assignment \(newFileChecksum)")
            return
        }
        logger?.debug("setting checksum \(newFileChecksum)")
        createAndSendMessage(.setFileChecksum, data: newFileChecksum.getData(), sendImmediately: sendImmediately)
    }

    // MARK: - fileTransferCommand

    private func setFileTransferCommand(_ fileTransferCommand: BSFileTransferCommand, sendImmediately: Bool = true) {
        logger?.debug("setting fileTransferCommand \(fileTransferCommand.name)")
        createAndSendMessage(.setFileTransferCommand, data: fileTransferCommand.data, sendImmediately: sendImmediately)
    }

    // MARK: - fileTransferStatus

    private let fileTransferStatusSubject: CurrentValueSubject<BSFileTransferStatus, Never> = .init(.idle)
    var fileTransferStatusPublisher: AnyPublisher<BSFileTransferStatus, Never> {
        fileTransferStatusSubject.eraseToAnyPublisher()
    }

    private(set) var fileTransferStatus: BSFileTransferStatus {
        get { fileTransferStatusSubject.value }
        set {
            fileTransferStatusSubject.value = newValue
            logger?.debug("updated fileTransferStatus to \(newValue.name)")

            if fileTransferStatus == .sending {
                logger?.debug("starting to send file")
                sendFileBlock(sendImmediately: false)
            }
        }
    }

    func getFileTransferStatus(sendImmediately: Bool = true) {
        logger?.debug("getting fileTransferStatus")
        createAndSendMessage(.getFileTransferStatus, sendImmediately: sendImmediately)
    }

    private func parseFileTransferStatus(_ data: Data) {
        guard let newFileTransferStatus = BSFileTransferStatus.parse(data) else {
            return
        }
        logger?.debug("parsed fileTransferStatus \(newFileTransferStatus.name)")
        fileTransferStatus = newFileTransferStatus
    }

    // MARK: - fileTransferBlock

    private func parseFileTransferBlock(_ data: Data) {
        guard fileTransferStatus == .receiving else {
            logger?.error("cannot parse fileTransferBlock when fileTransferStatus is not .receiving")
            return
        }

        let fileBlockLength = data.count
        logger?.debug("received fileBlock of length \(fileBlockLength)")

        var currentFileLength = fileDataToReceive.count
        let newFileLength = currentFileLength + fileBlockLength
        logger?.debug("updating fileLength from \(currentFileLength) to \(newFileLength)")

        guard newFileLength <= fileLength else {
            logger?.error("newFileLength \(newFileLength) is greater than fileLength \(self.fileLength) - cancelling now")
            cancelFileTransfer()
            return
        }

        fileDataToReceive.append(contentsOf: data)
        currentFileLength = fileDataToReceive.count
        let progress = Float(currentFileLength) / Float(fileLength)
        logger?.debug("fileToReceive length \(currentFileLength)/\(self.fileLength) (\(progress)%)")
        fileTransferProgressSubject.send((fileType, .receiving, progress))

        if currentFileLength == fileLength {
            logger?.debug("finished receiving file")
            let receivedFileChecksum = fileDataToReceive.crc32()
            guard receivedFileChecksum == fileChecksum else {
                logger?.error("file checksums don't match - expected \(self.fileChecksum), got \(receivedFileChecksum)")
                return
            }
            logger?.debug("file checksums match \(receivedFileChecksum)")
            fileTransferCompleteSubject.send((fileType, .receiving))
            fileReceivedSubject.send((fileType, fileDataToReceive))
        }
        else {
            createAndSendMessage(.fileBytesTransferred, data: currentFileLength.getData(), sendImmediately: true)
        }
    }

    // MARK: - fileBytesTransferred

    private var waitingToSendMoreData: Bool = false
    private var bytesTransferred: UInt16 = 0

    private func parseFileBytesTransferred(_ data: Data) {
        guard fileTransferStatus == .sending else {
            logger?.debug("currently not sending file")
            return
        }
        guard waitingToSendMoreData else {
            logger?.debug("not waiting to send more data")
            return
        }

        guard let currentBytesTransferred = UInt16.parse(data) else { return }
        logger?.debug("currentBytesTransferred: \(currentBytesTransferred)")

        guard currentBytesTransferred == bytesTransferred else {
            logger?.error("bytesTransferred not equal - got \(currentBytesTransferred), expected \(self.bytesTransferred)")
            return
        }

        logger?.debug("sending next file block")
        sendFileBlock(sendImmediately: false)
    }

    // MARK: - fileTransfer

    private let fileTransferProgressSubject: BSFileTransferProgressSubject = .init()
    var fileTransferProgressPublisher: BSFileTransferProgressPublisher {
        fileTransferProgressSubject.eraseToAnyPublisher()
    }

    private let fileTransferCompleteSubject: BSFileTransferCompleteSubject = .init()
    var fileTransferCompletePublisher: BSFileTransferCompletePublisher {
        fileTransferCompleteSubject.eraseToAnyPublisher()
    }

    private let fileReceivedSubject: BSFileReceivedSubject = .init()
    var fileReceivedPublisher: BSFileReceivedPublisher {
        fileReceivedSubject.eraseToAnyPublisher()
    }

    private var fileDataToReceive: Data = .init()
    private var fileDataToSend: Data?

    func sendFile(_ file: inout BSFile, sendImmediately: Bool = true) -> Bool {
        guard fileTransferStatus == .idle else {
            logger?.warning("cannot send file - status is \(self.fileTransferStatus.name)")
            return false
        }
        guard let fileData = file.getFileData() else {
            logger?.error("unable to get file data")
            return false
        }

        let newFileType = file.fileType
        logger?.debug("sending \(newFileType.name) file of length \(fileData.count)")

        let fileChecksum = fileData.crc32()

        if file.fileType != fileType {
            logger?.debug("different fileTypes - sending")
        }
        else if fileData.count != fileLength {
            logger?.debug("different fileLengths - sending")
        }
        else if fileChecksum != self.fileChecksum {
            logger?.debug("different fileChecksums - sending")
        }
        else {
            logger?.debug("already sent file")
            return false
        }

        fileDataToSend = fileData

        setFileTransferType(file.fileType, sendImmediately: false)
        setFileLength(BSFileLength(fileData.count), sendImmediately: false)
        setChecksum(fileChecksum, sendImmediately: false)
        setFileTransferCommand(.send, sendImmediately: sendImmediately)

        return true
    }

    var mtu: BSMtu = 0
    private var maxMessageLength: UInt16 { .init(mtu - 3 - 3) }

    private func sendFileBlock(sendImmediately: Bool = true) {
        guard fileTransferStatus == .sending else {
            logger?.error("cannot send block when fileTransferStatus is \(self.fileTransferStatus.name)")
            return
        }
        guard let fileDataToSend, !fileDataToSend.isEmpty else {
            logger?.error("no fileDataToSend")
            return
        }

        let remainingBytes = UInt16(fileDataToSend.count) - UInt16(bytesTransferred)
        logger?.debug("remainingBytes: \(remainingBytes)")

        let progress = Float(bytesTransferred) / Float(fileDataToSend.count)
        logger?.debug("progress: \(progress * 100)%")
        fileTransferProgressSubject.send((fileType, .sending, progress))

        guard remainingBytes > 0 else {
            logger?.debug("finished sending file")
            fileTransferCompleteSubject.send((fileType, .sending))
            waitingToSendMoreData = false
            return
        }
        waitingToSendMoreData = true

        let fileBlockLength = min(remainingBytes, maxMessageLength)
        logger?.debug("maxMessageLength: \(self.maxMessageLength), fileBlockLength: \(fileBlockLength)")

        let fileBlockToSend = fileDataToSend.subdata(in: Data.Index(bytesTransferred) ..< Data.Index(bytesTransferred + fileBlockLength))
        bytesTransferred += fileBlockLength
        logger?.debug("bytesTransferred: \(self.bytesTransferred)")
        createAndSendMessage(.setFileTransferBlock, data: fileBlockToSend, sendImmediately: sendImmediately)
    }

    func receiveFile(fileType: BSFileType, sendImmediately: Bool = true) {
        guard fileTransferStatus == .idle else {
            logger?.debug("cannot receive file - status \(self.fileTransferStatus.name) isn't idle")
            return
        }
        setFileTransferType(fileType, sendImmediately: false)
        setFileTransferCommand(.receive, sendImmediately: sendImmediately)
    }

    func cancelFileTransfer(sendImmediately: Bool = true) {
        guard fileTransferStatus != .idle else {
            logger?.warning("fileTransferStatus already idle - no need to cancel")
            return
        }
        logger?.debug("cancelling file transfer")
        setFileTransferCommand(.cancel, sendImmediately: sendImmediately)
    }
}
