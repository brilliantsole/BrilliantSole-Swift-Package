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

    public let fileName: String
    public let bundle: Bundle

    public var fileData: Data?

    public init(fileName: String, bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }
}
