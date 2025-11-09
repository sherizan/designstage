# Screen Recording Feature - Quick Reference

## 🎯 At a Glance

**Status**: ✅ Fully Implemented  
**Activation**: `⌘⇧R` or Menu Bar → "Record Region"  
**Output Format**: H.264 .mov files at 2× resolution  
**Storage**: `~/Movies/DesignStage-[timestamp].mov`

## 📦 Components (6 New Files)

| File | Purpose | Key Features |
|------|---------|--------------|
| `RecordingPreset.swift` | Preset dimensions model | 3 presets: Square, Landscape, Portrait |
| `RecordedVideo.swift` | Video metadata model | Codable, duration/dimension formatters |
| `EnhancedRegionSelectorWindow.swift` | Region selection UI | Draggable edges, handles, live dimensions |
| `RecordingControlBar.swift` | Recording controls | Record button, presets, duration timer |
| `VideoThumbnailGallery.swift` | Video gallery UI | Thumbnails, hover actions, scroll |
| `EnhancedRecordingService.swift` | Main coordinator | State machine, persistence, coordination |

## 🎨 User Flow (5 Steps)

```
1. Press ⌘⇧R
   ↓
2. See region selector (default 1280×720)
   • Drag to move
   • Drag edges/corners to resize
   ↓
3. Control bar appears below
   • Select preset (optional)
   • Click record button
   ↓
4. Recording starts
   • Duration timer counts
   • Click stop when done
   ↓
5. Video saved & thumbnail added to gallery
   • Click thumbnail to play
   • Hover to delete
```

## 🛠️ Key Classes & Methods

### EnhancedRecordingService

```swift
@MainActor
class EnhancedRecordingService: ObservableObject {
    enum RecordingState {
        case idle
        case regionSelection
        case readyToRecord(region: CGRect, preset: RecordingPreset?)
        case recording(region: CGRect, startTime: Date)
    }
    
    // Main API
    func startRegionSelection()
    func startRecording()
    func stopRecording()
    func cancelRecording()
    
    // Gallery
    func deleteVideo(_ video: RecordedVideo)
    func openVideo(_ video: RecordedVideo)
}
```

### EnhancedRegionSelectorWindow

```swift
class EnhancedRegionSelectorWindow: NSWindow {
    init(
        onComplete: @escaping (CGRect, RecordingPreset?) -> Void,
        onCancel: @escaping () -> Void
    )
}

// Interaction
- Drag inside: Move region
- Drag corners: Diagonal resize
- Drag edges: Single-axis resize
- ESC: Cancel
- Enter: Confirm
```

### RecordingControlBar

```swift
class RecordingControlBarWindow: NSPanel {
    func updatePosition(for region: CGRect)
    func updateRecordingState(isRecording: Bool, duration: TimeInterval)
}

// Actions
- onRecord: () -> Void
- onPresetChange: (RecordingPreset) -> Void
- onClose: () -> Void
```

### VideoThumbnailGallery

```swift
class VideoThumbnailGalleryWindow: NSPanel {
    func updateVideos(_ videos: [RecordedVideo])
}

// Features
- Auto-generates thumbnails from first frame
- Horizontal scroll for multiple videos
- Click to play, hover to delete
```

## 🔑 Integration Points

### AppDelegate.swift
```swift
private var recordingService: EnhancedRecordingService?

// In applicationDidFinishLaunching
recordingService = EnhancedRecordingService()

// Hotkey registration
hotkeyManager.register(keyCode: 15, modifiers: [.command, .shift]) {
    Task { @MainActor in
        self.recordingService?.startRegionSelection()
    }
}
```

### StatusItemController.swift
```swift
private weak var recordingService: EnhancedRecordingService?

init(statusItem: NSStatusItem?, 
     overlayService: OverlayService?, 
     recordingService: EnhancedRecordingService?)

@objc private func startRecording() {
    Task { @MainActor in
        recordingService?.startRegionSelection()
    }
}
```

## 📏 Preset Dimensions

| Preset | Width | Height | Use Case |
|--------|-------|--------|----------|
| Square | 1080 | 1080 | Social media posts |
| Landscape | 1280 | 720 | HD tutorials |
| Portrait | 393 | 852 | iPhone demos |
| Custom | Any | Any | Manual resize |

## 🎨 UI Specifications

### Colors
- Overlay: `rgba(0,0,0,0.5)`
- Border: `rgba(255,255,255,0.9)`
- Record Button: `#FF0000`
- Accent: `#0A84FF` (system blue)

### Sizes
- Control Bar: `400×60`
- Thumbnail: `90×90`
- Corner Handle: `12×12` (circle)
- Edge Handle: `8×8` (square)
- Record Button: `40×40`

### Spacing
- Region to Control Bar: `10px`
- Control Bar to Gallery: `60px`
- Thumbnail spacing: `12px`
- Min region size: `100×100`

## 🔄 State Machine

```
┌─────────────────────────────────────────┐
│                                         │
│  idle ←──────────────────┐              │
│   │                      │              │
│   │ startRegionSelection()              │
│   ↓                      │              │
│  regionSelection         │              │
│   │                      │              │
│   │ region confirmed     │              │
│   ↓                      │              │
│  readyToRecord ←──┐      │              │
│   │               │      │              │
│   │ startRecording()    │              │
│   ↓               │      │              │
│  recording        │      │              │
│   │               │      │              │
│   │ stopRecording() ────┘              │
│   │                      │              │
│   │ cancelRecording() ──┘              │
│                                         │
└─────────────────────────────────────────┘
```

## 💾 Persistence

### UserDefaults Key
```swift
"recordedVideos" // Array of RecordedVideo metadata
```

### File Structure
```
~/Movies/
  ├── DesignStage-2025-11-09-143052.mov
  ├── DesignStage-2025-11-09-143205.mov
  └── DesignStage-2025-11-09-143341.mov
```

## 🎥 Recording Specs

| Property | Value |
|----------|-------|
| Codec | H.264 |
| Container | .mov (QuickTime) |
| Bitrate | 6 Mbps |
| Resolution | 2× selected area |
| Cursor | Included |
| Audio | Not included |
| Max Duration | 2 minutes (auto-stop) |

## 🧪 Testing Checklist

**Basic Flow**
- [ ] Press ⌘⇧R to open selector
- [ ] Drag to move region
- [ ] Resize from corners
- [ ] Resize from edges
- [ ] Change preset
- [ ] Start recording
- [ ] Stop recording
- [ ] Verify video saved
- [ ] Play from gallery
- [ ] Delete from gallery

**Edge Cases**
- [ ] Very small region (< 100px)
- [ ] Multiple displays
- [ ] No disk space
- [ ] Missing permissions
- [ ] Auto-stop at 2 min

## 🐛 Common Issues & Solutions

### Issue: Recording fails to start
**Solution**: Check Screen Recording permission in System Preferences

### Issue: No thumbnail in gallery
**Solution**: Thumbnail generation is async, wait a moment or check video file exists

### Issue: Region selection doesn't appear
**Solution**: Ensure no other fullscreen app is blocking, check window level

### Issue: Video not saved
**Solution**: Check disk space, verify ~/Movies/ is accessible

## 📚 Documentation Files

1. **RECORDING_GUIDE.md** - Complete user guide
2. **RECORDING_WORKFLOW.md** - Visual workflow diagrams
3. **DESIGN_SPECS.md** - Detailed UI specifications
4. **IMPLEMENTATION_SUMMARY.md** - What was built
5. **README.md** - Updated with recording highlights

## 🚀 Quick Start for Developers

```bash
# 1. Open project
open designstage.xcodeproj

# 2. Build and run
⌘R

# 3. Grant permissions when prompted
System Preferences → Privacy & Security → Screen Recording

# 4. Test the feature
⌘⇧R → Select region → Record
```

## 💡 Tips & Tricks

**For Users:**
- Double-click inside region to confirm (if implemented)
- Use presets for consistent dimensions
- Check gallery before recording again

**For Developers:**
- All UI updates must be on MainActor
- Use weak references to avoid retain cycles
- Test on multiple displays
- Handle permissions gracefully
- Async thumbnail generation

## 🔮 Future Enhancements

Priority features to consider:
1. GIF export
2. Audio capture
3. Pause/resume recording
4. Countdown before recording
5. Annotation during recording
6. Custom quality settings
7. Direct upload to cloud

---

**Last Updated**: November 9, 2025  
**Version**: 1.0  
**Status**: Production Ready ✅

