//
//  JKButtonNode.swift
//  JFKMahjong
//
//  Created by build on 2020/4/9.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class JKButtonNode: SKNode {
    
    var clicked = PassthroughSubject<Void, Never>()
    
    private lazy var labelNode: SKLabelNode = {
        let node = SKLabelNode(text: "Button")
        return node
    }()
    
    private var stateTitles: [State: String] = [:] {
        didSet {
            labelNode.text = stateTitles[state]
        }
    }
    
    private(set) var state: State = .normal
    
    override init() {
        super.init()
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String?, for state: State) {
        if stateTitles.isEmpty {
            stateTitles[.normal] = title
            stateTitles[.disabled] = title
            stateTitles[.selected] = title
            stateTitles[.highlighted] = title
        } else {
            stateTitles[state] = title
        }
        labelNode.position = CGPoint(x: 0, y: 0)
        
        addChild(labelNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        clicked.send()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}

extension JKButtonNode {
    enum State {
        case normal, disabled, selected, highlighted
    }
}
