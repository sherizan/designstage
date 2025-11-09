# Screen Recording Feature - User Guide

## Overview

The Screen Recording feature in Design Stage allows you to capture any region of your screen with an intuitive interface that includes preset dimensions, draggable edges, and a video gallery.

## User Flow

### 1. Start Recording Selection

**Launch Methods:**
- Menu Bar: Click "Design Stage" icon → "Record Region (⌘⇧R)"
- Keyboard Shortcut: `⌘⇧R` (Command + Shift + R)

**Quick Stop:**
- While recording, press `⌘⇧R` again to stop immediately

### 2. Select Recording Region

When you activate the recording feature, you'll see:

#### Region Selector Overlay
- **Dark overlay** covering all screens (50% opacity)
- **Default recording area** (1280x720 landscape) appears centered on your screen
- **Live dimension display** in the top-right corner of the selection area
- **Visual handles** at corners and edges for resizing

#### Interaction Methods

**Moving the Region:**
- Click and drag anywhere inside the selection area
- The region will follow your cursor
- Cannot move outside screen boundaries

**Resizing with Edge Handles:**
- **Corner handles** (white circles with blue borders): Drag to resize from corners
- **Edge handles** (white squares): Drag to resize from sides
- **Minimum size**: 100x100 pixels to ensure usable recordings
- **Live dimension updates** as you resize

**Keyboard Controls:**
- `Escape`: Cancel region selection
- `Enter/Return`: Confirm selection and show recording controls

### 3. Recording Control Bar

After selecting a region, a sleek control bar appears below the selection area:

#### Control Bar Elements

**Left Side - Preset Selector:**
- Dropdown menu with preset dimensions:
  - **Square (1080 × 1080)**: Perfect for Instagram posts
  - **Landscape (1280 × 720)**: Standard HD recording
  - **Portrait (393 × 852)**: iPhone screen dimensions
  - **Custom**: Shows when you manually resize

**Center - Record Button:**
- **Red circle button**: Click to start recording
- **During recording**: Changes to square shape with pulsing animation
- Click again to stop recording

**Right Side - Dimension Display:**
- Shows current selection dimensions (e.g., "1280 × 720")
- Updates in real-time when you resize

**Duration Display:**
- Appears below the record button during recording
- Shows elapsed time (e.g., "0:45")
- Red text color for visibility

**Close Button:**
- "X" button on far right
- Cancels the recording setup

### 4. Recording Session

**Starting Recording:**
1. Click the red record button
2. The button animates (pulsing) to indicate active recording
3. Duration timer starts counting
4. All drawing overlays can be captured (if enabled)

**During Recording:**
- The recording captures only the selected region
- Cursor is visible in the recording
- Auto-stops after 2 minutes (safety feature)

**Stopping Recording:**
- Click the square button (transformed record button), OR
- Press `⌘⇧R` keyboard shortcut for quick stop
- Video processing happens automatically
- Confirmation dialog appears with video details

### 5. Video Thumbnail Gallery

Located below the control bar, the gallery shows your recorded videos:

#### Gallery Features

**Thumbnail Display:**
- **Horizontal scrolling gallery**
- Each thumbnail is 90x90 pixels
- Shows video preview image
- Duration badge in bottom-left corner

**Interaction:**
- **Click thumbnail**: Opens video in default player
- **Hover**: Shows delete button (trash icon)
- **Delete button**: Removes video from gallery and disk

**Video Information:**
- Duration overlay on each thumbnail
- Thumbnail auto-generated from first frame
- Sorted by creation date (newest first)

### 6. After Recording

**Completion Dialog:**
- Shows success message
- Displays video details:
  - Duration
  - Dimensions
  - File location
- Two options:
  - "Open in Finder": Navigate to saved video
  - "OK": Dismiss and continue

**Video Storage:**
- Saved to: `~/Movies/` directory
- Filename format: `DesignStage-YYYY-MM-DD-HHmmss.mov`
- Format: H.264 .mov file (high quality, 6 Mbps)
- Retina scaling: Captures at 2x resolution for sharp output

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⇧R` | Start region selection (when idle) / Stop recording (when recording) |
| `Escape` | Cancel selection/close controls |
| `Enter` | Confirm selection (if supported) |

## Technical Details

### Recording Specifications
- **Codec**: H.264
- **Container**: .mov (QuickTime)
- **Bitrate**: 6,000 kbps
- **Resolution**: 2× selected area (Retina)
- **Cursor**: Included
- **Audio**: Not included (screen-only recording)

### Preset Dimensions
- **Square**: 1080 × 1080 (1:1 ratio)
- **Landscape**: 1280 × 720 (16:9 ratio, 720p HD)
- **Portrait**: 393 × 852 (iPhone screen size)

### Permissions Required
- **Screen Recording Permission**: Required for macOS 10.15+
- Prompted on first use
- Can be granted in System Preferences → Security & Privacy → Screen Recording

## Tips & Best Practices

1. **Choose the Right Preset:**
   - Social media posts → Square (1080×1080)
   - Tutorials/demos → Landscape (1280×720)
   - Mobile app demos → Portrait (393×852)

2. **Performance:**
   - Close unnecessary applications for better performance
   - Recordings are optimized for file size and quality
   - Auto-stop at 2 minutes prevents accidentally long recordings

3. **Organization:**
   - Videos are automatically named with timestamps
   - Use the gallery for quick access to recent recordings
   - Delete unwanted recordings from the gallery to save space

4. **Custom Sizes:**
   - Drag edges to any custom dimension
   - Maintains minimum 100×100 pixel size
   - Dimensions always shown in pixels

## Troubleshooting

**"Recording Failed" Error:**
- Ensure Screen Recording permission is granted
- Check available disk space
- Try restarting Design Stage

**No Thumbnail in Gallery:**
- Thumbnail generation may take a moment
- Fallback icon shows if generation fails
- Video is still playable

**Recording Doesn't Start:**
- Verify the region is at least 100×100 pixels
- Check that Screen Recording permission is enabled
- Look for system alerts blocking the feature

## Architecture Notes (For Developers)

### Components
1. **RecordingPreset** - Model for preset dimensions
2. **RecordedVideo** - Model for video metadata
3. **EnhancedRegionSelectorWindow** - Interactive region selector with draggable edges
4. **RecordingControlBar** - Control interface with presets and record button
5. **VideoThumbnailGallery** - Horizontal scrolling gallery for recordings
6. **EnhancedRecordingService** - Main service coordinating all components
7. **ScreenRecorder** - Low-level screen capture using ScreenCaptureKit

### State Management
The recording service manages states:
- `idle` - No active recording
- `regionSelection` - User is selecting region
- `readyToRecord` - Region selected, controls visible
- `recording` - Active recording in progress

### Data Persistence
- Video metadata stored in UserDefaults
- Video files stored in Movies directory
- Gallery syncs with filesystem on launch

