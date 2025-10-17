//
//  SceneDelegate.swift
//  iOSWebViewAutomation
//
//  Created by EricWang on 2025/10/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        // 处理 UI Tests 的 Launch Arguments
        handleLaunchArguments()
    }

    // MARK: - Test Support

    /// 处理来自 UI Tests 的 Launch Arguments
    private func handleLaunchArguments() {
        let arguments = ProcessInfo.processInfo.arguments

        // 检查是否启用自动登录
        if arguments.contains("-AutoLogin"),
           let autoLoginIndex = arguments.firstIndex(of: "-AutoLogin"),
           autoLoginIndex + 1 < arguments.count,
           arguments[autoLoginIndex + 1] == "true" {

            // 获取用户名和密码
            var username = "testuser"
            var password = "password123"

            if let usernameIndex = arguments.firstIndex(of: "-Username"),
               usernameIndex + 1 < arguments.count {
                username = arguments[usernameIndex + 1]
            }

            if let passwordIndex = arguments.firstIndex(of: "-Password"),
               passwordIndex + 1 < arguments.count {
                password = arguments[passwordIndex + 1]
            }

            print("🧪 测试模式：自动登录")
            print("   用户名: \(username)")
            print("   密码: \(password)")

            // 延迟执行自动登录（等待 ViewController 加载完成）
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.performAutoLogin(username: username, password: password)
            }
        }

        // 检查是否启用测试按钮
        if arguments.contains("-EnableTestButtons") {
            print("🧪 测试模式：启用测试辅助按钮")
            // 可以在这里设置一个标志，让 ViewController 显示测试按钮
            UserDefaults.standard.set(true, forKey: "EnableTestButtons")
        }
    }

    /// 执行自动登录
    private func performAutoLogin(username: String, password: String) {
        // 通过 Notification 触发登录
        NotificationCenter.default.post(
            name: .webViewTestCommand,
            object: nil,
            userInfo: [
                "command": "autoLogin",
                "parameters": ["username": username, "password": password]
            ]
        )
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

