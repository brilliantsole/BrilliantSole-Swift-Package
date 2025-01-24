//
//  BSTimeUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/23/25.
//

import Foundation
import OSLog

private let logger = getLogger(category: "BSTimeUtils")

func getUtcTime() -> UInt64 {
    .init(Date().timeIntervalSince1970 * 1000)
}

private let timestampThreshold: UInt16 = 60_000

func parseTimestamp(_ data: Data, at offset: inout Data.Index) -> UInt64 {
    let currentTime = getUtcTime()
    logger.debug("currentTime: \(currentTime)ms")
    offset += 2

    let rawTimestamp: UInt16 = .parse(data, at: offset)
    logger.debug("rawTimestamp: \(rawTimestamp)ms")

    var timestamp: UInt64 = currentTime - (currentTime % (UInt64(UInt16.max) + 1))
    logger.debug("truncated timestamp: \(timestamp)ms")
    timestamp += UInt64(rawTimestamp)
    logger.debug("full timestamp: \(timestamp)ms")

    let timestampDifference = currentTime > timestamp ? currentTime - timestamp : timestamp - currentTime
    logger.debug("timestampDifference: \(timestampDifference)ms")
    if timestampDifference > timestampThreshold {
        logger.debug("correcting timestamp overflow")
        timestamp += UInt64(UInt16.max) * (currentTime - timestamp).signum()
    }

    logger.debug("timestamp: \(timestamp)ms")
    return timestamp
}
