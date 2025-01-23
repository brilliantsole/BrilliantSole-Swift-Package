//
//  BSTimeUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation

func getUtcTime() -> UInt64 {
    .init(Date().timeIntervalSince1970 * 1000)
}
