# Project Structure Guide

## 📁 Directory Structure

Your project has a nested structure:

```
D:\vishnu\flutter_projects\easy_voice-main\          ← Workspace Root (outer directory)
└── easy_voice-main\                                  ← Flutter Project Root (inner directory)
    ├── lib\                                          ← Dart source code
    ├── android\                                      ← Android platform files
    ├── ios\                                          ← iOS platform files
    ├── pubspec.yaml                                  ← Flutter dependencies
    └── ...
```

## ⚠️ Important: Project Root

**The actual Flutter project root is:** `easy_voice-main/easy_voice-main/`

This is where `pubspec.yaml` is located, and where you should run Flutter commands.

## ✅ Solutions Implemented

### 1. VS Code Workspace File
Created `easy_voice-main.code-workspace` in the workspace root. This file:
- Points to the correct Flutter project directory
- Configures proper settings for Flutter/Dart development
- Excludes build artifacts from search

**To use it:**
- Open VS Code
- File → Open Workspace from File
- Select `easy_voice-main.code-workspace`

### 2. Updated VS Code Settings
Updated `.vscode/settings.json` in the Flutter project with:
- Proper file exclusions
- Search exclusions for build artifacts
- Java configuration for Android development

### 3. Fixed Android Gradle Configuration
- Removed outdated Kotlin buildscript block
- Paths in `android/app/build.gradle` are correct (`source '../..'` resolves properly)

## 🚀 How to Work with This Project

### Option 1: Use the Workspace File (Recommended)
1. Open `easy_voice-main.code-workspace` in VS Code
2. All paths will resolve correctly
3. Run Flutter commands from the terminal in VS Code

### Option 2: Navigate to Project Root
When running Flutter commands from terminal:
```powershell
cd easy_voice-main
flutter pub get
flutter run
```

### Option 3: Open Inner Directory Directly
Open `D:\vishnu\flutter_projects\easy_voice-main\easy_voice-main\` as your workspace root in VS Code.

## 📝 Path Resolution Explained

### Android Gradle Paths
- `android/app/build.gradle` uses `source '../..'`
  - From `android/app/` → up 2 levels → Flutter project root ✅
- `android/settings.gradle` uses `file("local.properties")`
  - From `android/` → `local.properties` ✅

### Why This Structure?
This nested structure likely occurred when:
- Extracting a ZIP file that contained a folder named `easy_voice-main`
- The extracted folder was placed in a directory also named `easy_voice-main`

## 🔧 Verification

To verify everything is working:
```powershell
cd easy_voice-main
flutter doctor
flutter pub get
flutter build apk
```

All commands should work from the `easy_voice-main/easy_voice-main/` directory.

