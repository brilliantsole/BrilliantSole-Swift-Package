//
//  BSUdpMessageType.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/7/25.
//

import UkatonMacros

@EnumName(accessLevel: "public")
enum BSUdpMessageType: UInt8, BSEnum {
    case ping
    case pong
    case setRemoteReceivePort
    case serverMessage
}
