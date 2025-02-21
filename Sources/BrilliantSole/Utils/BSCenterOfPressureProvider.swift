//
//  BSCenterOfPressureProvider.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/21/25.
//

import Combine

public typealias BSCenterOfPressureTuple = (centerOfPressure: BSCenterOfPressure, normalizedCenterOfPressure: BSCenterOfPressure, timestamp: BSTimestamp)
typealias BSCenterOfPressureSubject = PassthroughSubject<BSCenterOfPressureTuple, Never>
public typealias BSCenterOfPressurePublisher = AnyPublisher<BSCenterOfPressureTuple, Never>

public protocol BSCenterOfPressureProvider {
    var centerOfPressurePublisher: BSCenterOfPressurePublisher { get }
    func resetPressure()
}
