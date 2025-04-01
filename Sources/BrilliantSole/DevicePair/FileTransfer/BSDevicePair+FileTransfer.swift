//
//  BSDevicePair+FileTransfer.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/1/25.
//

extension BSDevicePair {
    func addDeviceFileTransferListeners(device: BSDevice) {
        device.maxFileLengthPublisher.sink { [self] maxFileLength in
            guard let side = self.getDeviceSide(device) else { return }
            deviceMaxFileLengthSubject.send((side, device, maxFileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferStatusPublisher.sink { [self] fileTransferStatus in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileTransferStatusSubject.send((side, device, fileTransferStatus))
        }.store(in: &deviceCancellables[device]!)

        device.fileChecksumPublisher.sink { [self] fileChecksum in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileChecksumSubject.send((side, device, fileChecksum))
        }.store(in: &deviceCancellables[device]!)

        device.fileLengthPublisher.sink { [self] fileLength in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileLengthSubject.send((side, device, fileLength))
        }.store(in: &deviceCancellables[device]!)

        device.fileTypePublisher.sink { [self] fileType in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileTypeSubject.send((side, device, fileType))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferProgressPublisher.sink { [self] fileType, fileTransferDirection, progress in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileTransferProgressSubject.send((side, device, fileType, fileTransferDirection, progress))
        }.store(in: &deviceCancellables[device]!)

        device.fileTransferCompletePublisher.sink { [self] fileType, fileTransferDirection in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileTransferCompleteSubject.send((side, device, fileType, fileTransferDirection))
        }.store(in: &deviceCancellables[device]!)

        device.fileReceivedPublisher.sink { [self] fileType, data in
            guard let side = self.getDeviceSide(device) else { return }
            deviceFileReceivedSubject.send((side, device, fileType, data))
        }.store(in: &deviceCancellables[device]!)
    }
}
