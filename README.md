# GlamAR SDK Documentation for iOS

## Overview

The GlamAR SDK provides tools to integrate augmented reality (AR) features into your iOS application. This document covers the installation, initialization, and usage of the SDK, including details about `GlamArView` API, and `GlamAr` instance API.

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

// In your AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Initialize GlamAR with all available options
    GlamAr.initialize(
        accessKey: "YOUR_ACCESS_KEY",
        debug: true,  // Use debug environment (true) or production (false)
        previewMode: .none  // Optional: Set preview mode (.none, .camera, or .image("URL"))
    )
    return true
}
```

### Configuration Options

- `accessKey`: Your unique access key for the GlamAR service (Required)
- `debug`: Boolean flag to switch between debug and production environments
  - `true`: Uses debug/staging environment (default)
  - `false`: Uses production environment
- `previewMode`: Sets the preview mode for AR visualization (Optional)
  - `.none`: Default mode
  - `.camera`: Camera preview mode
  - `.image("URL")`: Image preview mode with specified URL

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

## API Reference

### GlamArApi

The `GlamArApi` class provides methods to interact with the GlamAR backend services.

```swift
// Initialize the API
let api = GlamArApi(accessKey: "your_access_key", debug: true)

// Fetch SKU List
api.fetchSkuList(pageNo: 1, pageSize: 10) { result in
    switch result {
    case .success(let response):
        // Handle SKU list response
        print("Total items: \(response.page.itemTotal)")
        print("Items: \(response.items)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Fetch Single SKU
api.fetchSku(id: "sku_id") { result in
    switch result {
    case .success(let item):
        // Handle single SKU response
        print("SKU: \(item)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Data Models

#### SkuListResponse
```swift
public struct SkuListResponse {
    public let page: Page
    public let items: [Item]
}
```

#### Page
```swift
public struct Page {
    public let type: String
    public let size: Int
    public let current: Int
    public let hasNext: Bool
    public let itemTotal: Int
}
```

#### Item
```swift
public struct Item {
    public let id: String
    public let orgId: Int
    public let category: String
    public let subCategory: String
    public let productName: String?
    public let productImage: String?
    public let vendor: String?
    public let isActive: Bool?
}
```

## GlamArView

The `GlamArView` is the main component for displaying AR content:

```swift
// Create a GlamArView
let glamArView = GlamArView(frame: view.bounds)
view.addSubview(glamArView)

// Start preview with specific mode
glamArView.startPreview(previewMode: .camera) // or .none or .image("URL")

// The view will automatically handle camera permissions when needed
```

### Preview Modes

GlamArView supports different preview modes:

- `.none`: Default mode without any specific preview
- `.camera`: Uses device camera for AR preview
- `.image(String)`: Uses a specific image URL for preview

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
