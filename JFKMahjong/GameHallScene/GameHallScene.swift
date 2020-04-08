//
//  GameHallScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit

class GameHallScene: SKScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
             let location = touch.location(in: self)
             let touchedNode = atPoint(location)
             if touchedNode.name == "start" {
                  print("start")
             }
            if touchedNode.name == "start", let scene = SKScene(fileNamed: "GuanNanMahjongScene") {
               let transition = SKTransition.flipVertical(withDuration: 1)
               view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
