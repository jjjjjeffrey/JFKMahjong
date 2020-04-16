//
//  GameLaunchScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class GameLaunchScene: JKScene {
    
    var loginButtonClicked = PassthroughSubject<Void, Never>()
    
    override func didMove(to view: SKView) {
        let loginButton = JKButtonNode()
        loginButton.setTitle("登录", for: .normal)
        loginButton.position = CGPoint(x: view.width/2,
                                      y:view.height/2)
        loginButton.clicked.sink { [weak self] button in
            self?.loginButtonClicked.send()
        }.store(in: &cancellables)
        addChild(loginButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
