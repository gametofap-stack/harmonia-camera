# Project Harmonia — Advanced Composition Camera for iPhone 15

An Apple Human Interface Guidelines-compliant, native iOS camera application engineered specifically for the iPhone 15 dual-lens 48MP imaging system.

Harmonia acts as an intelligent, real-time photographic composition coach that overlays 15 classical and modern artistic frameworks directly onto the viewfinder, coupled with hardware-level horizon leveling and on-device Vision AI scene recommendations.

---

## Key Hardware & Software Integrations

* **iPhone 15 Dual-Lens Precision:** Direct one-tap switching between **0.5x (13mm Ultra-Wide)**, **1x (26mm Main 48MP)**, and **2x (52mm Lossless Sensor Crop)**.
* **Sensor-Locked 4:3 Viewfinder:** Native 4:3 camera aspect ratio rendered without distortion on the 19.5:9 Super Retina XDR display, with deep-black top/bottom tactile control decks.
* **15 Vector Composition Frameworks:** Scalable, resolution-independent vector shapes with live horizontal/vertical flipping and 90° rotations.
* **Smart Coach (Vision AI):** Background 10 Hz throttled Neural Engine inference analyzing saliency, faces, perspective lines, and horizon to recommend optimal composition rules and focal lengths.
* **CoreMotion Kinetic Leveling:** Real-time 60 Hz pitch/roll attitude monitoring with mechanical Taptic Engine snaps on 0.0° level alignment.
* **Dual-Asset Capture:** 48MP/24MP pristine master capture with optional secondary composition reference photo.

---

## Directory Architecture

```
Camera Lens/
├── Harmonia/
│   ├── App/
│   │   ├── HarmoniaApp.swift          # App Entrypoint
│   │   └── AppEnvironment.swift       # Central State Coordinator
│   ├── Core/
│   │   ├── Configuration/
│   │   │   └── AppConfiguration.swift # Hardware specs & performance budgets
│   │   ├── Extensions/
│   │   │   └── Geometry+Extensions.swift # Unit space matrix math
│   │   └── Protocols/
│   │       └── ServiceProtocols.swift # Modular service contracts
│   ├── Resources/
│   │   ├── Info.plist                 # Camera/Photos privacy descriptors
│   │   └── Assets.xcassets/           # Asset catalogs
│   └── UI/
│       ├── RootView.swift             # 4:3 Viewfinder & control decks
│       └── Theme/
│           └── AppTheme.swift         # Design tokens, colors & haptics
├── Package.swift                      # SwiftPM package manifest (iOS 17+)
└── README.md
```

---

## Phased Roadmap

* [x] **Phase 0:** Project Inception & Foundation Architecture
* [x] **Phase 1:** AVFoundation Core & iPhone 15 Lens Pipeline (0.5x, 1x, 2x + 48MP)
* [x] **Phase 2:** CompositionKit — 15 Vector Frameworks Suite
* [x] **Phase 3:** CoreMotion Kinetics & Precision Haptic Leveling
* [x] **Phase 4:** "Smart Coach" Vision Intelligence Subsystem
* [x] **Phase 5:** High-Res Photo Capture & Dual-Save Asset Pipeline
* [x] **Phase 6:** Performance Optimization, Thermal Profiling & HIG Polish
* [x] **Phase 7:** App Store Deployment & Production Readiness

---

## Building & Deploying

### Prerequisites
* macOS 14.0+ with **Xcode 15.0+** installed.
* Target Device: **iPhone 15** running **iOS 17.0+**.
* Apple Developer Account for device deployment and App Store Connect signing.

### Quick Start
1. Open the project in Xcode (`Package.swift` or generate Xcode project via `swift package generate-xcodeproj`).
2. Select target device **iPhone 15** or **iOS Simulator (iPhone 15)**.
3. Press **Cmd + R** to run.

### Fastlane Automated CI/CD
* Run test suite: `bundle exec fastlane test`
* Deploy to TestFlight: `bundle exec fastlane beta`
* Submit for App Store Review: `bundle exec fastlane release`
