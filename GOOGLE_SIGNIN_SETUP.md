# Google Sign-In Setup Guide

This guide will help you configure Google Sign-In for both Web PWA and Android.

## Prerequisites

1. **Enable Google Sign-In in Firebase Console:**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select the **reptigramfirestore** project (ReptiGram Firebase - used for authentication)
   - Navigate to **Authentication** > **Sign-in method**
   - Click on **Google** and enable it
   - Save the **Web client ID** that appears

## Finding Your Google OAuth Web Client ID

### Method 1: Firebase Console (Easiest)
1. Go to Firebase Console > Authentication > Sign-in method
2. Click on Google provider
3. The **Web client ID** is displayed (format: `XXXXX-XXXXX.apps.googleusercontent.com`)

### Method 2: Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **reptigramfirestore**
3. Navigate to **APIs & Services** > **Credentials**
4. Find the **OAuth 2.0 Client ID** for **Web application** type
5. Copy the **Client ID** (format: `XXXXX-XXXXX.apps.googleusercontent.com`)

## Configuration Steps

### 1. Update Firebase Configuration

Edit `lib/config/firebase_config.dart` and replace the placeholder:

```dart
static const String googleWebClientId = 'YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com';
```

Replace `YOUR_ACTUAL_CLIENT_ID` with the actual client ID from Firebase Console.

### 2. Update Web Index HTML

Edit `web/index.html` and update the meta tag:

```html
<meta name="google-signin-client_id" content="YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com">
```

Replace `YOUR_ACTUAL_CLIENT_ID` with the same client ID.

### 3. Android Configuration

#### Step 1: Add Android App to ReptiGram Firebase Console

**IMPORTANT: You MUST use the ReptiGram Firebase project (reptigramfirestore), NOT the RepFiles Firebase project!**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. **Select the `reptigramfirestore` project** (ReptiGram Firebase - used for authentication)
   - ⚠️ **NOT** `repfiles-prototype` (that's for data storage only)
3. Click the gear icon ⚙️ next to "Project Overview" → **Project settings**
4. Scroll down to **Your apps** section
5. If you don't see an Android app, click **Add app** → Choose **Android** icon
6. Enter the following:
   - **Android package name**: `com.example.repfiles_firestore`
   - **App nickname** (optional): RepFiles Android
   - **Debug signing certificate SHA-1**: `EF:C5:C4:AE:3A:DF:A6:DA:9E:63:D8:0D:2F:88:9E:44:85:1A:F4:74`
   - **Debug signing certificate SHA-256**: `6D:CD:E8:3B:E1:6F:C4:02:61:FB:E9:97:43:B8:BF:05:25:3A:32:06:55:D1:6F:45:71:0A:10:29:28:00:57:D4`
7. Click **Register app**
8. **Download** the `google-services.json` file
9. **Place the file** in: `android/app/google-services.json`
   - This file must be from the **reptigramfirestore** project (for Google Sign-In to work)

#### Step 2: Register SHA-1 Fingerprint (if app already exists in ReptiGram Firebase)

If the Android app already exists in the **reptigramfirestore** project:
1. Go to **reptigramfirestore** project → **Project settings** → **Your apps** → Select your Android app
2. Click **Add fingerprint** button
3. Add both fingerprints:
   - **SHA-1**: `EF:C5:C4:AE:3A:DF:A6:DA:9E:63:D8:0D:2F:88:9E:44:85:1A:F4:74`
   - **SHA-256**: `6D:CD:E8:3B:E1:6F:C4:02:61:FB:E9:97:43:B8:BF:05:25:3A:32:06:55:D1:6F:45:71:0A:10:29:28:00:57:D4`
4. Click **Save**
5. If prompted, download the updated `google-services.json` and replace the one in `android/app/`

**Your fingerprints for reference:**
- **SHA-1**: `EF:C5:C4:AE:3A:DF:A6:DA:9E:63:D8:0D:2F:88:9E:44:85:1A:F4:74`
- **SHA-256**: `6D:CD:E8:3B:E1:6F:C4:02:61:FB:E9:97:43:B8:BF:05:25:3A:32:06:55:D1:6F:45:71:0A:10:29:28:00:57:D4`

## Testing

### Web PWA:
1. Run `flutter run -d chrome`
2. Click "Continue with Google" button
3. You should see Google Sign-In popup

### Android:
1. Run `flutter run -d android`
2. Click "Continue with Google" button
3. Native Google Sign-In should appear

## Troubleshooting

### Error: "ClientID not set"
- Make sure you've replaced the placeholder in `lib/config/firebase_config.dart`
- Make sure you've updated the meta tag in `web/index.html`
- Verify the client ID format is correct (ends with `.apps.googleusercontent.com`)

### Error: "Popup blocked"
- Allow popups for your localhost/domain
- Check browser popup settings

### Error: "Sign-in failed" on Android
- Verify `google-services.json` exists in `android/app/`
- Make sure Google Sign-In is enabled in Firebase Console
- Check that the package name matches in Firebase Console

## Notes

- **Web PWA**: Requires explicit client ID configuration
- **Android**: Uses client ID from `google-services.json` automatically
- Both platforms authenticate through **ReptiGram Firebase** (reptigramfirestore project)
- User data is stored in **RepFiles Firebase** (repfiles-prototype project)

