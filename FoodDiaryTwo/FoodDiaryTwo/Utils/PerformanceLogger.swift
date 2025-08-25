//
//  PerformanceLogger.swift
//  FoodDiaryTwo
//
//  Lightweight perf logging utilities
//

import Foundation
import os

enum PerformanceLogger {
    private static let log = OSLog(subsystem: "com.fooddiarytwo.app", category: "performance")
    private static var marks: [String: DispatchTime] = [:]
    
    static func begin(_ name: String) {
        marks[name] = DispatchTime.now()
        os_log("BEGIN %{public}@", log: log, type: .info, name)
    }
    
    static func end(_ name: String) {
        guard let start = marks[name] else { return }
        let end = DispatchTime.now()
        let nanos = end.uptimeNanoseconds - start.uptimeNanoseconds
        let ms = Double(nanos) / 1_000_000.0
        os_log("END %{public}@ -> %{public}.2f ms", log: log, type: .info, name, ms)
        marks.removeValue(forKey: name)
    }
}


