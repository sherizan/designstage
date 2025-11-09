//
//  DesignStageApp.swift
//  Design Stage
//
//  A lightweight macOS menu bar app for drawing, recording, and showcasing design content.
//

import SwiftUI

@main
struct DesignStageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Menu bar app - no traditional windows
        Settings {
            EmptyView()
        }
    }
}

