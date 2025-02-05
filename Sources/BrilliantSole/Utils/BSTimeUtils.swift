//
//  BSTimeUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSTimeUtils")

public typealias BSTimestamp = UInt64

func getUtcTime() -> BSTimestamp {
    .init(Date().timeIntervalSince1970 * 1000)
}

private let timestampThreshold: UInt16 = 60_000

func parseTimestamp(_ data: Data, at offset: inout Data.Index) -> BSTimestamp? {
    let currentTime = getUtcTime()
    logger.debug("currentTime: \(currentTime)ms")

    guard let rawTimestamp = UInt16.parse(data, at: offset) else {
        return nil
    }
    logger.debug("rawTimestamp: \(rawTimestamp)ms")
    offset += 2

    var timestamp: BSTimestamp = currentTime - (currentTime % (BSTimestamp(UInt16.max) + 1))
    logger.debug("truncated timestamp: \(timestamp)ms")
    timestamp += BSTimestamp(rawTimestamp)
    logger.debug("full timestamp: \(timestamp)ms")

    let timestampDifference = currentTime > timestamp ? currentTime - timestamp : timestamp - currentTime
    logger.debug("timestampDifference: \(timestampDifference)ms")
    if timestampDifference > timestampThreshold {
        logger.debug("correcting timestamp overflow")
        let timestampCorrection = Int(UInt16.max) * (Int(currentTime) - Int(timestamp)).signum()
        timestamp = BSTimestamp(clamping: Int(timestamp) + timestampCorrection)
    }

    logger.debug("timestamp: \(timestamp)ms")
    return timestamp
}
