# Background Assets Test App

A complete iOS app demonstrating Apple-Hosted Background Assets with all three download policies.

## 🎯 What This App Does

Tests **3 download policies** for Background Assets:

| Policy | Color | Image | Behavior |
|--------|-------|-------|----------|
| **Essential** | 🟢 Green | image1.jpg | Downloads **before** app launches (blocking) |
| **Prefetch** | 🟠 Orange | image2.jpg | Downloads **in background** after app launches |
| **On-Demand** | 🟣 Purple | image3.jpg | Downloads **only when button pressed** |

## 📋 Requirements

- **Xcode 16.0+** (full installation, not just Command Line Tools)
- **iOS 26.0+** device or simulator
- **Apple Developer Account** (for TestFlight)
- **macOS** with WiFi for local testing

## 🚀 Quick Start

### Option A: Test on TestFlight (Recommended - Real Behavior)
Skip local testing and go straight to TestFlight to see actual download policies in action.

→ **[Jump to TestFlight Setup](#testflight-setup)**

### Option B: Test Locally (Mock Server - Limited)
Test download/display logic locally. Note: Essential/Prefetch won't auto-download with mock server.

→ **[Jump to Local Testing](#local-testing-setup)**

---

## 📱 TestFlight Setup

### Step 1: Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platforms:** iOS
   - **Name:** Background Assets Test
   - **Primary Language:** English
   - **Bundle ID:** `com.bgassetstestapp.learninglanguages.applebgassets`
   - **SKU:** `bgassetstest001`
4. Click **Create**

### Step 2: Archive & Upload App

**In Xcode:**

1. Select destination: **Any iOS Device (arm64)**
2. **Product → Archive** (wait for build)
3. In Organizer window:
   - Click **Distribute App**
   - Select **TestFlight & App Store** → Next
   - Select **Upload** → Next
   - Keep defaults → Next
   - Review → **Upload**
   - Wait for "Upload Successful"

### Step 3: Upload Asset Packs

You have 3 asset pack files:
- `Essential.aar`
- `Prefetch.aar`
- `OnDemand.aar`

**Using Transporter App (Easiest):**

1. Download **Transporter** from Mac App Store
2. Open Transporter
3. Drag and drop each `.aar` file into Transporter
4. Click **Deliver** for each file
5. Wait for upload to complete

**Using Command Line (Alternative):**

```bash
# Using iTMSTransporter
xcrun iTMSTransporter -m upload -f Essential.aar -u your@email.com
xcrun iTMSTransporter -m upload -f Prefetch.aar -u your@email.com
xcrun iTMSTransporter -m upload -f OnDemand.aar -u your@email.com
```

### Step 4: Wait for Processing

1. Go to https://appstoreconnect.apple.com
2. Go to **My Apps** → Your App → **TestFlight** tab
3. Wait for build to process (5-15 minutes)
4. Status will change from "Processing" to "Ready to Submit" or "Ready to Test"

### Step 5: Add Yourself as Tester

1. In App Store Connect → TestFlight tab
2. Click **Internal Testing** (left sidebar)
3. Click **+** next to Internal Testers
4. Add yourself (your Apple ID email)
5. The build should auto-select
6. Click **Add** → **Start Testing**

### Step 6: Install TestFlight & Test

**On your iPhone:**

1. Install **TestFlight** from App Store
2. Open TestFlight
3. You'll see "Background Assets Test" invitation
4. Tap **Install**
5. **Watch the installation:**
   - Essential asset downloads FIRST (before app icon appears)
   - App installs
   - Prefetch downloads in BACKGROUND

6. **Open the app and test:**
   - 🟢 **Essential:** Click "Check Asset" → Should show image1 immediately
   - 🟠 **Prefetch:** Click "Check Asset" → Should show image2 immediately
   - 🟣 **On-Demand:** Click "Download Asset" → Downloads NOW → Shows image3

---

## 🧪 Local Testing Setup

**⚠️ Note:** Local mock server only tests download mechanism. Essential/Prefetch won't auto-download - they download when you press buttons. For real behavior, use TestFlight.

### Step 1: Package Asset Packs

```bash
cd /Users/marin/Projects/applebgassets

# Package all three asset packs
xcrun ba-package AssetPacks/Essential/Manifest.json -o Essential.aar
xcrun ba-package AssetPacks/Prefetch/Manifest.json -o Prefetch.aar
xcrun ba-package AssetPacks/OnDemand/Manifest.json -o OnDemand.aar
```

### Step 2: Setup SSL Certificate

```bash
./setup-ssl-complete.sh
```

**This will:**
- Clean up old certificates
- Create new CA + Server certificates
- Import to Mac Keychain
- Create iOS profile: `ssl-cert/BGAssets-CA.mobileconfig`

### Step 3: Install Certificate on iPhone

1. **Remove old certificate (if you installed one before):**
   - Settings → General → VPN & Device Management
   - Remove old "Background Assets CA" profile
   - Settings → General → About → Certificate Trust Settings
   - Toggle OFF old certificate

2. **Install new certificate:**
   - AirDrop `ssl-cert/BGAssets-CA.mobileconfig` to iPhone
   - Tap file → Install → Enter passcode
   - Settings → General → About → Certificate Trust Settings
   - Toggle ON: **Background Assets CA**

### Step 4: Start Mock Server

```bash
cd /Users/marin/Projects/applebgassets
xcrun ba-serve --host 192.168.88.19 Essential.aar Prefetch.aar OnDemand.aar
```

**Note the port number** (e.g., `Listening on port 60382`)

When prompted for certificate, select: `192.168.88.19`

### Step 5: Configure URL Override on iPhone

1. **Enable Developer Mode:**
   - Settings → Privacy & Security → Developer Mode → ON
   - Restart iPhone

2. **Set URL Override:**
   - Settings → Developer → Background Assets Testing
   - Tap **Development Overrides**
   - **URL Override:** `https://192.168.88.19:[PORT]`
   - (Replace `[PORT]` with the port from ba-serve)

### Step 6: Run & Test

1. In Xcode, select your iPhone as destination
2. Build and Run (⌘R)
3. Test all three download policies

---

## 📁 Project Structure

```
applebgassets/
├── README.md                          # This file
├── setup-ssl-complete.sh              # SSL certificate setup for local testing
│
├── applebgassets/                     # Main app
│   ├── applebgassetsApp.swift
│   ├── ContentView.swift              # UI with 3 download policy cards
│   ├── AssetPackDownloadManager.swift # Download logic with debugging
│   └── Info.plist                     # Background Assets configuration
│
├── BackgroundDownloadExtension/       # Managed downloader extension
│   ├── BackgroundDownloadHandler.swift
│   ├── Info.plist
│   └── BackgroundDownloadExtension.entitlements
│
├── AssetPacks/                        # Source assets & manifests
│   ├── Essential/
│   │   ├── image1.jpg
│   │   └── Manifest.json
│   ├── Prefetch/
│   │   ├── image2.jpg
│   │   └── Manifest.json
│   └── OnDemand/
│       ├── image3.jpg
│       └── Manifest.json
│
├── Essential.aar                      # Packaged asset packs (for upload)
├── Prefetch.aar
├── OnDemand.aar
│
└── ssl-cert/                          # SSL certificates (for local testing)
    ├── BGAssets-CA.mobileconfig       # Install this on iPhone
    └── [other cert files]
```

## ⚙️ Configuration Details

### Info.plist Keys (Already Configured)

**App Target:**
- `BAAppGroupID`: `group.com.bgassetstestapp.learninglanguages.applebgassets`
- `BAHasManagedAssetPacks`: `YES`
- `BAUsesAppleHosting`: `YES`

### App Groups (Already Configured)

Both app and extension targets share:
- `group.com.bgassetstestapp.learninglanguages.applebgassets`

### Asset Pack IDs

| File | Asset Pack ID | Download Policy |
|------|---------------|-----------------|
| Essential.aar | `Essential` | essential |
| Prefetch.aar | `Prefetch` | prefetch |
| OnDemand.aar | `OnDemand` | onDemand |

## 🐛 Debugging

The app includes extensive logging with emoji prefixes:
- 🟢 Essential asset logs
- 🟠 Prefetch asset logs
- 🟣 OnDemand asset logs

**View logs in Xcode:**
- Show Debug Area: ⌘⇧Y
- Look for colored emoji logs

## 🔧 Troubleshooting

### Local Testing Issues

**"Certificate is invalid" error:**
- Make sure you installed `BGAssets-CA.mobileconfig` on iPhone
- Settings → General → About → Certificate Trust Settings → Toggle ON
- Restart ba-serve and select the correct certificate

**Assets not downloading:**
- Verify URL override matches: `https://[YOUR_MAC_IP]:[PORT]`
- Check ba-serve is still running
- Make sure iPhone and Mac are on same WiFi network

**ba-package command not found:**
- You need full Xcode installed (not just Command Line Tools)
- Run: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

### TestFlight Issues

**Build stuck in "Processing":**
- Wait 15-30 minutes
- Check email for any issues from Apple

**Assets not downloading automatically:**
- Only works on TestFlight/App Store, NOT local mock server
- Uninstall and reinstall from TestFlight to test fresh install

**Essential/Prefetch download when pressing buttons:**
- This is expected on local mock server
- Use TestFlight to see real automatic download behavior

## 📚 Apple Documentation

- [Background Assets Framework](https://developer.apple.com/documentation/backgroundassets)
- [Creating Managed Asset Packs](https://developer.apple.com/documentation/backgroundassets/creating-managed-asset-packs)
- [Testing Asset Packs Locally](https://developer.apple.com/documentation/backgroundassets/testing-asset-packs-locally)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

## 🎯 Testing Checklist

### Local Testing ✓
- [x] SSL certificate created and trusted
- [x] Mock server running
- [x] URL override configured
- [x] All three assets download and display

### TestFlight Testing
- [ ] App created in App Store Connect
- [ ] App build uploaded
- [ ] Asset packs uploaded (all 3 .aar files)
- [ ] Build processed and ready
- [ ] Added as internal tester
- [ ] Installed from TestFlight
- [ ] Essential downloads before launch
- [ ] Prefetch downloads in background
- [ ] OnDemand downloads on button press

## 📝 Notes

- **Deployment Target:** iOS 26.0+ (required for Apple-Hosted Background Assets)
- **Bundle ID:** `com.bgassetstestapp.learninglanguages.applebgassets`
- **Team ID:** UCWYJ55XX6
- **Local testing** shows download mechanism works
- **TestFlight testing** shows actual download policy behavior

---

## 🚀 Next Steps

1. ✅ Local testing complete (download/display works)
2. → Upload to TestFlight (see [TestFlight Setup](#testflight-setup))
3. → Test real download policies on device
4. → Ready for production!

**Good luck! 🎉**
