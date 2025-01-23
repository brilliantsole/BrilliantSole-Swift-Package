//
//  BSMessage.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

import Foundation

struct BSMessage<MessageType: RawRepresentable> where MessageType.RawValue == UInt8 {
    let type: MessageType
    let data: Data?

    init(type: MessageType, data: Data? = nil) {
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
        _data.append(type.rawValue)

        let dataLength = self.dataLength()
        _data.append(dataLength.getData(littleEndian: true))
        if dataLength > 0, let data = data {
            _data += data
        }
    }
}
