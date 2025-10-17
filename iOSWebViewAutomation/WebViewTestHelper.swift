//
//  WebViewTestHelper.swift
//  iOSWebViewAutomation
//
//  测试辅助类：用于在 UI Tests 中操作 WebView
//

import Foundation
import UIKit
import WebKit

class WebViewTestHelper {
    static let shared = WebViewTestHelper()

    private weak var viewController: ViewController?

    private init() {}

    /// 注册 ViewController
    func registerViewController(_ vc: ViewController) {
        self.viewController = vc
    }

    /// 处理来自 UI Tests 的命令
    func handleTestCommand(_ command: String, parameters: [String: String] = [:]) {
        guard let vc = viewController else {
            print("⚠️ ViewController 未注册")
            return
        }

        print("🔧 执行测试命令: \(command), 参数: \(parameters)")

        switch command {
        case "fillUsername":
            if let username = parameters["value"] {
                vc.fillUsername(username) { success in
                    print("✅ 填充用户名: \(success)")
                }
            }

        case "fillPassword":
            if let password = parameters["value"] {
                vc.fillPassword(password) { success in
                    print("✅ 填充密码: \(success)")
                }
            }

        case "clickLogin":
            vc.clickLoginButton() { success in
                print("✅ 点击登录按钮: \(success)")
                // 等待一下让登录处理完成，然后更新 statusLabel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    vc.getResultText { _ in
                        // statusLabel 已经在 getResultText 中更新
                    }
                }
            }

        case "clickClear":
            vc.clickClearButton() { success in
                print("✅ 点击清除按钮: \(success)")
            }

        case "autoLogin":
            // 自动登录：填充用户名、密码并点击登录
            let username = parameters["username"] ?? "testuser"
            let password = parameters["password"] ?? "password123"

            vc.fillUsername(username) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    vc.fillPassword(password) { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            vc.clickLoginButton() { success in
                                print("✅ 自动登录完成: \(success)")
                                // 等待一下让登录处理完成，然后更新 statusLabel
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    vc.getResultText { _ in
                                        // statusLabel 已经在 getResultText 中更新
                                    }
                                }
                            }
                        }
                    }
                }
            }

        default:
            print("⚠️ 未知命令: \(command)")
        }
    }
}

// MARK: - 通过 Notification 来触发命令
extension Notification.Name {
    static let webViewTestCommand = Notification.Name("WebViewTestCommand")
}

extension WebViewTestHelper {
    /// 开始监听测试命令
    func startListening() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification(_:)),
            name: .webViewTestCommand,
            object: nil
        )
    }

    @objc private func handleNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let command = userInfo["command"] as? String {
            let parameters = userInfo["parameters"] as? [String: String] ?? [:]
            handleTestCommand(command, parameters: parameters)
        }
    }
}
