//
//  BSEnum.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/22/25.
//

protocol BSEnum: RawRepresentable, CaseIterable, Sendable, Hashable where RawValue == UInt8 {
    var name: String { get }
}
