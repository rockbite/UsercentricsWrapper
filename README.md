# Usercentrics SDK Wrapper for iOS

## Overview
This project provides a **UsercentricsWrapper** for integrating the [Usercentrics SDK](https://usercentrics.com/docs/apps/intro/) into iOS applications developed using LibGDX and RoboVM. The wrapper acts as a bridge between Java and the Usercentrics iOS SDK with handling SDK-related events via a delegate or callback.

## Installation

### Step 1: Build the project 
Build the project to generate UsercentricsWrapper-Swift.h

### Step 2: Export the Framework
Navigate to the project folder and run the following command in your terminal:

```bash
xcodebuild archive \
-scheme UsercentricsWrapper \
-destination "generic/platform=iOS" \
-archivePath ../output/UsercentricsWrapper \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES
```

### Step 3: Add the Framework to Your Project
Add `UsercentricsWrapper.framework`, `UsercentricsUI.framework`, and `Usercentrics.framework` into the project.
Copy the Resource Bundle into the project
