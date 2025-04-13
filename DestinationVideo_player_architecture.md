# DestinationVideo Player Architecture Analysis - Revised

This document analyzes how the Apple DestinationVideo sample project implements full-window video playback in visionOS, with a strict focus on verifiable code patterns.

## Overview

The DestinationVideo app demonstrates an approach to video playback in visionOS that:

1. Provides a full-window video playback experience
2. Maintains app state when transitioning between UI and playback
3. Integrates with visionOS immersive spaces

## Core Components

### 1. PlayerModel

The `PlayerModel` class manages the video playback state and defines two presentation modes:

```swift
// From Player/PlayerModel.swift
/// The presentation modes the player supports.
enum Presentation {
    /// Presents the player as a child of a parent user interface.
    case inline
    /// Presents the player in full-window exclusive mode.
    case fullWindow
}

@MainActor @Observable class PlayerModel {
    /// The presentation in which to display the current media.
    private(set) var presentation: Presentation = .inline
    
    /// The currently loaded video.
    private(set) var currentItem: Video? = nil
    
    /// Loads a video for playback in the requested presentation.
    func loadVideo(_ video: Video, presentation: Presentation = .inline, autoplay: Bool = true) {
        // Update the model state
        currentItem = video
        shouldAutoPlay = autoplay
        isPlaybackComplete = false
        
        // Load the video into the player
        // ...
        
        // Set the presentation
        self.presentation = presentation
    }
    
    func reset() {
        currentItem = nil
        player.replaceCurrentItem(with: nil)
        playerUI = nil
        playerUIDelegate = nil
        Task {
            presentation = .inline
        }
    }
}
```

### 2. ContentView

The `ContentView` is the app's top-level view that switches its content based on the presentation mode:

```swift
// From ContentView.swift
struct ContentView: View {
    @Environment(PlayerModel.self) private var player
    #if os(visionOS)
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment
    #endif

    var body: some View {
        #if os(visionOS)
        Group {
            switch player.presentation {
            case .fullWindow:
                PlayerView()
                    .immersiveEnvironmentPicker {
                        ImmersiveEnvironmentPickerView()
                    }
                    .onAppear {
                        player.play()
                    }
            default:
                // Shows the app's content library by default.
                DestinationTabs()
            }
        }
        .immersionManager()
        #else
        // Platform-specific code for other OSes
        DestinationTabs()
            .presentVideoPlayer()
        #endif
    }
}
```

### 3. DetailView

The `DetailView` contains the "Play Movie" button that initiates full-window playback:

```swift
// From Views/DetailView.swift
struct DetailView: View {
    @Environment(PlayerModel.self) private var player
    
    var body: some View {
        // UI layout...
        Button {
            /// Load the media item for full-window presentation.
            player.loadVideo(video, presentation: .fullWindow)
        } label: {
            Label("Play Movie", systemImage: "play.fill")
        }
    }
}
```

### 4. PlayerView

The `PlayerView` presents the video playback interface:

```swift
// From Player/PlayerView.swift
struct PlayerView: View {
    let controlsStyle: PlayerControlsStyle
    @Environment(PlayerModel.self) private var model
    
    init(controlsStyle: PlayerControlsStyle = .system) {
        self.controlsStyle = controlsStyle
    }

    var body: some View {
        switch controlsStyle {
        case .system:
            systemPlayerView
                // Configuration...
        case .custom:
            #if os(visionOS)
            InlinePlayerView()
            #endif
        }
    }
}
```

## Key Implementation Patterns

### 1. Presentation State Switching

The app uses `player.presentation` to control what the ContentView displays:

1. When the app starts, `presentation` is `.inline` and `ContentView` shows `DestinationTabs`
2. When "Play Movie" is clicked, `player.loadVideo(video, presentation: .fullWindow)` is called
3. This updates `player.presentation` to `.fullWindow`
4. `ContentView` observes this change and switches to showing `PlayerView()`
5. When playback ends or is dismissed, `player.reset()` is called
6. This resets `player.presentation` to `.inline`
7. `ContentView` switches back to showing `DestinationTabs`

### 2. visionOS Immersive Integration

In visionOS, the full-window player can integrate with immersive spaces:

```swift
// From ContentView.swift
PlayerView()
    .immersiveEnvironmentPicker {
        ImmersiveEnvironmentPickerView()
    }
```

The `immersiveEnvironmentPicker` modifier allows users to select immersive environments while in full-window playback mode.

The `ImmersiveEnvironmentPickerView` provides buttons that trigger immersive spaces:

```swift
// From Views/visionOS/ImmersiveEnvironmentPickerView.swift
struct StudioButton: View {
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment

    var state: EnvironmentStateType

    var body: some View {
        Button {
            immersiveEnvironment.requestEnvironmentState(state)
            immersiveEnvironment.loadEnvironment()
        } label: {
            // Button UI...
        }
    }
}
```

When an environment is selected, the app opens an immersive space:

```swift
// From Views/ViewModifiers.swift
func immersionManager() -> some View {
    self.modifier(ImmersiveSpacePresentationModifier())
}

private struct ImmersiveSpacePresentationModifier: ViewModifier {
    @Environment(ImmersiveEnvironment.self) private var immersiveEnvironment
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    func body(content: Content) -> some View {
        content
            .onChange(of: immersiveEnvironment.showImmersiveSpace) { _, show in
                Task { @MainActor in
                    if !immersiveEnvironment.immersiveSpaceIsShown, show {
                        switch await openImmersiveSpace(id: ImmersiveEnvironmentView.id) {
                        case .opened:
                            immersiveEnvironment.immersiveSpaceIsShown = true
                        // Error handling...
                        }
                    }
                }
            }
    }
}
```

### 3. Platform-Specific Window Management

Each platform handles the video presentation differently:

#### visionOS

In visionOS, the app switches content within the same window:

```swift
// From ContentView.swift
switch player.presentation {
case .fullWindow:
    PlayerView()
    // ...
default:
    DestinationTabs()
}
```

#### iOS/tvOS

On iOS/tvOS, the app uses a modal presentation:

```swift
// From Views/ViewModifiers.swift
private struct FullScreenCoverModifier: ViewModifier {
    @Environment(PlayerModel.self) private var player
    @State private var isPresentingPlayer = false
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresentingPlayer) {
                PlayerView()
                // ...
            }
            .onChange(of: player.presentation, { _, newPresentation in
                isPresentingPlayer = newPresentation == .fullWindow
            })
    }
}
```

#### macOS

On macOS, the app opens a new window:

```swift
// From Views/ViewModifiers.swift
private struct OpenVideoPlayerModifier: ViewModifier {
    @Environment(PlayerModel.self) private var player
    @Environment(\.openWindow) private var openWindow
    
    func body(content: Content) -> some View {
        content
            .onChange(of: player.presentation, { oldValue, newValue in
                if newValue == .fullWindow {
                    openWindow(id: PlayerView.identifier)
                }
            })
    }
}

// From PlayerWindow.swift (macOS only)
struct PlayerWindow: Scene {
    var player: PlayerModel

    var body: some Scene {
        WindowGroup(id: PlayerView.identifier) {
            PlayerView()
                // ...
        }
    }
}
```

## Flow Diagram

```
┌─────────────────┐     User clicks "Play Movie"     ┌──────────────────┐
│                 │ ──────────────────────────────▶ │                  │
│    DetailView   │ player.loadVideo(presentation:.fullWindow)│    PlayerModel   │
│                 │ ◀─────────────────────────────  │                  │
└─────────────────┘     Updates presentation to .fullWindow └──────────────────┘
                                                             │
                                                             │ ContentView observes
                                                             │ presentation change
                                                             ▼
┌─────────────────┐     Switches content            ┌──────────────────┐
│                 │ ◀─────────────────────────────│                  │
│   ContentView   │                                │   PlayerView     │
│                 │ ──────────────────────────────▶│                  │
└─────────────────┘                                └──────────────────┘
       │                      ┌──────────────────┐        │
       │                      │                  │        │ Optional
       │                      │  ImmersiveSpace  │◀───────┘ immersive
       │                      │                  │          integration
       │                      └──────────────────┘
       │
       │ Player closes or 
       │ user dismisses it
       ▼
┌─────────────────┐
│                 │
│  DestinationTabs│
│                 │
└─────────────────┘
```

## visionOS-Specific Features

### Window Management Approach

In visionOS, the app avoids window management issues by:

1. Keeping a single window active at all times
2. Switching the content within that window based on `player.presentation`
3. Never explicitly opening or closing windows for the player

This pattern prevents app exit issues that might occur when closing windows.

### Immersive Space Integration

In visionOS, the player integrates with immersive spaces through:

1. The `immersiveEnvironmentPicker` modifier on PlayerView
2. The ImmersiveEnvironment observable class that manages spaces
3. The ImmersiveSpacePresentationModifier that handles space transitions

## Key Files

- **DestinationVideo.swift**: Main app structure
- **ContentView.swift**: Switches between UI and player
- **PlayerModel.swift**: Manages playback state and presentation mode
- **DetailView.swift**: Contains the "Play Movie" button
- **PlayerView.swift**: Presents the player interface
- **ViewModifiers.swift**: Contains platform-specific presentation logic

## Applying This to Your Project

To apply this architecture to your visionOS project:

1. Create a central player model that tracks presentation state
2. Use SwiftUI's environment to share this model
3. Make your top-level view conditionally switch between regular UI and player based on presentation state
4. When showing the player, display it directly in the view hierarchy rather than in a separate window
5. Reset the presentation state when the player closes

The key insight is that rather than managing windows directly, the app uses state (presentation mode) to control what's displayed in the window, avoiding window management issues entirely. 