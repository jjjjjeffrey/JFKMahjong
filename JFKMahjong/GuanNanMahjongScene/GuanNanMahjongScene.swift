//
//  GuanNanMahjongScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class Gamer {
    var name: String
    
    private weak var table: MahjongTable?
    
    init(name: String) {
        self.name = name
    }
    
    var wind: MahjongTile.Wind?
    
    var joined: Bool {
        get {
            return wind != nil
        }
    }
    
    func joinTable(_ table: MahjongTable) {
        do {
            wind = try table.join(self)
            self.table = table
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    func autoDiscardTile() {
        guard let wind = wind else {
            return
        }
        var tiles = table?.getTiles(wind) ?? []
        if tiles.count < 14 {
            table?.draw(wind: wind)
            tiles = table?.getTiles(wind) ?? []
        }
        table?.discard(wind: wind, tileIndex: tiles.endIndex-1)
    }
}

class GuanNanMahjongScene: JKScene {
    
    let table = MahjongTable()
    
    var exitButtonClicked = PassthroughSubject<Void, Never>()
    
    var currentGamerWind: MahjongTile.Wind?
    var gamer1: Gamer = Gamer(name: "Jeffrey1")
    var gamer2: Gamer = Gamer(name: "Jeffrey2")
    var gamer3: Gamer = Gamer(name: "Jeffrey3")
    var gamer4: Gamer = Gamer(name: "Jeffrey4")
    
    private var tileNodes: [JKButtonNode] = []
    
    override func sceneDidLoad() {
        
        table.isFull.assign(to: \.isEnabled, on: startButton).store(in: &cancellables)
        
        table.isFull.sink { (full) in
            print("是否满员: \(full)")
        }.store(in: &cancellables)
        
        gamer1.joinTable(table)
        gamer2.joinTable(table)
        gamer3.joinTable(table)
        gamer4.joinTable(table)
        
        table.takeTurns.sink { [weak self] (wind) in
            if wind == self?.gamer1.wind {
                self?.table.draw(wind: wind)
                self?.updateMyTilesUI()
            } else if wind == self?.gamer2.wind {
                self?.gamer2.autoDiscardTile()
            } else if wind == self?.gamer3.wind {
                self?.gamer3.autoDiscardTile()
            } else if wind == self?.gamer4.wind {
                self?.gamer4.autoDiscardTile()
            }
        }.store(in: &cancellables)
        
        table.isEnd.sink { [weak self] in
            print("游戏结束")
        }.store(in: &cancellables)
    }
    
    override func didMove(to view: SKView) {
        
        startButton.position = CGPoint(x: view.width/2,
                                      y:view.height/2)
        addChild(startButton)
        
        let backButton = JKButtonNode()
        backButton.setTitle("退出", for: .normal)
        backButton.position = CGPoint(x: view.safeAreaLeft+20, y: view.height-view.safeAreaTop-backButton.calculateAccumulatedFrame().height-20)
        backButton.clicked.sink { [weak self] button in
            self?.exitButtonClicked.send()
        }.store(in: &cancellables)
        addChild(backButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    //MARK: - Private
    private lazy var startButton: JKButtonNode = {
        let b = JKButtonNode()
        b.isEnabled = false
        b.setTitle("开始游戏", for: .normal)
        b.clicked.sink { [weak self] button in
            self?.startGame()
        }.store(in: &cancellables)
        return b
    }()
    
    private weak var currentActiveTile: JKButtonNode?
    
    private func startGame() {
        
        startButton.removeFromParent()
        
        //洗牌
        table.shufflingTheTiles()
        //确定庄家
        table.confirmDealer()
        //掷骰子确定抓牌位置
        table.throwDies()
        //发牌
        table.deal()
        
        updateMyTilesUI()
    }
    
    private func updateMyTilesUI() {
        guard let wind = gamer1.wind else {
            return
        }
        tileNodes.forEach { (node) in
            node.removeFromParent()
        }
        let mytiles = table.getTiles(wind)
        
        let tileWidth = (frame.width-view!.safeAreaLeft-view!.safeAreaRight)/18
        let tileHeight = 194/128*tileWidth
        let leftBegin = tileWidth/2+view!.safeAreaLeft+tileWidth*2
        let bottomBegin = view!.safeAreaBottom+tileHeight/2
        
        for (i,tile) in mytiles.enumerated() {
            var left = leftBegin+CGFloat(i)*tileWidth
            if i == 13 {
                left += 10
            }
            let tileNode = JKButtonNode()
            tileNode.tag = i
            tileNode.setImage(tile.imageName, size: CGSize(width: tileWidth, height: tileHeight), for: .normal)
            tileNode.position = CGPoint(x: left, y: bottomBegin)
            tileNode.clicked.sink { [weak self] button in
                if button.isSelected {
                    self?.discardTile(button.tag)
                } else {
                    self?.activeTile(button)
                }
            }.store(in: &cancellables)
            addChild(tileNode)
            tileNodes.append(tileNode)
        }
    }
    
    private func activeTile(_ button: JKButtonNode) {
        guard button !== currentActiveTile else {
            return
        }
        if let currentActiveTile = currentActiveTile {
            deactiveTile(currentActiveTile)
        }
        button.isSelected = true
        let oldY = button.position.y
        let tileHeight = button.calculateAccumulatedFrame().height
        let moveAction = SKAction.moveTo(y: oldY+tileHeight/3, duration: 0.1)
        button.run(moveAction)
        currentActiveTile = button
    }
    
    func deactiveTile(_ button: JKButtonNode) {
        button.isSelected = false
        let oldY = button.position.y
        let tileHeight = button.calculateAccumulatedFrame().height
        let moveAction = SKAction.moveTo(y: oldY-tileHeight/3, duration: 0.1)
        button.run(moveAction)
    }
    
    func discardTile(_ index: Int) {
        if let userWind = gamer1.wind {
            table.discard(wind: userWind, tileIndex: index)
            self.updateMyTilesUI()
        }
    }
}
