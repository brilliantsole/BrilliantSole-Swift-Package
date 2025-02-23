//
//  BSBaseFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger(disabled: true)
public class BSBaseFile: BSFile {
    public class var fileType: BSFileType {
        fatalError("Subclasses must implement `fileType`")
    }

    public var fileURL: URL? {
        didSet {
            if fileURL != oldValue {
                logger?.log("clearing fileData due to new fileURL \(self.fileURL?.absoluteString ?? "nil")")
                fileData = nil
            }
        }
    }

    public var fileData: Data?

    init() {}

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    init(fileName: String, bundle: Bundle = .main) {
        guard let fileURL = bundle.url(forResource: fileName, withExtension: Self.fileType.fileExtension) else {
            let errorString = "file \(fileName).\(Self.fileType.fileExtension) not found"
            Self.logger?.error("\(errorString)")
            return
        }
        self.fileURL = fileURL
    }
}
