//
//  BSConnectionMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/5/25.
//

import Foundation

typealias _BSConnectionMessageType = UInt8

struct BSConnectionMessage {
    let type: _BSConnectionMessageType
    let data: Data?
    var typeString: String { BSConnectionMessageUtils.enumStrings[Int(type)] }

    init(type: UInt8, data: Data? = nil) {
        self.type = type
        self.data = data
    }

    func length() -> UInt16 {
        return UInt16(3 + dataLength())
    }

    func dataLength() -> UInt16 {
        return UInt16(data?.count ?? 0)
    }

    func appendTo(_ _data: inout Data) {
        _data.append(type)

        let dataLength = self.dataLength()
        _data.append(dataLength.getData(littleEndian: true))
        if dataLength > 0, let data = data {
            _data += data
        }
    }
}
