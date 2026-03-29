# Info.plist Configuration for Qibla Feature

## Required Permissions

Add these keys to your `Info.plist` file:

### 1. Location Permission (Already exists for prayer times)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Kıble yönü ve namaz vakitleri için konumunuz kullanılır.</string>
```

### 2. Motion Permission (For compass calibration)
```xml
<key>NSMotionUsageDescription</key>
<string>Pusula için hareket sensörü kullanılır.</string>
```

## How to Add in Xcode:

1. Open your project in Xcode
2. Select the target (VakitNiyet)
3. Go to "Info" tab
4. Hover over any row and click the "+" button
5. Add the keys above with their values

## Alternative: Edit Info.plist directly

If you see Info.plist file in your project:
1. Right-click on Info.plist
2. Open As > Source Code
3. Add the XML entries above inside the `<dict>` tag

## Testing Permissions:

1. Run the app
2. Go to Qibla view
3. You should see permission request
4. Grant "Allow While Using App"
5. Compass should start working

## Notes:

- Location permission is shared with prayer times feature
- Motion permission is specifically for compass heading
- Both permissions are "when in use" only (not background)

## Troubleshooting:

**Problem:** Permission not showing
**Solution:** 
- Clean build folder (⌘ + Shift + K)
- Delete app from device/simulator
- Rebuild and run

**Problem:** Compass not working
**Solution:**
- Must test on real device (simulator doesn't have compass)
- Check that CLLocationManager.headingAvailable() returns true
