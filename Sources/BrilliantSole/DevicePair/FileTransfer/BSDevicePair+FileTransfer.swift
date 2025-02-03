//
//  BSDevicePair+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

extension BSDevicePair {
    func addDeviceFileTransferListeners(device: BSDevice) {
        device.maxFileLengthPublisher.sink { [self] device, maxFileLength in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceMaxFileLengthSubject.send((self, insoleSide, device, maxFileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferStatusPublisher.sink { [self] device, fileTransferStatus in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferStatusSubject.send((self, insoleSide, device, fileTransferStatus))
        }.store(in: &deviceCancellables[device]!)

        device.fileChecksumPublisher.sink { [self] device, fileChecksum in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileChecksumSubject.send((self, insoleSide, device, fileChecksum))
        }.store(in: &deviceCancellables[device]!)

        device.fileLengthPublisher.sink { [self] device, fileLength in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileLengthSubject.send((self, insoleSide, device, fileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTypePublisher.sink { [self] device, fileType in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTypeSubject.send((self, insoleSide, device, fileType))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferProgressPublisher.sink { [self] device, fileType, fileTransferDirection, progress in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferProgressSubject.send((self, insoleSide, device, fileType, fileTransferDirection, progress))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferCompletePublisher.sink { [self] device, fileType, fileTransferDirection in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferCompleteSubject.send((self, insoleSide, device, fileType, fileTransferDirection))
        }.store(in: &deviceCancellables[device]!)

        device.fileReceivedPublisher.sink { [self] device, fileType, data in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileReceivedSubject.send((self, insoleSide, device, fileType, data))
        }.store(in: &deviceCancellables[device]!)
    }
}
