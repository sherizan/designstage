🧠 Product Name

Design Stage — a lightweight macOS menu bar app that lets creators draw, highlight, record, and showcase design or screen content beautifully during meetings, demos, or recordings.

🎯 Goal

Help designers and presenters visually explain ideas faster by providing a smart overlay, fade ink drawing, recordable canvas, and preset device frames — all in one minimal utility.

🪄 Core Features
Feature	Description	Shortcut
✏️ Draw Anywhere	On-screen freehand drawing overlay	⌘⇧D
🧹 Clear Ink	Wipe drawings instantly	⌘⇧C
🌈 Color & Width Picker	Simple preset palette (menu or hotkey)	⌘1–5
🔥 Fade Ink	Strokes auto-fade after 5–20s	⌘⇧F
🎥 Screen Recorder	Select screen area and record to .mov or .gif	⌘⇧R
📱 Device Frames & Backgrounds	Add preset areas (iPhone, iPad, 1080p, 4K) with optional background/blurs	Menu: “Frame Presets”
💾 Export Snapshot	Capture current screen + scribbles	⌘⇧S
🧩 Detailed Behavior
🖋️ Fade Ink

Each stroke has a birthTime and fades smoothly (easeOutQuad) until invisible.

Configurable durations: Off / 5s / 10s / 20s.

Cleans the screen automatically — perfect for live demos.

🎥 Recording

User drags to select a region → starts capture.

Export to .mov via AVFoundation or .gif via ImageIO.

Option to include overlay drawings in final output.

Shows “REC” dot in menu bar; auto-stop after 2 min if forgotten.

🖼️ Preset Frames

Menu > Frame Preset

iPhone 15 Pro (1179×2556)

iPad Pro 11” (1668×2388)

1080p / 1440p / 4K

Custom Size

Frames appear as centered floating windows.

Background options:

Solid color

Image picker

Live blur of desktop

🧰 Architecture Overview
DesignStage/
 ├─ AppDelegate.swift
 ├─ StatusItemController.swift
 ├─ OverlayWindowController.swift
 ├─ DrawingView.swift
 ├─ HotkeyManager.swift
 ├─ FadeEngine.swift
 ├─ Recorder/
 │   ├─ RegionSelector.swift
 │   ├─ ScreenRecorder.swift
 │   └─ GifEncoder.swift
 ├─ Presets/
 │   ├─ PresetManager.swift
 │   └─ FrameWindowController.swift
 └─ Assets.xcassets

 ⚙️ Technical Highlights

Language: Swift

Frameworks: AppKit, AVFoundation, ImageIO, QuartzCore

Target: macOS 13+

Overlay: Transparent NSPanel on .screenSaver level

Recording: CGWindowListCreateImage + AVAssetWriter for MOV

GIF: CGImageDestination encoder (10–15 FPS)

Fade Engine: uses CACurrentMediaTime() for time-based alpha

🧩 Menu Bar Items

✏️ Toggle Draw (⌘⇧D)

🧹 Clear Screen (⌘⇧C)

🔥 Fade Ink → Off / 5 / 10 / 20s

🎥 Record Region (⌘⇧R)

📱 Frame Preset → iPhone / iPad / 1080p / 4K / Custom

🎨 Color Presets → Yellow / Red / Blue / Green / White

🚪 Quit Design Stage

✅ MVP Acceptance Criteria

Fade ink renders smoothly (no flicker).

Record region creates playable .mov or .gif.

Frame presets open accurate pixel frames.

Overlay + drawing works across all apps/spaces.

CPU < 5% idle, memory < 100MB.
