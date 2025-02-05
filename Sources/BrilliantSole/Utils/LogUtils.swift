//
//  LogUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/20/25.
//

import OSLog

func getLogger(category: String) -> Logger {
    Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
}
