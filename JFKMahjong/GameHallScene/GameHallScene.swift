//
//  GameHallScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class GameHallScene: JKScene {
    
    var startButtonClicked = PassthroughSubject<Void, Never>()
    
    override func didMove(to view: SKView) {
        let startButton = JKButtonNode()
        startButton.setTitle("创建房间", for: .normal)
        startButton.position = CGPoint(x: view.width/2,
                                      y:view.height/2)
        startButton.clicked.sink { [weak self] button in
            self?.startButtonClicked.send()
        }.store(in: &cancellables)
        addChild(startButton)
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
