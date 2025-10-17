# iOS WebView Automation Testing Project

A complete iOS WebView automation testing sample project that demonstrates how to test HTML pages in WKWebView using XCTest and JavaScript Bridge.

## Project Highlights

### Implemented Solutions

- **Solution 1**: JavaScript Bridge + evaluateJavaScript
  - Execute JavaScript directly from Swift to manipulate HTML elements
  - Precise control over WebView interactions

- **Solution 3**: Accessibility Label Injection
  - Automatically add aria-label attributes to HTML elements
  - Improve accessibility and test reliability

- **Solution 4**: Native Status Label Bridge (Core Solution)
  - Use native UILabel as a bridge between WebView state and UI testing
  - Solve the fundamental issue of XCUITest not being able to access WebView internal elements
  - Real-time synchronization of WebView state to native UI elements

### Core Features

1. **WKWebView Integration**
   - Load local HTML test pages
   - Bidirectional JavaScript and Swift communication
   - Automatic accessibility label injection

2. **Test Helper System**
   - `WebViewTestHelper`: Unified test command handler
   - Launch Arguments support: Control app behavior from UI Tests
   - Notification mechanism: Cross-component communication

3. **Complete Test Suite**
   - Basic page load testing
   - Automated login testing
   - Error handling testing
   - Performance testing

## Project Structure

```
iOSWebViewAutomation/
├── iOSWebViewAutomation/              # Main App Target
│   ├── ViewController.swift           # Main view controller (contains WKWebView)
│   ├── WebViewTestHelper.swift        # Test helper class
│   ├── SceneDelegate.swift            # Launch Arguments handler
│   ├── test_login.html                # Local test page
│   └── ...
│
└── iOSWebViewAutomationUITests/       # UI Tests Target
    ├── iOSWebViewAutomationUITests.swift
    ├── WebViewLoginTests.swift        # Login test cases
    └── ...
```

## Getting Started

### 1. Open the Project

```bash
cd /Users/apple/Work/iOSWebViewAutomation
open iOSWebViewAutomation.xcodeproj
```

### 2. Add HTML File to Xcode

**Important**: Manually add `test_login.html` to the Xcode project:

1. Right-click on the project folder in Xcode
2. Select "Add Files to iOSWebViewAutomation..."
3. Choose the `test_login.html` file
4. Make sure "Copy items if needed" and target are checked

### 3. Run the App

- Select simulator or physical device
- Click the run button (⌘R)
- You should see the local HTML login page

### 4. Run Tests

#### Option 1: Via Xcode

- Select Product > Test (⌘U)
- Or click the play button in the test navigator

#### Option 2: Run Specific Tests

- Open `WebViewLoginTests.swift`
- Click the diamond icon next to the test method

### 5. Test Credentials

```
Username: testuser
Password: password123
```

## Test Methods

### Basic Tests

```swift
// Test if WebView is loaded
func testWebViewLoaded()

// Test if page elements exist
func testPageTitleExists()

// Test basic page loading
func testBasicPageLoad()
```

### Login Tests

```swift
// Test successful login
func testSuccessfulLogin()

// Test failed login
func testFailedLogin()

// Test auto-fill credentials
func testAutoFillCredentials()

// Test login with empty fields
func testLoginWithEmptyFields()
```

### Performance Tests

```swift
// Test login performance
func testLoginPerformance()
```

## Core Technical Implementation

### 1. JavaScript Execution

```swift
// ViewController.swift
func fillUsername(_ username: String, completion: ((Bool) -> Void)? = nil) {
    let js = "document.getElementById('username').value = '\(username)';"
    webView.evaluateJavaScript(js) { _, error in
        completion?(error == nil)
    }
}
```

### 2. Accessibility Label Injection

```swift
func injectAccessibilityLabels(completion: ((Bool) -> Void)? = nil) {
    let js = """
    document.getElementById('username').setAttribute('aria-label', 'usernameField');
    document.getElementById('password').setAttribute('aria-label', 'passwordField');
    // ...
    """
    webView.evaluateJavaScript(js) { _, error in
        completion?(error == nil)
    }
}
```

### 3. Launch Arguments Handling

```swift
// SceneDelegate.swift
app.launchArguments = [
    "-AutoLogin", "true",
    "-Username", "testuser",
    "-Password", "password123"
]
```

### 4. JavaScript to Swift Communication

```swift
// JavaScript (test_login.html)
window.webkit.messageHandlers.loginHandler.postMessage({
    status: 'success',
    username: username
});

// Swift (ViewController.swift)
func userContentController(_ userContentController: WKUserContentController,
                          didReceive message: WKScriptMessage) {
    if message.name == "loginHandler" {
        // Handle message
    }
}
```

### 5. Native Status Label Bridge (Core Technology)

**Problem**: XCUITest cannot directly access HTML elements inside WebView

**Solution**: Use native UILabel as a bridge

```swift
// ViewController.swift - Create hidden status label
statusLabel = UILabel()
statusLabel.textColor = .clear  // Invisible to users
statusLabel.accessibilityIdentifier = "statusLabel"
statusLabel.isAccessibilityElement = true

// Sync update when WebView state changes
func userContentController(_ userContentController: WKUserContentController,
                          didReceive message: WKScriptMessage) {
    if let status = body["status"] as? String {
        DispatchQueue.main.async { [weak self] in
            if status == "success" {
                self?.statusLabel.text = "Login successful!"
            }
        }
    }
}

// Access native label in UI tests
let statusLabel = app.staticTexts["statusLabel"]
XCTAssertEqual(statusLabel.label, "Login successful!")
```

**Advantages**:
- ✅ UI tests can directly access native elements
- ✅ Real-time sync of WebView state
- ✅ No impact on user interface
- ✅ Stable and reliable testing

## Extension Suggestions

### 1. Add More Test Scenarios

- Form validation testing
- Network request interception
- Cookie and LocalStorage testing
- Page navigation testing

### 2. Integrate with CI/CD

```bash
# Run tests from command line
xcodebuild test \
  -project iOSWebViewAutomation.xcodeproj \
  -scheme iOSWebViewAutomation \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### 3. Test Real Websites

Modify the `loadTestPage()` method in `ViewController.swift`:

```swift
private func loadTestPage() {
    if let url = URL(string: "https://your-website.com") {
        webView.load(URLRequest(url: url))
    }
}
```

### 4. Add Test Helper Buttons

Show hidden buttons in test mode for manual test triggering:

```swift
if UserDefaults.standard.bool(forKey: "EnableTestButtons") {
    // Show test buttons
}
```

## Common Issues

### Q1: WebView elements cannot be recognized?

**A**: This is normal! XCUITest cannot directly recognize HTML elements inside WebView. Solutions:
- Use JavaScript Bridge (evaluateJavaScript)
- Inject accessibility labels
- Control app behavior via Launch Arguments
- **Recommended**: Use Native Status Label bridge solution (see Core Technical Implementation #5)

### Q2: How to debug JavaScript code?

**A**:
1. Enable developer menu in Safari
2. Connect simulator/device
3. Safari > Develop > [Device Name] > [App Name]

### Q3: Tests are unstable and fail frequently?

**A**:
- Increase wait time (`sleep(2)`)
- Use `waitForExistence(timeout:)` instead of direct access
- Ensure page is fully loaded before executing operations

### Q4: How to test actual login flow?

**A**:
- Use test environment URL
- Use test accounts (don't use production accounts)
- Consider network latency, increase timeout

## Tech Stack

- Swift 5.0+
- iOS 14.0+
- WKWebView
- XCTest
- XCUITest

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License

## Author

Ying Hao Wang

## Test Results

✅ **All Tests Passed** - Verified on Physical Device

```
Test Statistics:
- Total Executed: 18 tests
- Passed: 18 ✅
- Failed: 0
- Total Time: 135.8 seconds
- Result: TEST SUCCEEDED
```

Key Test Cases:
- ✅ testSuccessfulLogin - Successful login test
- ✅ testFailedLogin - Failed login test
- ✅ testAutoLogin - Auto login test
- ✅ testLoginWithWrongCredentials - Wrong credentials test
- ✅ testLoginWithEmptyFields - Empty fields test
- ✅ testWebViewLoaded - WebView loading test
- ✅ testPageTitleExists - Page elements test
- ✅ testLoginPerformance - Performance test

## Changelog

### 2025-10-17 v1.1 - Status Label Bridge Solution
- ✅ Implemented Native Status Label bridge technology
- ✅ Solved XCUITest unable to access WebView internal elements issue
- ✅ Fixed all UI test failures
- ✅ Verified all tests pass on physical device (18/18)
- ✅ Updated test cases to use statusLabel
- ✅ Added complete technical documentation

### 2025-10-17 v1.0 - Initial Release
- ✨ Implemented Solution 1: JavaScript Bridge + evaluateJavaScript
- ✨ Implemented Solution 3: Accessibility label injection
- ✨ Created complete testing framework
- ✨ Support for Launch Arguments control
- ✨ Implemented bidirectional JavaScript-Swift communication
