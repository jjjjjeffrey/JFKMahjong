//
//  AppSceneDelegate.swift
//  JFKMahjong
//
//  Created by build on 2020/4/20.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import UIKit
import SwiftUI


class AppSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window : UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let nativeSize = windowScene.screen.nativeBounds.size
        windowScene.sizeRestrictions?.minimumSize = nativeSize
        windowScene.sizeRestrictions?.maximumSize = nativeSize
        

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = GameViewController()
        
        
        self.window = window
        window.makeKeyAndVisible()
        
        #if targetEnvironment(macCatalyst)
        if let titlebar = windowScene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
        #endif
    }
}
