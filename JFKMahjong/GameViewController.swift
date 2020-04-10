//
//  GameViewController.swift
//  JFKMahjong
//
//  Created by build on 2020/3/27.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: JKViewController {
    
    enum SceneType {
        case gameLaunchScene, gameHallScene, guanNanMahjongScene
    }
    
    var skview: SKView {
        get {
            view as! SKView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presentScene(.gameLaunchScene)
        
        skview.ignoresSiblingOrder = true
        skview.showsFPS = true
        skview.showsNodeCount = true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Private
    private func presentScene(_ sceneType: SceneType) {
        var scene = SKScene()
        switch sceneType {
        case .gameLaunchScene:
            let launchScene = GameLaunchScene()
            launchScene.loginButtonClicked.sink { [weak self] in
                self?.presentScene(.gameHallScene)
            }.store(in: &cancellables)
            scene = launchScene
        case .gameHallScene:
            let hallScene = GameHallScene()
            hallScene.startButtonClicked.sink { [weak self] in
                self?.presentScene(.guanNanMahjongScene)
            }.store(in: &cancellables)
            scene = hallScene
        case .guanNanMahjongScene:
            let guannanScene = GuanNanMahjongScene()
            guannanScene.exitButtonClicked.sink { [weak self] in
                self?.presentScene(.gameHallScene)
            }.store(in: &cancellables)
            scene = guannanScene
        }
        scene.scaleMode = .aspectFill
        scene.size = view.bounds.size
        let transition = SKTransition.crossFade(withDuration: 1)
        skview.presentScene(scene, transition: transition)
    }
}
