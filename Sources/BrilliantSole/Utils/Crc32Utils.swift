//
//  Crc32Utils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation
import zlib

public typealias BSFileChecksum = UInt32

extension Data {
    func crc32() -> BSFileChecksum {
        withUnsafeBytes { buffer in
            guard let pointer = buffer.baseAddress else { return 0 }
            return UInt32(zlib.crc32(0, pointer.assumingMemoryBound(to: UInt8.self), uInt(buffer.count)))
        }
    }
}
