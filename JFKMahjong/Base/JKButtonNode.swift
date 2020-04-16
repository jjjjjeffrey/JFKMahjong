//
//  JKButtonNode.swift
//  JFKMahjong
//
//  Created by build on 2020/4/9.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine
import SwifterSwift

class JKButtonNode: SKNode {
    
    var clicked = PassthroughSubject<JKButtonNode, Never>()
    
    var tag: Int = 0
    
    private lazy var labelNode: SKLabelNode = {
        let node = SKLabelNode(text: "Button")
        node.fontColor = stateColors[.normal] ?? UIColor(hex: 0x0091FF)
        return node
    }()
    
    private lazy var spriteNode: SKSpriteNode = {
        let node = SKSpriteNode()
        return node
    }()
    
    private var stateTitles: [State: String] = [:] {
        didSet {
            labelNode.text = stateTitles[state]
        }
    }
    
    private var stateColors: [State: UIColor?] = [.normal: UIColor(hex: 0x0091FF), .disabled: UIColor(hex: 0x6D7278), .selected: UIColor(hex: 0x32C5FF), .highlighted: UIColor(hex: 0x32C5FF)] {
        didSet {
            labelNode.fontColor = stateColors[state] ?? UIColor(hex: 0x0091FF)
        }
    }
    
    private var stateImages: [State: String] = [:] {
        didSet {
            spriteNode.texture = SKTexture(imageNamed: stateImages[state] ?? "")
        }
    }
    
    private(set) var state: State = .normal {
        didSet {
            labelNode.fontColor = stateColors[state] ?? UIColor(hex: 0x0091FF)
            spriteNode.texture = SKTexture(imageNamed: stateImages[state] ?? "")
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            state = isEnabled ? .normal : .disabled
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            state = isSelected ? .normal : .selected
        }
    }
    
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
    
    func setTextColor(_ color: UIColor?, for state: State) {
        if stateColors.isEmpty {
            stateColors[.normal] = color
            stateColors[.disabled] = color
            stateColors[.selected] = color
            stateColors[.highlighted] = color
        } else {
            stateColors[state] = color
        }
        labelNode.position = CGPoint(x: 0, y: 0)
        
        addChild(labelNode)
    }
    
    func setImage(_ imageName: String?, size: CGSize, for state: State) {
        if stateImages.isEmpty {
            stateImages[.normal] = imageName
            stateImages[.disabled] = imageName
            stateImages[.selected] = imageName
            stateImages[.highlighted] = imageName
        } else {
            stateImages[state] = imageName
        }
        spriteNode.size = size
        spriteNode.position = CGPoint(x: 0, y: 0)
        
        addChild(spriteNode)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled {
            clicked.send(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}

extension JKButtonNode {
    enum State {
        case normal, disabled, selected, highlighted
    }
}
