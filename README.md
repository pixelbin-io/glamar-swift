# GlamAR SDK Documentation for iOS

## Overview

GlamAR is a powerful Augmented Reality SDK for Android that enables virtual try-on experiences for makeup, jewelry, and other beauty products. The SDK provides an easy-to-integrate solution with real-time AR capabilities, face detection, and product visualization features.

## Features

- Real-time virtual makeup try-on
- Multiple product category support
- Camera and image-based preview modes
- Real-time face tracking and analysis
- Easy integration with Android applications
- Snapshot functionality
- High-performance WebView-based rendering
- Original/Modified view comparison
- Configurable parameters

## Installation

You can integrate GlamAR into your project using one of the following dependency managers:

### Swift Package Manager (SPM)

1. In Xcode, select "File" → "Add Packages..."
2. Enter the following URL in the search bar: <https://github.com/pixelbin-io/glamar-swift.git>
3. Select the version you want to use
4. Click "Add Package"

### CocoaPods

1. If you haven't already, install CocoaPods:

   ```bash
   gem install cocoapods
   ```

2. In your project directory, create a `Podfile` if you don't have one:

   ```bash
   pod init
   ```

3. Add the following line to your Podfile:

   ```ruby
   pod 'GlamAR'
   ```

4. Run the following command:

   ```bash
   pod install
   ```

5. Open the `.xcworkspace` file to work with your project in Xcode.

### Carthage

1. If you haven't already, install Carthage:

   ```bash
   brew install carthage
   ```

2. In your project directory, create a `Cartfile` if you don't have one:

   ```bash
   touch Cartfile
   ```

3. Add the following line to your Cartfile:

   ```ruby
   github "pixelbin-io/glamar-swift"
   ```

4. Run the following command:

   ```bash
   carthage update --use-xcframeworks
   ```

5. In your target's "General" settings, add the built `GlamAR.xcframework` from `Carthage/Build` to the "Frameworks, Libraries, and Embedded Content" section.

### Manual Installation

If you prefer not to use a dependency manager:

1. Download the latest release of GlamAR from the [releases page](https://github.com/pixelbin-io/glamar-swift/releases).
2. Drag and drop `GlamAR.framework` into your Xcode project.
3. In your target's "General" settings, add GlamAR under "Frameworks, Libraries, and Embedded Content".

### Dependencies

GlamAR depends on Alamofire. If you're using SPM, CocoaPods, or Carthage, this dependency will be automatically managed. If you're installing manually, ensure you also include Alamofire in your project.

After installation, import GlamAR in your Swift files:

```swift
import GlamAR
```

Now you're ready to use GlamAR in your project!

## Initialization

To use GlamAR in your iOS application, you need to initialize it with your access key. The initialization should be done when your app starts, typically in your `AppDelegate` or `SceneDelegate`.

```swift
import GlamAR

let overrides = GlamAROverrides(
    meta: ["sdkVersion" : "2.0.0"]
)

// In your AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize GlamAR with all available options
    GlamAr.initialize(
        accessKey: "YOUR_ACCESS_KEY",
        debug: true,  // Use debug environment (true) or production (false)
        bundleIdentifier: String = Bundle.main.bundleIdentifier ?? "", // Used for parent domain reference
        overrides: overrides) // Optional: Pass a pre-configured WKWebView
    )
    return true
}
```

### Configuration Options

- `accessKey`: Your unique access key for the GlamAR service (Required)
- `debug`: Boolean flag to switch between debug and production environments
  - `true`: Uses debug/staging environment (default)
  - `false`: Uses production environment
- `bundleIdentifier`: Parent domain reference
- `overrides`: Category configurations 

### Getting GlamAR Instance

After initialization, you can get the GlamAR instance using:

```swift
do {
    let glamAr = try GlamAr.getInstance()
    // Use glamAr instance
} catch GlamArError.notInitialized {
    print("GlamAR not initialized")
}
```

## GlamArWebViewManager

The `GlamArWebViewManager` is the main component for displaying AR content:

```swift
// Create a webview
let glamARWebView = GlamArWebViewManager.shared.getPreparedWebView()
view.addSubview(glamARWebView)
```

## Example Usage

Here's a complete example demonstrating the usage of `GlamAr` and `GlamArView`:

```swift
import UIKit
import GlamAR

class ViewController: UIViewController {
    private var showingOriginal = false

    @IBOutlet weak var glamARWebView: WKWebView!

    @IBAction func onApplyClick(_ sender: Any) {
        GlamAr.applyByCategory(category: "sunglasses")
    }

    @IBAction func onClearClick(_ sender: Any) {
        GlamAr.close()
    }
    
    @IBAction func onToggleClick(_ sender: Any) {
        GlamAr.skinAnalysis(options: "start")
    }

    @IBAction func onExportClick(_ sender: Any) {
        GlamAr.snapshot()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let webview = GlamArWebViewManager.shared.getPreparedWebView() {
            
            glamARWebView.addSubview(webview)
            
            webview.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                webview.topAnchor.constraint(equalTo: glamARWebView.topAnchor),
                webview.bottomAnchor.constraint(equalTo: glamARWebView.bottomAnchor),
                webview.leadingAnchor.constraint(equalTo: glamARWebView.leadingAnchor),
                webview.trailingAnchor.constraint(equalTo: glamARWebView.trailingAnchor)
            ])
        }
        
        GlamAr.addEventListener(event: "sku-applied") { (callbackValue) in
            print("sku-applied: \(callbackValue ?? "")")
        }
        
        GlamAr.addEventListener(event: "sku-failed") { (callbackValue) in
            print("sku-failef: \(callbackValue ?? "")")
        }
        
        GlamAr.addEventListener(event: "init-complete") { (callbackValue) in
            print("init-complete: \(callbackValue ?? "")")
        }
    }
}
```

## Permissions

Ensure you handle permissions appropriately, especially for camera access if using `PreviewMode.camera`. Add the necessary privacy usage descriptions to your `Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for AR features.</string>
```

## Conclusion

This document provides a comprehensive overview of the GlamAR SDK for iOS, detailing how to install, initialize, and use its various components. Use this as a reference to integrate AR features into your iOS application effectively.
