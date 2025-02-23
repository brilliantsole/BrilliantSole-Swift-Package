//
//  BSFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog
import UkatonMacros

private let logger = getLogger(category: "BSFile", disabled: true)

public protocol BSFile {
    static var fileType: BSFileType { get }
    var fileType: BSFileType { get }
    var fileData: Data? { get set }
    var fileURL: URL? { get }
    mutating func getFileData() -> Data?
}

public extension BSFile {
    mutating func getFileData() -> Data? {
        if fileData != nil {
            return fileData
        }

        guard let fileURL else {
            logger?.error("no fileURL defined")
            return nil
        }

        do {
            let fileData = try Data(contentsOf: fileURL)
            logger?.debug("loaded file with \(fileData.count) bytes")
            self.fileData = fileData
            return fileData
        } catch {
            logger?.error("Error loading file: \(error)")
            return nil
        }
    }

    var fileType: BSFileType { Self.fileType }
}
