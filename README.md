# GlamAR SDK Documentation for iOS

## Overview

The GlamAR SDK provides tools to integrate augmented reality (AR) features into your iOS application. This document covers the installation, initialization, and usage of the SDK, including details about `GlamArView` API, and `GlamAr` instance API.

## Installation

You can integrate GlamAR into your project using one of the following dependency managers:

### Swift Package Manager (SPM)

1. In Xcode, select "File" → "Add Packages..."
2. Enter the following URL in the search bar: https://github.com/pixelbin-io/glamar-swift.git
3. Select the version you want to use
4. Click "Add Package"

### CocoaPods

1. If you haven't already, install CocoaPods:
   ```
   $ gem install cocoapods
   ```

2. In your project directory, create a `Podfile` if you don't have one:
   ```
   $ pod init
   ```

3. Add the following line to your Podfile:
   ```ruby
   pod 'GlamAR'
   ```

4. Run the following command:
   ```
   $ pod install
   ```

5. Open the `.xcworkspace` file to work with your project in Xcode.

### Carthage

1. If you haven't already, install Carthage:
   ```
   $ brew install carthage
   ```

2. In your project directory, create a `Cartfile` if you don't have one:
   ```
   $ touch Cartfile
   ```

3. Add the following line to your Cartfile:
   ```
   github "pixelbin-io/glamar-swift"
   ```

4. Run the following command:
   ```
   $ carthage update --use-xcframeworks
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

### Initialize SDK in AppDelegate

Initialize the SDK in your `AppDelegate` to ensure it's set up when your app starts. By default, it will be pointing to development; set `development` to `false` for production.

```swift
import GlamAR

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GlamAr.initialize(accessKey: "YOUR_ACCESS_KEY", development: false)
        return true
    }
}
```

## GlamArView

### Setup

To use `GlamArView`, add it to your view hierarchy:

```swift
import GlamAR

class ViewController: UIViewController {
    @IBOutlet weak var glamArView: GlamArView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup GlamArView
    }
}
```

### Starting Preview

Start the preview in various modes using `startPreview`:

```swift
glamArView.startPreview(previewMode: .none)
glamArView.startPreview(previewMode: .camera)
glamArView.startPreview(previewMode: .image("IMAGE_URL"), isBeauty: false)
```

### Applying SKUs

Apply a SKU to the `GlamArView`:

```swift
glamArView.applySku(skuId: "SKU_ID", category: "CATEGORY")
```

### Clearing View

Clear the `GlamArView`:

```swift
glamArView.clear()
```

### Taking Snapshot

Take a snapshot of the current view:

```swift
glamArView.snapshot()
```

### Toggling Original/AR View

Toggle between the original and AR-applied view:

```swift
glamArView.toggle(showOriginal: showingOriginal)
```

## GlamAr Instance API

### Fetch SKU List

Fetch a list of SKUs:

```swift
GlamAr.getInstance().api.fetchSkuList(pageNo: 1, pageSize: 100) { result in
    switch result {
    case .success(let skuListResponse):
        // Handle success
    case .failure(let error):
        // Handle failure
    }
}
```

### Fetch Specific SKU

Fetch details of a specific SKU:

```swift
GlamAr.getInstance().api.fetchSku(id: "SKU_ID") { result in
    switch result {
    case .success(let item):
        // Handle success
    case .failure(let error):
        // Handle failure
    }
}
```

## Example Usage

Here's a complete example demonstrating the usage of `GlamAr` and `GlamArView`:

```swift
import UIKit
import GlamAR

class ViewController: UIViewController {
    private var showingOriginal = false

    @IBOutlet weak var glamArView: GlamArView!

    @IBAction func onApplyClick(_ sender: Any) {
        self.glamArView.applySku(skuId: "666b311f-1b34-4082-99d1-c525451b44a1", category: "beauty")
    }
    
    @IBAction func onClearClick(_ sender: Any) {
        self.glamArView.clear()
    }
    
    @IBAction func onToggleClick(_ sender: Any) {
        showingOriginal = !showingOriginal
        self.glamArView.toggle(showOriginal: showingOriginal)
    }
    
    @IBAction func onExportClick(_ sender: Any) {
        self.glamArView.snapshot()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.glamArView.startPreview(previewMode: .none)
        // Alternatively:
        // self.glamArView.startPreview(previewMode: .camera)
        // self.glamArView.startPreview(previewMode: .image("IMAGE_URL"), isBeauty: false)
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
