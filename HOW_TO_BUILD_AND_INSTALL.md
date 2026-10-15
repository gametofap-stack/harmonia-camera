# How to Build & Install Harmonia on your iPhone 15 (Using Windows)

You do **not** need a Mac. Everything is automated:
1. GitHub compiles the code in the cloud on a Mac for free.
2. You download the generated `Harmonia.ipa` file to your Windows PC.
3. You plug your iPhone 15 into your PC via USB-C and install it using **Sideloadly** (100% free, using your regular Apple ID).

---

## Step 1: Push This Code to GitHub (Takes 2 minutes)

1. Open PowerShell or Terminal in this folder (`d:\Antigravity Apps\Camera Lens`).
2. Go to [github.com](https://github.com) in your browser and create a new **Private Repository** (e.g., name it `harmonia-camera`). Do **not** check "Initialize with README".
3. In your terminal, run these commands:
   ```powershell
   git init
   git add .
   git commit -m "Initial Harmonia Camera release"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/harmonia-camera.git
   git push -u origin main
   ```
   *(Replace `YOUR_USERNAME` with your actual GitHub username).*

---

## Step 2: Cloud Builds the App Automatically (Takes ~3 minutes)

1. The moment you push your code, GitHub Actions triggers automatically.
2. On your GitHub repository page in your browser:
   * Click on the **"Actions"** tab at the top.
   * You will see a running workflow called **"Build Harmonia iOS IPA"**.
   * Click on it and watch the progress.
3. Once the build finishes (shows a green checkmark ✅):
   * Scroll down to the **"Artifacts"** section at the bottom of the summary page.
   * Click on **`Harmonia-iPhone15-IPA`** to download it.
   * Extract the downloaded `.zip` file to get your **`Harmonia.ipa`** file!

---

## Step 3: Enable "Developer Mode" on your iPhone 15 (Takes 30 seconds)

Because this is a custom-built app, iOS requires you to enable Developer Mode once:
1. On your iPhone 15, open **Settings**.
2. Tap **Privacy & Security**.
3. Scroll all the way to the bottom and tap **Developer Mode**.
4. Turn the switch **ON**.
5. Your iPhone will ask to restart. Tap **Restart**.
6. When it turns back on, unlock it and tap **Turn On** when the confirmation popup appears.

---

## Step 4: Install Harmonia onto your iPhone 15 via Windows

1. Download and install **Sideloadly** on your Windows PC from:
   👉 **[https://sideloadly.io](https://sideloadly.io)** (Official, free, and safe sideloading tool for Windows).
2. Connect your **iPhone 15 to your PC** using its USB-C cable.
   * If your iPhone asks *"Trust This Computer?"*, tap **Trust** and enter your passcode.
3. Open **Sideloadly** on Windows:
   * You will see your iPhone 15 detected in the device dropdown.
   * Drag and drop the **`Harmonia.ipa`** file onto the big IPA icon in Sideloadly.
   * In the **Apple ID** field, type your normal Apple ID email address.
   * Click **Start**.
   * (If prompted, enter your Apple ID password / 2FA code. Sideloadly uses this only to request a free developer certificate directly from Apple to sign the app for your specific phone).
4. Wait about 30 seconds until Sideloadly says **"Done"**.

---

## Step 5: Trust the Certificate & Launch

1. On your iPhone 15, open **Settings** $\to$ **General** $\to$ **VPN & Device Management**.
2. Under *Developer App*, you will see your Apple ID email. Tap it.
3. Tap **Trust "[Your Apple ID]"** and confirm.
4. Go to your iPhone home screen — **Harmonia Camera** is installed!
5. Tap the icon to open it, grant Camera and Photo permissions, and start framing with all 15 composition rules!
