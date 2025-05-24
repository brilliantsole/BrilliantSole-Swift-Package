//
//  BSDevicePair+BSSensorConfigurable.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/19/25.
//

extension BSDevicePair: BSSensorConfigurable {
    public var sensorTypes: [BSSensorType] {
        // FIX?
        let intersection = devices.values.map { Set($0.sensorTypes) }.reduce(Set(devices.values.first?.sensorTypes ?? [])) { $0.intersection($1) }
        return .init(intersection.sorted())
    }
}
