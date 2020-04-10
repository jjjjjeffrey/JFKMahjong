//
//  JKScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/10.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class JKScene: SKScene {
    var cancellables: Set<AnyCancellable> = []
    
    deinit {
        cancellables.forEach { (cancellable) in
            cancellable.cancel()
        }
    }
}
