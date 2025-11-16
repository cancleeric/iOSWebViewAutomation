//
//  ViewController.swift
//  iOSWebViewAutomation
//
//  Created by EricWang on 2025/10/17.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    // MARK: - Properties
    var webView: WKWebView!
    var statusLabel: UILabel!  // Native label for UI testing

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadTestPage()

        // 注册到测试辅助类
        WebViewTestHelper.shared.registerViewController(self)
        WebViewTestHelper.shared.startListening()
    }

    // MARK: - Setup
    private func setupWebView() {
        // 配置 WKWebView
        let configuration = WKWebViewConfiguration()

        // 设置消息处理器（用于接收来自 JavaScript 的消息）
        let contentController = WKUserContentController()
        contentController.add(self, name: "loginHandler")
        configuration.userContentController = contentController

        // 创建 WebView
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self

        // 设置 accessibility identifier 用于 UI 测试
        webView.accessibilityIdentifier = "mainWebView"

        view.addSubview(webView)

        // 创建原生状态标签（用于 UI 测试识别 WebView 内部状态）
        statusLabel = UILabel()
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.textAlignment = .center
        statusLabel.textColor = .clear  // 隐藏但可被 UI 测试访问
        statusLabel.accessibilityIdentifier = "statusLabel"
        statusLabel.isAccessibilityElement = true
        statusLabel.text = ""
        view.addSubview(statusLabel)

        // 设置约束（放在屏幕外但仍然可访问）
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusLabel.widthAnchor.constraint(equalToConstant: 1),
            statusLabel.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func loadTestPage() {
        // 檢查啟動參數，決定載入哪個頁面
        let args = ProcessInfo.processInfo.arguments

        if args.contains("-LoadSudoku") {
            // 載入數讀遊戲
            loadSudokuGame()
        } else {
            // 預設載入登入測試頁面
            if let htmlPath = Bundle.main.path(forResource: "test_login", ofType: "html") {
                let url = URL(fileURLWithPath: htmlPath)
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
            } else {
                print("無法找到 test_login.html 檔案")
            }
        }
    }

    private func loadSudokuGame() {
        // 載入數讀遊戲 - 從 Docker 容器
        // Docker 容器運行在 http://localhost:8078
        // Port 8078 已在 Squid 系統 config/ports.py 中註冊為 SUDOKU_GAME_PORT

        let sudokuURL = URL(string: "http://localhost:8078")!
        let request = URLRequest(url: sudokuURL)
        webView.load(request)
        print("✅ 開始載入數讀遊戲: \(sudokuURL.absoluteString)")

        // 備註：也可以使用本地檔案方式（需要將 sudoku 資料夾加入 Xcode 專案）
        // if let sudokuPath = Bundle.main.path(forResource: "sudoku/index", ofType: "html") {
        //     let url = URL(fileURLWithPath: sudokuPath)
        //     let sudokuDir = url.deletingLastPathComponent().deletingLastPathComponent()
        //     webView.loadFileURL(url, allowingReadAccessTo: sudokuDir)
        //     print("✅ 成功載入數讀遊戲: \(url.path)")
        // }
    }

    // MARK: - 测试辅助方法（方案 1：evaluateJavaScript）

    /// 填充用户名
    func fillUsername(_ username: String, completion: ((Bool) -> Void)? = nil) {
        let js = "document.getElementById('username').value = '\(username)';"
        webView.evaluateJavaScript(js) { _, error in
            completion?(error == nil)
        }
    }

    /// 填充密码
    func fillPassword(_ password: String, completion: ((Bool) -> Void)? = nil) {
        let js = "document.getElementById('password').value = '\(password)';"
        webView.evaluateJavaScript(js) { _, error in
            completion?(error == nil)
        }
    }

    /// 点击登录按钮
    func clickLoginButton(completion: ((Bool) -> Void)? = nil) {
        let js = "document.getElementById('loginButton').click();"
        webView.evaluateJavaScript(js) { _, error in
            completion?(error == nil)
        }
    }

    /// 点击清除按钮
    func clickClearButton(completion: ((Bool) -> Void)? = nil) {
        let js = "document.getElementById('clearButton').click();"
        webView.evaluateJavaScript(js) { _, error in
            completion?(error == nil)
        }
    }

    /// 获取结果文本
    func getResultText(completion: @escaping (String?) -> Void) {
        let js = "document.getElementById('result').textContent;"
        webView.evaluateJavaScript(js) { [weak self] result, error in
            if let text = result as? String {
                // 同时更新原生标签以便 UI 测试访问
                DispatchQueue.main.async {
                    self?.statusLabel.text = text
                }
                completion(text)
            } else {
                completion(nil)
            }
        }
    }

    /// 检查登录是否成功
    func isLoginSuccessful(completion: @escaping (Bool) -> Void) {
        let js = "document.getElementById('result').classList.contains('success');"
        webView.evaluateJavaScript(js) { result, error in
            completion((result as? Bool) ?? false)
        }
    }

    /// 注入 accessibility 标识（方案 3）
    func injectAccessibilityLabels(completion: ((Bool) -> Void)? = nil) {
        let js = """
        (function() {
            document.getElementById('username').setAttribute('aria-label', 'usernameField');
            document.getElementById('password').setAttribute('aria-label', 'passwordField');
            document.getElementById('loginButton').setAttribute('aria-label', 'loginButton');
            document.getElementById('clearButton').setAttribute('aria-label', 'clearButton');
            document.getElementById('result').setAttribute('aria-label', 'resultLabel');
            return true;
        })();
        """
        webView.evaluateJavaScript(js) { _, error in
            completion?(error == nil)
        }
    }
}

// MARK: - WKNavigationDelegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("✅ 页面加载完成")
        // 页面加载完成后注入 accessibility 标识
        injectAccessibilityLabels { success in
            print("Accessibility labels injected: \(success)")
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ 页面加载失败: \(error.localizedDescription)")
    }
}

// MARK: - WKScriptMessageHandler
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 处理来自 JavaScript 的消息
        if message.name == "loginHandler", let body = message.body as? [String: Any] {
            print("📩 收到来自 JS 的消息: \(body)")

            if let status = body["status"] as? String {
                // 更新原生标签以便 UI 测试访问
                DispatchQueue.main.async { [weak self] in
                    if status == "success" {
                        print("✅ 登录成功")
                        self?.statusLabel.text = "登录成功！"
                    } else {
                        print("❌ 登录失败")
                        // 获取具体的错误消息
                        self?.getResultText { text in
                            // statusLabel 已经在 getResultText 中更新
                        }
                    }
                }
            }
        }
    }
}

