# App Store Privacy Nutrition Labels Declaration
### Project: Harmonia Camera (`com.apple.harmonia.camera`)

In compliance with Apple's App Store Privacy Guidelines, this document provides the exact responses required when filling out the App Privacy Questionnaire in App Store Connect.

---

## 1. Summary of Data Collection

| Question | Response | Technical Architecture Justification |
| :--- | :--- | :--- |
| **Do you or your third-party partners collect data from this app?** | **NO** | Harmonia operates entirely client-side on-device. No telemetry, analytics SDKs, or cloud backends are bundled. |
| **Is any data used to track users across apps/websites?** | **NO** | No third-party ad networks, tracking identifiers, or device fingerprinting. |

---

## 2. Sensor & Data Usage Breakdown

### A. Camera (`NSCameraUsageDescription`)
* **Purpose:** Live viewfinder composition overlay rendering and high-resolution photo capture.
* **On-Device Only:** Video sample buffers (`CMSampleBuffer`) are processed ephemerally in RAM by Apple's `Vision` framework. No frames are cached, logged, or transmitted off-device.

### B. Motion & Sensors (`CMMotionManager`)
* **Purpose:** Accelerometer and gyroscope streaming for real-time horizon level indication and camera stance detection.
* **On-Device Only:** Attitude angles (pitch/roll) are evaluated in-memory and immediately discarded.

### C. Photo Library (`NSPhotoLibraryAddUsageDescription`)
* **Purpose:** Saving captured photos (Clean Master and optional Composition Reference) into a local "Harmonia" album in the Apple Photos app.
* **On-Device Only:** Images are written directly to `PHPhotoLibrary` via system APIs. No remote cloud uploads occur.

---

## 3. App Store Connect Label Output

```
┌────────────────────────────────────────────────────────┐
│                      DATA NOT COLLECTED                │
│                                                        │
│  The developer does not collect any data from this app.│
│                                                        │
│  • No Contact Info                                     │
│  • No Identifiers                                      │
│  • No Usage Data                                       │
│  • No Diagnostics                                      │
│  • No Location                                         │
└────────────────────────────────────────────────────────┘
```
