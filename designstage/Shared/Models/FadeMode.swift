//
//  FadeMode.swift
//  Design Stage
//
//  Fade ink duration presets.
//

import Foundation

enum FadeMode: Int, CaseIterable {
    case off = 0
    case threeSeconds = 3
    case fiveSeconds = 5
    case tenSeconds = 10
    case twentySeconds = 20
    
    var displayName: String {
        switch self {
        case .off: return "Off"
        case .threeSeconds: return "3 seconds"
        case .fiveSeconds: return "5 seconds"
        case .tenSeconds: return "10 seconds"
        case .twentySeconds: return "20 seconds"
        }
    }
    
    var duration: TimeInterval {
        return TimeInterval(self.rawValue)
    }
}

