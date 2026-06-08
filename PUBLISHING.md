# GlamAR SDK Publishing Guide

This is a minimal guide for publishing the GlamAR Swift SDK to CocoaPods.

## Prerequisites

- Ensure you have the latest version code ready
- Update the version number in `GlamAR.podspec`
- Create and push a git tag matching the version

## Publishing Steps

### 1. Validate the Podspec

```bash
pod spec lint GlamAR.podspec
```

### 2. Set Up Authentication

```bash
pod trunk register dev@pixelbin.io 'PixelBin Team' --description='GlamAR SDK Publishing'
# Follow the verification link sent to the dev@pixelbin.io email
# Note: You need to be added to this email group to access the verification link
```

### 3. Publish to CocoaPods

```bash
pod trunk push GlamAR.podspec
```

### 4. Verify Publication

Check that your package is available on CocoaPods:

- [CocoaPods GlamAR Page](https://cocoapods.org/pods/GlamAR)
- Or run: `pod search GlamAR`

## Troubleshooting

If you encounter authentication issues:

- Verify your token is correct and not expired
- Run `pod trunk me` to check your session status
- If needed, register again with `pod trunk register`

For validation errors:

- Check that your git tag exactly matches the version in the podspec
- Ensure all required files are included in the repository
- Verify that dependencies like Alamofire (version ~> 5.9.1) are correctly specified
