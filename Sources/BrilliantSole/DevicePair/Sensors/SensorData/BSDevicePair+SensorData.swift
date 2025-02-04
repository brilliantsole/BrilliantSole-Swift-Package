//
//  BSDevicePair+SensorDataManager.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 2/3/25.
//

extension BSDevicePair {
    func setupSensorDataManager() {
        sensorDataManager.pressureSensorDataManager.pressureDataPublisher.sink { pressureData, timestamp in
            self.pressureDataSubject.send((self, pressureData, timestamp))
        }.store(in: &cancellables)
    }
}
