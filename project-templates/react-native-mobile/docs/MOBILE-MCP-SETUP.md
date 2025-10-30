# Mobile MCP Setup Guide

## Overview

This template uses **Mobile MCP** (`@mobilenext/mobile-mcp`) to enable Claude Code to directly control iOS simulators, Android emulators, and real devices for automated testing and development assistance.

### What is Mobile MCP?

Mobile MCP is a platform-agnostic mobile automation server that provides Claude Code with 17 tools for interacting with mobile devices:
- Device management (list, launch, install apps)
- UI interaction (tap, type, swipe, long press)
- Screen inspection (accessibility tree, screenshots)
- Device control (orientation, hardware buttons, deep links)

### Trust Score: 6.5/10

**Note**: Mobile MCP has a moderate trust score (6.5/10). This is acceptable for development and testing, but always review automated actions before executing on production devices.

## Benefits

### Development Workflow Enhancement

**Old Workflow** (Manual Testing):
```
1. Write React Native feature
2. Manually open simulator
3. Manually navigate to feature
4. Manually test interactions
5. Manually check for bugs
6. Repeat for iOS and Android separately
7. Document test results manually

Time: 30-40 minutes per feature
```

**New Workflow** (Mobile MCP):
```
1. Write React Native feature
2. Ask Claude Code: "Test the login screen on iPhone 15"
3. Mobile MCP automatically:
   - Lists available devices
   - Launches app
   - Captures screen elements
   - Performs interactions
   - Takes screenshots for validation
4. Receive test results in conversation

Time: 10-15 minutes per feature
Time Saved: 60-65% per feature
```

### Cross-Platform Testing

**Single API for iOS and Android**:
- Write test once, run on both platforms
- Consistent element detection (accessibility tree)
- Same screenshot capabilities
- Unified device management

**Example**:
```
# Test on iOS
"Test registration on iPhone 15 Pro simulator"

# Same test on Android
"Test registration on Pixel 7 emulator"

Mobile MCP handles platform differences automatically
```

### BMad QA Integration

Mobile MCP enables the QA agent to test mobile apps (similar to Playwright MCP for web):
- E2E test scenarios in markdown
- QA agent executes via Mobile MCP tools
- Screenshots automatically captured
- Results documented in gate files

## Prerequisites

### Required Tools

1. **Node.js 18+** and npm
2. **Expo CLI**: `npm install -g expo-cli`
3. **iOS Simulator** (Mac only):
   - Xcode installed
   - At least one simulator downloaded
4. **Android Emulator** (optional):
   - Android Studio installed
   - At least one AVD (Android Virtual Device) created
5. **Claude Code** with project directory open

### Check Prerequisites

```bash
# Verify Node.js
node --version  # Should be 18.x or higher

# Verify Expo CLI
expo --version

# List iOS simulators (Mac only)
xcrun simctl list devices available

# List Android emulators
emulator -list-avds

# Verify Claude Code MCPs
# In Claude Code:
/mcp
# Should show: mobile-mcp
```

## Quick Start

### Step 1: Install Dependencies

```bash
# From project root
npm install
```

This installs React Native, Expo, and all dependencies.

### Step 2: Start Expo Development Server

```bash
npm start
```

**Verify**: Metro bundler starts and shows QR code

### Step 3: Launch App on Simulator

**iOS (Mac only)**:
```bash
npm run ios
```

**Android**:
```bash
npm run android
```

**Expo Go** (Real device):
1. Install Expo Go from App Store / Play Store
2. Scan QR code from terminal

### Step 4: Verify Mobile MCP

```bash
# In Claude Code
/mcp
```

You should see:
- **mobile-mcp** - Mobile device automation (17 tools)

### Step 5: Test Mobile MCP

In Claude Code, try:

```
"List all available devices"
```

Mobile MCP will execute `mobile_list_available_devices` and show:
- iPhone 15 Pro (iOS 17.0) - Booted
- Pixel 7 (API 33) - Shutdown

```
"Take a screenshot of the current screen"
```

Mobile MCP will capture and return screenshot image.

## Mobile MCP Tools Reference

### Device Management Tools

#### mobile_list_available_devices
Lists all connected devices, simulators, and emulators.

**Example**:
```
"Show me all available devices"
```

**Output**:
```
Available Devices:
1. iPhone 15 Pro (iOS 17.0) - Booted
2. iPhone 14 (iOS 16.4) - Shutdown
3. iPad Pro 12.9" (iOS 17.0) - Booted
4. Pixel 7 (Android 13, API 33) - Shutdown
```

#### mobile_launch_app
Launches app by bundle ID.

**Parameters**:
- `bundleId` - App bundle identifier (e.g., `com.yourapp.mobile`)
- `deviceId` - Device to launch on (optional, uses booted device if omitted)

**Example**:
```
"Launch the app on iPhone 15 Pro"
```

**Bundle ID**: Find in `app.json` → `expo.ios.bundleIdentifier` or `expo.android.package`

#### mobile_install_app
Installs app from .app (iOS) or .apk (Android) file.

**Parameters**:
- `appPath` - Absolute path to .app or .apk file
- `deviceId` - Device to install on

**Example**:
```
"Install the latest build on iPhone 15 Pro"
# Mobile MCP: mobile_install_app("/path/to/YourApp.app", "iPhone-15-Pro")
```

#### mobile_terminate_app
Stops running app.

**Parameters**:
- `bundleId` - App to terminate

**Example**:
```
"Stop the app"
# Mobile MCP: mobile_terminate_app("com.yourapp.mobile")
```

#### mobile_uninstall_app
Removes app from device.

**Parameters**:
- `bundleId` - App to uninstall
- `deviceId` - Device to uninstall from

**Example**:
```
"Uninstall the app from Pixel 7"
# Mobile MCP: mobile_uninstall_app("com.yourapp.mobile", "Pixel-7")
```

### UI Interaction Tools

#### mobile_click_on_screen_at_coordinates
Taps at specific x,y coordinates.

**Parameters**:
- `x` - X coordinate
- `y` - Y coordinate
- `deviceId` - Device to tap on (optional)

**Example**:
```
"Tap the login button at coordinates (200, 400)"
# Mobile MCP: mobile_click_on_screen_at_coordinates(200, 400)
```

**How to Find Coordinates**:
1. Use `mobile_list_elements_on_screen` to get element positions
2. Use `mobile_take_screenshot` and visually estimate
3. Use accessibility labels (preferred method)

#### mobile_type_keys
Enters text into focused input field.

**Parameters**:
- `text` - Text to type
- `deviceId` - Device to type on (optional)

**Example**:
```
"Type 'test@example.com' into the email field"
# First tap email field, then:
# Mobile MCP: mobile_type_keys("test@example.com")
```

#### mobile_swipe_on_screen
Performs swipe gesture.

**Parameters**:
- `direction` - up, down, left, right
- `startX` - Start X coordinate
- `startY` - Start Y coordinate
- `endX` - End X coordinate
- `endY` - End Y coordinate
- `deviceId` - Device to swipe on (optional)

**Example**:
```
"Swipe up to scroll down the page"
# Mobile MCP: mobile_swipe_on_screen("up", 200, 600, 200, 200)
```

#### mobile_long_press_on_screen_at_coordinates
Long press at coordinates.

**Parameters**:
- `x` - X coordinate
- `y` - Y coordinate
- `duration` - Duration in milliseconds (default: 1000)
- `deviceId` - Device to long press on (optional)

**Example**:
```
"Long press the message at (200, 300) to show context menu"
# Mobile MCP: mobile_long_press_on_screen_at_coordinates(200, 300, 1500)
```

#### mobile_double_tap_on_screen
Double taps at coordinates.

**Parameters**:
- `x` - X coordinate
- `y` - Y coordinate
- `deviceId` - Device to double tap on (optional)

**Example**:
```
"Double tap the image to zoom"
# Mobile MCP: mobile_double_tap_on_screen(200, 400)
```

### Screen Inspection Tools

#### mobile_list_elements_on_screen
Returns accessibility tree of current screen.

**Parameters**:
- `deviceId` - Device to inspect (optional)

**Example**:
```
"List all UI elements on the screen"
```

**Output**:
```
Elements on Screen:
1. Button - "Login" (x: 180, y: 400, width: 120, height: 44)
2. TextInput - "Email" (x: 50, y: 200, width: 300, height: 44)
3. TextInput - "Password" (x: 50, y: 280, width: 300, height: 44)
4. Text - "Forgot Password?" (x: 250, y: 460, width: 100, height: 20)
```

**Use Case**: Find coordinates for tapping or verify UI layout

#### mobile_take_screenshot
Captures screenshot and returns base64 image.

**Parameters**:
- `deviceId` - Device to screenshot (optional)

**Example**:
```
"Take a screenshot of the current screen"
```

**Output**: Base64 encoded PNG image (displayed in Claude Code)

#### mobile_save_screenshot
Saves screenshot to file.

**Parameters**:
- `filePath` - Absolute path to save screenshot
- `deviceId` - Device to screenshot (optional)

**Example**:
```
"Save screenshot to /tmp/login_screen.png"
# Mobile MCP: mobile_save_screenshot("/tmp/login_screen.png")
```

#### mobile_get_screen_size
Returns device screen dimensions.

**Parameters**:
- `deviceId` - Device to query (optional)

**Example**:
```
"What's the screen size?"
```

**Output**:
```
Screen Size: 393 x 852 (iPhone 15 Pro)
```

### Device Control Tools

#### mobile_press_button
Presses hardware buttons.

**Parameters**:
- `button` - home, volumeUp, volumeDown, power, back (Android), menu (Android)
- `deviceId` - Device to control (optional)

**Example**:
```
"Press the home button"
# Mobile MCP: mobile_press_button("home")

"Press back button to go to previous screen"
# Mobile MCP: mobile_press_button("back")  # Android only
```

#### mobile_open_url
Opens deep link or URL.

**Parameters**:
- `url` - Deep link (yourapp://...) or URL (https://...)
- `deviceId` - Device to open on (optional)

**Example**:
```
"Open the profile screen via deep link"
# Mobile MCP: mobile_open_url("yourapp://profile")

"Open website in Safari"
# Mobile MCP: mobile_open_url("https://example.com")
```

#### mobile_set_orientation
Changes device orientation.

**Parameters**:
- `orientation` - portrait, landscape, portraitUpsideDown, landscapeLeft, landscapeRight
- `deviceId` - Device to rotate (optional)

**Example**:
```
"Rotate to landscape mode"
# Mobile MCP: mobile_set_orientation("landscape")
```

#### mobile_get_orientation
Gets current device orientation.

**Parameters**:
- `deviceId` - Device to query (optional)

**Example**:
```
"What's the current orientation?"
```

**Output**: `portrait`, `landscape`, etc.

## Development Workflow

### Standard Development Cycle

**Step 1: Dev Implements Feature**

```bash
/BMad/agents/dev
*develop-story docs/stories/2.1.story.md
```

Dev writes:
- React Native components
- Navigation logic
- API integration
- **E2E test scenarios** (markdown format)

**Step 2: Dev Writes E2E Scenarios**

```markdown
# E2E Test Scenarios: User Login

## TC1.1: Successful Login

**Priority**: P0 (Critical)

**Steps**:
1. Launch app on iPhone 15 Pro simulator
2. Verify login screen is displayed
3. Tap email input field at (180, 200)
4. Type "test@example.com"
5. Tap password input field at (180, 280)
6. Type "password123"
7. Tap "Login" button at (200, 400)
8. Wait 2 seconds for API response

**Expected Result**:
- User redirected to dashboard screen
- Welcome message displays "Welcome, Test User!"
- Dashboard shows user data

**Screenshots**:
- TC1.1_step1_login_screen.png
- TC1.1_step8_dashboard.png

**API Verification**:
- POST /api/auth/login returns 200
- Response includes valid JWT token
```

**Step 3: Dev Outputs QA Handoff**

```markdown
## QA Handoff

**Story**: 2.1 - User Login Feature
**Status**: Ready for QA
**Branch**: feature/user-login

**Test Scenarios**: docs/qa/e2e/sprint-1/epics/epic-2/story-1/

**Testing Requirements**:
1. Run E2E scenarios on iOS (iPhone 15 Pro)
2. Run E2E scenarios on Android (Pixel 7)
3. Verify API integration (GET /api/users/me after login)
4. Test with invalid credentials (TC1.2)
5. Test with network error simulation (TC1.3)

**Prerequisites**:
- Backend running on http://localhost:3000
- Test user exists: test@example.com / password123
- Mobile app built and installed on simulators

**Dev Notes**:
- Login uses JWT token stored in AsyncStorage
- Token auto-refresh implemented (expires in 24h)
- Offline mode caches last known user data
```

**Step 4: QA Executes Tests via Mobile MCP**

```bash
/BMad/agents/qa
*review docs/stories/2.1.story.md
```

QA uses Mobile MCP interactively:

```
QA: "Launch the app on iPhone 15 Pro simulator"
Mobile MCP: mobile_launch_app("com.yourapp.mobile", "iPhone-15-Pro")
→ App launched successfully

QA: "Take a screenshot of the current screen"
Mobile MCP: mobile_take_screenshot()
→ [Screenshot shows login screen]

QA: "List all UI elements on the screen"
Mobile MCP: mobile_list_elements_on_screen()
→ TextInput "Email" at (180, 200)
→ TextInput "Password" at (180, 280)
→ Button "Login" at (200, 400)

QA: "Tap the email field and enter test@example.com"
Mobile MCP: mobile_click_on_screen_at_coordinates(180, 200)
Mobile MCP: mobile_type_keys("test@example.com")
→ Text entered

QA: "Tap the password field and enter password123"
Mobile MCP: mobile_click_on_screen_at_coordinates(180, 280)
Mobile MCP: mobile_type_keys("password123")
→ Text entered

QA: "Tap the Login button"
Mobile MCP: mobile_click_on_screen_at_coordinates(200, 400)
→ Button tapped

QA: "Wait 2 seconds then take screenshot"
Mobile MCP: mobile_take_screenshot()
→ [Screenshot shows dashboard with "Welcome, Test User!"]

QA: "Verify the API was called correctly - check backend logs"
[QA switches to backend terminal or uses API Server MCP]

QA: "Rotate to landscape and verify layout"
Mobile MCP: mobile_set_orientation("landscape")
Mobile MCP: mobile_take_screenshot()
→ [Screenshot shows landscape dashboard]
```

**Step 5: QA Creates Gate File**

```yaml
# docs/qa/gates/2.1-user-login.yml
story: 2.1
title: User Login Feature
status: PASS
assessed_by: Quinn (QA Agent)
assessed_date: 2025-10-29

test_results:
  - scenario: TC1.1
    status: PASS
    platform: iOS (iPhone 15 Pro)
    notes: Login successful, dashboard displayed correctly
    screenshots:
      - TC1.1_step1_login_screen.png
      - TC1.1_step8_dashboard.png

  - scenario: TC1.1
    status: PASS
    platform: Android (Pixel 7)
    notes: Login successful, consistent with iOS

  - scenario: TC1.2
    status: PASS
    notes: Invalid credentials properly rejected, error message shown

  - scenario: TC1.3
    status: PASS
    notes: Network error handled gracefully, retry option displayed

overall_assessment: |
  All test scenarios passed on both iOS and Android.
  API integration verified successfully.
  Landscape orientation works correctly.
  Ready for deployment.
```

## Advanced Use Cases

### Testing Deep Links

```
"Open the app via deep link yourapp://profile/123"
# Mobile MCP: mobile_open_url("yourapp://profile/123")
# Verify: Profile screen for user 123 is displayed
```

### Testing Push Notifications

```
"Simulate push notification"
# Use Expo CLI: expo send-notification --token={device-token}

"Tap the notification when it appears"
# Mobile MCP: mobile_click_on_screen_at_coordinates(200, 50)
```

### Testing Offline Mode

```
"Turn off WiFi on the simulator"
# iOS: System Settings → WiFi → Off
# Android: Settings → Network → WiFi → Off

"Launch the app and verify offline mode"
# Mobile MCP: mobile_launch_app()
# Mobile MCP: mobile_take_screenshot()
# Verify: "You're offline" banner displayed
```

### Testing Accessibility

```
"Enable VoiceOver and test screen reader navigation"
# iOS Settings → Accessibility → VoiceOver → On

"List all accessibility elements"
# Mobile MCP: mobile_list_elements_on_screen()
# Verify: All elements have proper accessibility labels
```

### Testing Gestures

```
"Test pull-to-refresh gesture"
# Mobile MCP: mobile_swipe_on_screen("down", 200, 100, 200, 400)
# Verify: Refresh indicator shows, data reloads

"Test swipe-to-delete on list item"
# Mobile MCP: mobile_swipe_on_screen("left", 350, 200, 50, 200)
# Verify: Delete button appears
```

## Troubleshooting

### Issue: Mobile MCP Tools Not Available

**Error**: `/mcp` doesn't show `mobile-mcp`

**Solution**:
1. Verify `.mcp.json` is configured correctly
2. Restart Claude Code
3. Check Claude Code logs for MCP server errors
4. Ensure `@mobilenext/mobile-mcp` can be installed: `npx @mobilenext/mobile-mcp@latest --version`

### Issue: Device Not Found

**Error**: `mobile_list_available_devices` returns empty list

**Solution**:

**iOS**:
```bash
# List simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot "iPhone 15 Pro"

# Verify simulator is booted
xcrun simctl list | grep Booted
```

**Android**:
```bash
# List emulators
emulator -list-avds

# Start emulator
emulator -avd Pixel_7_API_33

# Verify device is connected
adb devices
```

### Issue: App Not Launching

**Error**: `mobile_launch_app` fails

**Solution**:
1. Verify app is installed: Check device home screen
2. Check bundle ID is correct:
   - iOS: `app.json` → `expo.ios.bundleIdentifier`
   - Android: `app.json` → `expo.android.package`
3. Reinstall app: `npm run ios` or `npm run android`
4. Check app permissions (location, camera, etc.) are granted

### Issue: UI Elements Not Found

**Error**: `mobile_list_elements_on_screen` returns empty or incomplete list

**Solution**:
1. Ensure app is using proper accessibility labels:
   ```tsx
   <TouchableOpacity accessible={true} accessibilityLabel="Login Button">
     <Text>Login</Text>
   </TouchableOpacity>
   ```
2. Check if custom components expose accessibility
3. Use `mobile_take_screenshot` to manually verify UI
4. Fall back to coordinate-based tapping if needed

### Issue: Screenshots Are Blank

**Error**: `mobile_take_screenshot` returns blank image

**Solution**:
1. Wait for screen to fully render before screenshot
2. Check if app is in background (bring to foreground)
3. Verify simulator display is on (not sleeping)
4. iOS: Check simulator Graphics Quality settings

### Issue: Typing Not Working

**Error**: `mobile_type_keys` doesn't enter text

**Solution**:
1. Ensure input field is focused first:
   ```
   "Tap email field then type email"
   # mobile_click_on_screen_at_coordinates(180, 200)
   # Wait 500ms
   # mobile_type_keys("test@example.com")
   ```
2. iOS: Check keyboard is visible on simulator
3. Android: Enable "Show soft keyboard" in emulator settings

### Issue: Real Device Not Connecting

**Error**: Real device doesn't appear in device list

**Solution**:

**iOS**:
1. Connect iPhone/iPad via USB
2. Trust computer on device
3. Check Xcode recognizes device: Xcode → Window → Devices and Simulators
4. Enable Developer Mode: Settings → Privacy & Security → Developer Mode

**Android**:
1. Enable USB Debugging: Settings → Developer Options → USB Debugging
2. Connect via USB
3. Accept RSA fingerprint on device
4. Verify: `adb devices` shows device

## Performance Tips

### Optimize Test Execution

**Use Element Detection Instead of Coordinates**:
```
# Slow (requires visual estimation)
"Tap the login button at (200, 400)"

# Fast (uses accessibility tree)
"List elements, find Login button, tap it"
# mobile_list_elements_on_screen()
# mobile_click_on_screen_at_coordinates({x from element})
```

**Batch Operations**:
```
# Slow (multiple MCP calls)
"Tap email field"
"Type email"
"Tap password field"
"Type password"
"Tap login button"

# Fast (batch in single request)
"Fill login form with email test@example.com and password password123, then tap login"
# Mobile MCP executes all steps in sequence
```

### Screenshot Optimization

**Only capture when needed**:
- ✅ Before critical actions (baseline)
- ✅ After critical actions (validation)
- ✅ On errors (debugging)
- ❌ After every single step (slow, storage-heavy)

**Use saved screenshots sparingly**:
```
# Development: View in Claude Code (no file saved)
"Take screenshot"

# QA Documentation: Save for test reports
"Save screenshot to docs/qa/screenshots/TC1.1_login.png"
```

## BMad Integration

### QA Agent Commands

QA agent uses Mobile MCP automatically when reviewing mobile stories:

```bash
/BMad/agents/qa
*review docs/stories/2.1.story.md
```

QA agent will:
1. Read E2E scenarios from story
2. Use Mobile MCP to execute test steps
3. Capture screenshots for validation
4. Verify expected results
5. Create gate file (PASS/FAIL/CONCERNS)

### Dev Agent Integration

Dev agent references Mobile MCP when writing E2E scenarios:

```bash
/BMad/agents/dev
*develop-story docs/stories/2.1.story.md
```

Dev agent knows:
- Available Mobile MCP tools (17 tools)
- Markdown test scenario format
- When to use coordinates vs. accessibility tree
- Screenshot best practices

## Comparison: Manual vs. Mobile MCP

### Manual Testing Workflow

```
1. Dev writes feature (30 min)
2. Dev manually opens simulator (2 min)
3. Dev manually navigates to feature (3 min)
4. Dev manually tests (10 min)
5. Dev documents test in Notion/Jira (5 min)
6. QA reads documentation (5 min)
7. QA manually repeats test on iOS (10 min)
8. QA manually repeats test on Android (10 min)
9. QA documents results (5 min)

Total Time: ~80 minutes
Human Interaction: Constant
Error Prone: Yes (manual steps)
```

### Mobile MCP Workflow

```
1. Dev writes feature (30 min)
2. Dev writes E2E scenarios in markdown (5 min)
3. Dev outputs QA Handoff (1 min)
4. QA activates agent (1 min)
5. QA asks: "Test login on iOS" (30 sec)
   → Mobile MCP executes all steps automatically
6. QA asks: "Test login on Android" (30 sec)
   → Mobile MCP executes all steps automatically
7. QA creates gate file (3 min)

Total Time: ~41 minutes
Human Interaction: Minimal
Error Prone: No (automated, repeatable)

Time Saved: 49% per feature
```

## Security Considerations

### Trust Score: 6.5/10

Mobile MCP has a moderate trust score. Follow these guidelines:

**Development/Staging**: ✅ Safe to use
- Testing on simulators/emulators
- Local development devices
- Internal test builds

**Production**: ⚠️ Use with caution
- Never run automated tests on production devices with real user data
- Review all MCP actions before executing
- Disable Mobile MCP in production `.mcp.json`

### Best Practices

1. **Isolate test data**: Use separate backend environment for testing
2. **Review before executing**: Always understand what MCP will do
3. **Limit device access**: Only connect test devices to Mobile MCP
4. **Monitor actions**: Log all Mobile MCP operations during testing
5. **Disable in production**: Remove Mobile MCP from production config

## Next Steps

1. **Complete backend setup**: Follow backend template README
2. **Configure API integration**: Set `API_BASE_URL` in `.env`
3. **Write first E2E scenario**: Use template in `docs/qa/e2e/`
4. **Test Mobile MCP**: Ask Claude Code to execute scenario
5. **Integrate with BMad**: Use Dev + QA agents for workflow

## Resources

- **Mobile MCP GitHub**: https://github.com/mobile-next/mobile-mcp
- **React Native Testing**: https://reactnative.dev/docs/testing-overview
- **Expo Testing**: https://docs.expo.dev/develop/unit-testing/
- **iOS Simulator**: https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device
- **Android Emulator**: https://developer.android.com/studio/run/emulator
- **BMad Testing Guide**: `.bmad-core/data/testing-stack-guide.md`
