//
//  BSTxMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/19/25.
//

import Foundation

typealias BSTxMessageType = UInt8

struct BSTxMessage {
    let type: BSTxMessageType
    let data: Data?
    var typeString: String { BSTxRxMessageUtils.enumStrings[Int(type)] }

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
