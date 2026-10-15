# Production Release Verification & Hardware Checklist
### Project: Harmonia Camera (`com.apple.harmonia.camera`)
**Target Hardware:** iPhone 15 (Model A3090, A2846, A3089, A3092)

---

## 1. Physical Device Verification Protocol

Before final App Store submission, the binary must pass the following hardware checklist on a physical iPhone 15 running iOS 17+:

### Camera & Optical Pipeline
- [ ] **Ultra-Wide ($0.5\times$):** Tapping `0.5x` smoothly swaps to the physical $13\text{mm}$ lens without viewfinder flicker or aspect distortion.
- [ ] **Main ($1.0\times$):** Tapping `1x` returns cleanly to the 48MP main sensor ($26\text{mm}$).
- [ ] **Lossless Sensor Crop ($2.0\times$):** Tapping `2x` engages optical-grade $52\text{mm}$ framing via center quad-pixel crop.
- [ ] **48MP Full Resolution Check:** Verify that photos captured on 1x save at full sensor dimensions ($8064 \times 6048$) when inspected in Photos.
- [ ] **Low-Light Boost:** Verify that the viewfinder connection automatically handles low-light scenarios without freezing.
- [ ] **Torch Toggle:** Tapping the torch icon toggles the physical rear LED flash smoothly with active state color indication.

### Composition Vector Suite
- [ ] **All 15 Frameworks:** Verify that each of the 15 rules renders with its dual-stroke anti-glare halo.
- [ ] **Flip Horizontal:** Swapping left/right horizontally mirrors asymmetric rules (Fibonacci, Golden Triangles, Left to Right).
- [ ] **Rotate $90^\circ$:** Tapping rotate steps the orientation by $90^\circ$ clockwise with spring animation.
- [ ] **Color Styling:** Switching between Studio Red, Apple Gold, and Polar White instantly updates the active overlay and cached drawer thumbnails.

### Kinetics & Motion
- [ ] **60 Hz Level Tracking:** Tilting the phone smoothly animates the split-bar horizon line counter to device roll.
- [ ] **Mechanical Snap Haptic:** Leveling the phone to $0.0^\circ \pm 0.35^\circ$ fires a clean, crisp `UIImpactFeedbackGenerator(style: .rigid)` pulse.
- [ ] **Stance HUD:** Verify correct classification of *Low Angle*, *Eye Level*, *High Angle*, and *Flat-Lay*.

### Vision AI & Smart Coach
- [ ] **Frame Rate Stability:** Verify that the viewfinder maintains a locked 60 FPS while Vision analysis runs at 10 Hz in the background.
- [ ] **Face & Portrait Detection:** Pointing at a face triggers the portrait suggestion with 2x lens recommendation.
- [ ] **One-Tap Apply:** Tapping "Apply Rule & Lens" in the Smart Coach card instantly transitions the camera without user friction.

### Asset Delivery & Dual-Save
- [ ] **Clean Photo:** Appears in the "Recent" album in Apple Photos at pristine quality.
- [ ] **Composition Reference:** When enabled, an annotated photo with guide lines and metadata stamp is saved alongside the clean master.
- [ ] **"Harmonia" Custom Album:** Both assets are automatically sorted into the dedicated "Harmonia" album.
- [ ] **Quick Review:** Tapping the bottom-left thumbnail opens the full-screen inspector with pinch-to-zoom and native iOS share sheet.

### Thermals & Energy
- [ ] **15-Minute Stress Test:** Continuous 15-minute camera operation remains within "Nominal" or "Fair" thermal states under indoor lighting.
- [ ] **Thermal Throttling Fallback:** Verify that simulated "Serious" or "Critical" thermal states gracefully throttle AI sampling to protect the main preview loop.

---

## 2. App Store Review Guidelines Compliance

* **Guideline 2.1 (Performance - App Completeness):** No placeholder buttons, broken links, or non-functional features.
* **Guideline 2.5 (Software Requirements - Public APIs):** Uses only public Apple APIs (`AVFoundation`, `Vision`, `CoreMotion`, `Photos`, `SwiftUI`). Zero private framework calls.
* **Guideline 5.1.1 (Data Collection & Storage):** Zero personal data collected; camera and photo permissions explained with crystal clarity in `Info.plist`.
* **Guideline 5.1.2 (Data Use & Sharing):** No third-party SDKs, tracking libraries, or remote servers.

---

**Architectural Sign-off:** Production Ready for App Store Connect Submission.
