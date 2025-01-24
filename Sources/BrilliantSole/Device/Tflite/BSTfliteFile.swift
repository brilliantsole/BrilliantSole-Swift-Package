//
//  BSTfliteFile.swift
//  BrilliantSole
//
//  Created by Zack Qattan on 1/21/25.
//

class BSTfliteFile: BSBaseFile {
    override class var fileType: BSFileType { .tflite }

    let modelName: String
    let sensorTypes: Set<BSTfliteSensorType>
    func getSensorTypes() -> Set<BSSensorType> {
        .init(sensorTypes.map { $0.sensorType })
    }

    let task: BSTfliteTask
    let sensorRate: BSSensorRate

    static let maxCaptureDelay: UInt16 = 5000
    var captureDelay: UInt16 {
        didSet {
            captureDelay = min(captureDelay, Self.maxCaptureDelay)
        }
    }

    static let maxThreshold: Float = 1.0
    var threshold: Float {
        didSet {
            threshold = min(threshold, Self.maxThreshold)
        }
    }

    let classes: [String]?

    init(fileName: String, modelName: String, sensorTypes: Set<BSTfliteSensorType>, task: BSTfliteTask, sensorRate: BSSensorRate, captureDelay: UInt16 = 0, threshold: Float = 0.0, classes: [String]?) {
        self.modelName = modelName
        self.sensorTypes = sensorTypes
        self.task = task
        self.sensorRate = sensorRate
        self.captureDelay = captureDelay
        self.threshold = threshold
        self.classes = classes

        super.init(fileName: fileName)
    }
}
