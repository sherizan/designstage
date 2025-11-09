# Screen Recording UI Design Specifications

## Color Palette

### Primary Colors
- **Overlay Background**: `rgba(0, 0, 0, 0.5)` - Semi-transparent black
- **Selection Border**: `rgba(255, 255, 255, 0.9)` - Near-white with slight transparency
- **Record Button**: `#FF0000` - System red
- **Blue Accent**: `#0A84FF` - System blue (handles, borders)

### Control Bar
- **Background**: `rgba(0, 0, 0, 0.85)` - Dark with 85% opacity
- **Border**: `rgba(255, 255, 255, 0.1)` - Subtle white border
- **Text**: `#FFFFFF` - White
- **Duration (recording)**: `#FF0000` - Red

### Gallery
- **Background**: `rgba(0, 0, 0, 0.9)` - Dark with 90% opacity
- **Border**: `rgba(255, 255, 255, 0.15)` - Subtle white border
- **Thumbnail Hover Border**: `#0A84FF` - System blue
- **Delete Button**: `rgba(255, 0, 0, 0.8)` - Semi-transparent red

## Typography

### System Fonts
```swift
// Dimension labels (live updates)
Font: SF Mono (Monospaced System)
Size: 13pt
Weight: Medium

// Duration timer
Font: SF Mono (Monospaced System)
Size: 12pt
Weight: Medium

// Control bar labels
Font: System
Size: 13pt
Weight: Regular
```

## Layout Specifications

### Region Selector Window

```
Full Screen Overlay
├── Background: rgba(0, 0, 0, 0.5)
├── Level: .screenSaver (above all apps)
└── Selection Rectangle
    ├── Default Size: 1280×720
    ├── Default Position: Centered on screen
    ├── Border Width: 3px
    ├── Border Color: White (90% opacity)
    └── Handles
        ├── Corner Handles
        │   ├── Size: 12×12
        │   ├── Shape: Circle
        │   ├── Fill: White
        │   └── Border: 2px Blue
        └── Edge Handles
            ├── Size: 8×8
            ├── Shape: Square
            ├── Fill: White (80% opacity)
            └── Border: 1.5px Blue (80% opacity)

Dimension Label (Top-Right Corner)
├── Background: rgba(0, 0, 0, 0.7)
├── Padding: 8px horizontal, 6px vertical
├── Border Radius: 4px
├── Text: White, 13pt Mono
└── Format: "1280 × 720"
```

### Recording Control Bar

```
Width: 400px
Height: 60px
Position: Below region center, 10px gap
Background: rgba(0, 0, 0, 0.85)
Border: 1px rgba(255, 255, 255, 0.1)
Corner Radius: 8px
Shadow: Yes

Layout (Flexbox-like):
┌─────────────────────────────────────────┐
│ [Preset ▼]     ●      [1280×720]   [×] │
│   130px      40×40      100px      20px │
│   15px←    centered   →140px    →350px  │
└─────────────────────────────────────────┘

Components:
├── Preset Selector (Left)
│   ├── X: 15px from left
│   ├── Width: 130px
│   ├── Height: 28px
│   └── Type: NSPopUpButton
│
├── Record Button (Center)
│   ├── Size: 40×40
│   ├── Position: Horizontally centered
│   ├── Shape: Circle (idle), Square (recording)
│   ├── Color: Red
│   ├── Corner Radius: 20px (idle), 4px (recording)
│   └── Animation: Pulse (0.8s cycle when recording)
│
├── Duration Label (Below button when recording)
│   ├── Font: 12pt Mono
│   ├── Color: Red
│   ├── Position: Below button, 8px gap
│   └── Format: "0:00"
│
├── Dimension Display (Right)
│   ├── Font: 13pt Mono
│   ├── Color: White
│   ├── Position: 140px from right
│   └── Auto-size to fit
│
└── Close Button (Far Right)
    ├── X: 10px from right
    ├── Size: 20×20
    ├── Icon: "xmark" system symbol
    └── Color: White (70% opacity)
```

### Video Thumbnail Gallery

```
Width: min(region.width, 600px)
Height: 120px
Position: Below control bar, 70px gap from region
Background: rgba(0, 0, 0, 0.9)
Border: 1px rgba(255, 255, 255, 0.15)
Corner Radius: 8px
Shadow: Yes

Layout:
┌──────────────────────────────────────────┐
│  [📹] [📹] [📹] [📹] [📹]  →             │
│   90×90 thumbnails with 12px spacing     │
│   Horizontal scroll enabled              │
│   Padding: 10px all sides                │
└──────────────────────────────────────────┘

Thumbnail Specifications:
├── Container
│   ├── Size: 90×90
│   ├── Background: rgba(0, 0, 0, 0.5)
│   ├── Corner Radius: 6px
│   ├── Border: 2px transparent (clear on idle)
│   └── Border (hover): 2px #0A84FF
│
├── Image View
│   ├── Size: 82×82 (inset by 4px)
│   ├── Corner Radius: 4px
│   └── Scaling: Aspect Fill
│
├── Duration Badge
│   ├── Position: Bottom-left, 6px from edges
│   ├── Background: rgba(0, 0, 0, 0.7)
│   ├── Padding: 3px horizontal, 2px vertical
│   ├── Corner Radius: 3px
│   ├── Font: 10pt Mono Bold
│   ├── Color: White
│   └── Format: "0:45"
│
└── Delete Button (Hover Only)
    ├── Position: Top-right, 4px from edges
    ├── Size: 20×20
    ├── Background: rgba(255, 0, 0, 0.8)
    ├── Corner Radius: 10px (circle)
    ├── Icon: "trash" system symbol
    └── Color: White
```

## Animations & Transitions

### Record Button Animation (During Recording)
```swift
// Pulsing effect
Duration: 0.8 seconds
Timing: Ease-in-out
Property: Alpha
Values: 1.0 → 0.5 → 1.0
Loop: Infinite
```

### Hover Effects
```swift
// Thumbnail hover
Duration: 0.2 seconds
Property: Border color
From: Clear
To: Blue (#0A84FF)

// Delete button appear
Duration: 0.15 seconds
Property: Alpha
From: 0.0
To: 1.0
```

### Window Transitions
```swift
// Fade in
Duration: 0.25 seconds
Property: Alpha
From: 0.0
To: 1.0

// Fade out
Duration: 0.2 seconds
Property: Alpha
From: 1.0
To: 0.0
```

## Cursor States

### Region Selector Interactions
```
Inside selection: .openHand
Dragging inside: .closedHand
Left/Right edge: .resizeLeftRight
Top/Bottom edge: .resizeUpDown
Corners: .crosshair (diagonal resize)
Outside selection: .arrow
```

## Spacing & Padding

### Standard Spacing
- **Small gap**: 8px
- **Medium gap**: 12px
- **Large gap**: 16px
- **Section gap**: 24px

### Component Padding
- **Control bar**: 15px horizontal, 10px vertical
- **Gallery**: 10px all sides
- **Labels**: 8px horizontal, 6px vertical
- **Buttons**: 12px horizontal, 8px vertical

## Responsive Behavior

### Region Constraints
```
Minimum Width: 100px
Minimum Height: 100px
Maximum Width: Screen width
Maximum Height: Screen height
```

### Control Bar Position
```
Always centered below region
Maintains 10px gap from region bottom
Adjusts position when region moves
```

### Gallery Width
```
Width: min(region.width, 600px)
Centers below region if narrower than region
Maximum 600px to prevent excessive width
```

## Accessibility

### Color Contrast
- White text on dark background: WCAG AAA compliant
- Button labels: High contrast
- Duration timer (red): Sufficient contrast

### Interactive Elements
- Minimum touch target: 40×40 (record button)
- Keyboard navigation: Supported (ESC, Enter)
- Focus indicators: System default

### Screen Reader Support
- Buttons have accessibility descriptions
- Images have accessibility labels
- State changes announced

## Design Principles

### Visual Hierarchy
1. **Primary**: Record button (center, red, largest)
2. **Secondary**: Dimension display, preset selector
3. **Tertiary**: Gallery thumbnails, close button

### Consistency
- Rounded corners throughout (4px, 6px, 8px, 10px, 20px)
- Consistent color palette
- Monospaced fonts for dimensions/durations
- System fonts for labels

### Feedback
- Hover states on interactive elements
- Pulsing animation during recording
- Live dimension updates
- Visual handles on selection

### Minimalism
- Clean, uncluttered interface
- Essential controls only
- Hidden elements (delete button) until needed
- Transparent backgrounds for context

## Implementation Notes

### Layer Order (Front to Back)
```
1. Close button (most forward)
2. Delete buttons (hover)
3. Duration timer (recording)
4. Control bar
5. Gallery
6. Region selector overlay
7. Background overlay (most back)
```

### Window Levels
```
Region Selector: .screenSaver
Control Bar: .floating
Gallery: .floating
Alert Dialogs: .modalPanel
```

### Performance Considerations
- Thumbnail generation: Async with caching
- Animation: Hardware-accelerated (layer-backed)
- Drawing: CVDisplayLink for smooth updates
- Scroll: Elastic scrolling enabled

---

This design specification ensures a modern, clean, and intuitive interface that matches macOS design guidelines while providing a delightful user experience.

