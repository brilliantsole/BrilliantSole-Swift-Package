//
//  BSCenterOfPressureProvider.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/21/25.
//

import Combine

public typealias BSCenterOfPressureDataTuple = (pressure: any BSCenterOfPressureData, timestamp: BSTimestamp)

public protocol BSCenterOfPressureDataProvider {
    var pressureDataPublisher: AnyPublisher<BSCenterOfPressureDataTuple, Never> { get }
}
