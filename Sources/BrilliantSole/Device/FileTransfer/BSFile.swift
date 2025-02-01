//
//  BSFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog
import UkatonMacros

private let logger = getLogger(category: "BSFile")

public protocol BSFile {
    static var fileType: BSFileType { get }
    var fileType: BSFileType { get }
    var fileName: String { get }
    var fileData: Data? { get set }
    var bundle: Bundle { get }
    mutating func getFileData() -> Data?
}

public extension BSFile {
    mutating func getFileData() -> Data? {
        if fileData != nil {
            return fileData
        }

        guard let fileURL = bundle.url(forResource: fileName, withExtension: Self.fileType.fileExtension) else {
            let errorString = "file \(fileName).\(Self.fileType.fileExtension) not found"
            logger.error("\(errorString)")
            return nil
        }

        do {
            let fileData = try Data(contentsOf: fileURL)
            print("loaded file with \(fileData.count) bytes")
            self.fileData = fileData
            return fileData
        } catch {
            logger.error("Error loading file: \(error)")
            return nil
        }
    }

    var fileType: BSFileType { Self.fileType }
}
