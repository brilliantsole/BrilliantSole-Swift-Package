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
class BSBaseFile: BSFile {
    class var fileType: BSFileType {
        fatalError("Subclasses must implement `fileType`")
    }

    let fileName: String
    var fileData: Data?

    init(fileName: String) {
        self.fileName = fileName
    }
}
