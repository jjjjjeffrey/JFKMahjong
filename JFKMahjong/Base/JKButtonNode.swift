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
    
    var clicked = PassthroughSubject<Void, Never>()
    
    private lazy var labelNode: SKLabelNode = {
        let node = SKLabelNode(text: "Button")
        node.fontColor = stateColors[.normal] ?? UIColor(hex: 0x0091FF)
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
    
    private(set) var state: State = .normal {
        didSet {
            labelNode.fontColor = stateColors[state] ?? UIColor(hex: 0x0091FF)
        }
    }
    
    var isEnable: Bool = true {
        didSet {
            state = isEnable ? .normal : .disabled
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnable {
            clicked.send()
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
