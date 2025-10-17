//
//  WebViewLoginTests.swift
//  iOSWebViewAutomationUITests
//
//  实用的 WebView 登录测试示例
//  使用 Launch Arguments 来触发 App 中的测试辅助方法
//

import XCTest

final class WebViewLoginTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - 测试场景

    /// 测试成功登录
    @MainActor
    func testSuccessfulLogin() throws {
        // 启动 App 并传递自动登录参数
        app.launchArguments = [
            "-AutoLogin", "true",
            "-Username", "testuser",
            "-Password", "password123"
        ]
        app.launch()

        // 等待 WebView 加载
        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView 应该加载")

        // 等待登录完成
        sleep(4)

        // 验证登录成功消息（通过原生 statusLabel）
        let statusLabel = app.staticTexts["statusLabel"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 5), "状态标签应该存在")
        XCTAssertEqual(statusLabel.label, "登录成功！", "应该显示登录成功消息")

        print("✅ 登录测试通过")
    }

    /// 测试失败登录
    @MainActor
    func testFailedLogin() throws {
        app.launchArguments = [
            "-AutoLogin", "true",
            "-Username", "wronguser",
            "-Password", "wrongpass"
        ]
        app.launch()

        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        sleep(4)

        // 验证错误消息（通过原生 statusLabel）
        let statusLabel = app.staticTexts["statusLabel"]
        XCTAssertTrue(statusLabel.waitForExistence(timeout: 5), "状态标签应该存在")
        XCTAssertEqual(statusLabel.label, "用户名或密码错误", "应该显示错误消息")

        print("✅ 失败登录测试通过")
    }

    /// 测试基本页面加载
    @MainActor
    func testBasicPageLoad() throws {
        app.launch()

        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView 应该存在")

        // 等待页面加载
        sleep(2)

        // 验证页面元素
        XCTAssertTrue(webView.staticTexts["测试登录页面"].exists, "标题应该存在")
        XCTAssertTrue(webView.staticTexts["用户名"].exists, "用户名标签应该存在")
        XCTAssertTrue(webView.staticTexts["密码"].exists, "密码标签应该存在")

        print("✅ 页面加载测试通过")
    }

    /// 测试手动填充（通过辅助按钮）
    @MainActor
    func testManualFillWithHelper() throws {
        app.launchArguments = ["-EnableTestButtons", "true"]
        app.launch()

        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        sleep(2)

        // 如果 App 中添加了测试辅助按钮，可以通过这些按钮来触发操作
        // 例如：app.buttons["FillUsernameButton"].tap()

        print("✅ 手动填充测试设置完成")
    }
}

// MARK: - 真实场景测试
extension WebViewLoginTests {

    /// 测试完整的登录流程
    @MainActor
    func testCompleteLoginFlow() throws {
        app.launch()

        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        sleep(2)

        // 这里演示如何在实际测试中操作 WebView
        // 注意：直接操作 WebView 内部元素比较困难
        // 最好的方式是通过我们实现的 JavaScript bridge

        print("✅ 完整流程测试框架已就绪")
        print("💡 提示：在实际使用中，可以通过以下方式操作 WebView：")
        print("   1. 使用 Launch Arguments 触发 App 中的测试辅助方法")
        print("   2. 在 App 中添加隐藏的测试按钮（仅在测试模式下显示）")
        print("   3. 使用 evaluateJavaScript 直接操作 HTML 元素")
    }

    /// 性能测试：登录操作的响应时间
    @MainActor
    func testLoginPerformance() throws {
        app.launch()

        let webView = app.webViews["mainWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        sleep(2)

        measure {
            // 这里可以测量登录操作的性能
            // 例如：点击登录按钮到显示结果的时间
            print("📊 性能测量中...")
        }
    }
}
