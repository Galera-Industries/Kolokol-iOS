//
//  SceneDelegate.swift
//  Kolokol
//
//  Created by Арсений Потякин on 20.09.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let uiwindow = UIWindow(windowScene: windowScene)
        window = uiwindow
        let keychain = KeychainManager()
        keychain.save(key: KeychainManager.keyForSaveAccessToken, value: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiI0bXF1YVB4OE9vT3dFZUNoS05DZGw5RnV0ZGYyIiwiZW1haWwiOiJpc2FldjJrMThAZ21haWwuY29tIiwicm9sZSI6InN0dWRlbnQiLCJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU5MTkyNTU2LCJpYXQiOjE3NTg5MzMzNTZ9.u0OA_15gs3xf3irNvUytTwbqsdybcXLD9d7QbEkZz14")
        window?.rootViewController = UINavigationController(rootViewController: TestsListMainAssembly.build(role: "student"))
        window?.makeKeyAndVisible()
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

