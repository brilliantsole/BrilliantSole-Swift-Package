//
//  Crc32Utils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation
import zlib

extension Data {
    func crc32() -> UInt32 {
        withUnsafeBytes { buffer in
            guard let pointer = buffer.baseAddress else { return 0 }
            return UInt32(zlib.crc32(0, pointer.assumingMemoryBound(to: UInt8.self), uInt(buffer.count)))
        }
    }
}
