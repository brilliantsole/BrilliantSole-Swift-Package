//
//  OSUtils.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/15/25.
//

var isWatch: Bool {
    #if os(watchOS)
    true
    #else
    false
    #endif
}

var isMacOs: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
}

var is_iOS: Bool {
    #if os(iOS)
    true
    #else
    false
    #endif
}
