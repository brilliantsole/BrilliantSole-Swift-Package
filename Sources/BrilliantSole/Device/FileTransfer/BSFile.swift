//
//  BSFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import OSLog
import UkatonMacros

private let logger = getLogger(category: "BSFile")

protocol BSFile {
    static var fileType: BSFileType { get }
    var fileName: String { get }
    var fileData: Data? { get set }
    mutating func getFileData(bundle: Bundle) -> Data?
}

extension BSFile {
    mutating func getFileData(bundle: Bundle = .main) -> Data? {
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
}
