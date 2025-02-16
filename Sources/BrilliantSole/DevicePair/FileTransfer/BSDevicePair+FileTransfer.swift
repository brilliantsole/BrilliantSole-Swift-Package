//
//  BSDevicePair+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

extension BSDevicePair {
    func addDeviceFileTransferListeners(device: BSDevice) {
        device.maxFileLengthPublisher.sink { [self] maxFileLength in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceMaxFileLengthSubject.send((insoleSide, device, maxFileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferStatusPublisher.sink { [self] fileTransferStatus in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferStatusSubject.send((insoleSide, device, fileTransferStatus))
        }.store(in: &deviceCancellables[device]!)

        device.fileChecksumPublisher.sink { [self] fileChecksum in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileChecksumSubject.send((insoleSide, device, fileChecksum))
        }.store(in: &deviceCancellables[device]!)

        device.fileLengthPublisher.sink { [self] fileLength in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileLengthSubject.send((insoleSide, device, fileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTypePublisher.sink { [self] fileType in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTypeSubject.send((insoleSide, device, fileType))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferProgressPublisher.sink { [self] fileType, fileTransferDirection, progress in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferProgressSubject.send((insoleSide, device, fileType, fileTransferDirection, progress))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferCompletePublisher.sink { [self] fileType, fileTransferDirection in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileTransferCompleteSubject.send((insoleSide, device, fileType, fileTransferDirection))
        }.store(in: &deviceCancellables[device]!)

        device.fileReceivedPublisher.sink { [self] fileType, data in
            guard let insoleSide = self.getDeviceInsoleSide(device) else { return }
            deviceFileReceivedSubject.send((insoleSide, device, fileType, data))
        }.store(in: &deviceCancellables[device]!)
    }
}
