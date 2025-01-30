//
//  BSBaseFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation
import OSLog
import UkatonMacros

@StaticLogger
public class BSBaseFile: BSFile {
    public class var fileType: BSFileType {
        fatalError("Subclasses must implement `fileType`")
    }

    public let fileName: String
    public var fileData: Data?

    public init(fileName: String) {
        self.fileName = fileName
    }
}
