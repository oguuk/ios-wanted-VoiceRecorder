//
//  SceneDelegate.swift
//  VoiceRecorder
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowScene = windowScene
        
        let rootViewController = AudioListViewController()
        let recordPermissionManager: RecordPermissionManageable = RecordPermissionManager()
        rootViewController.recordPermissionManager = recordPermissionManager
        window?.rootViewController = UINavigationController(
            rootViewController: rootViewController
        )
        
        window?.makeKeyAndVisible()
    }
}
