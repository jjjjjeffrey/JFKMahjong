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
        } catch {
            print("\(error.localizedDescription)")
        }
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
    
    var myTiles: [MahjongTile] = []
    
    override func sceneDidLoad() {
        
        table.isFull.assign(to: \.isEnable, on: startButton).store(in: &cancellables)
        
        table.isFull.sink { (full) in
            print("是否满员: \(full)")
        }.store(in: &cancellables)
        
        gamer1.joinTable(table)
        gamer2.joinTable(table)
        gamer3.joinTable(table)
        gamer4.joinTable(table)
    }
    
    override func didMove(to view: SKView) {
        
        startButton.position = CGPoint(x: view.width/2,
                                      y:view.height/2)
        addChild(startButton)
        
        let backButton = JKButtonNode()
        backButton.setTitle("退出", for: .normal)
        backButton.position = CGPoint(x: view.safeAreaLeft+20, y: view.height-view.safeAreaTop-backButton.calculateAccumulatedFrame().height-20)
        backButton.clicked.sink { [weak self] in
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
        b.isEnable = false
        b.setTitle("开始游戏", for: .normal)
        b.clicked.sink { [weak self] in
            self?.startGame()
        }.store(in: &cancellables)
        return b
    }()
    
    func startGame() {
        
        startButton.removeFromParent()
        
        //洗牌
        table.shufflingTheTiles()
        //确定庄家
        table.confirmDealer()
        //掷骰子确定抓牌位置
        table.throwDies()
        //发牌
        table.deal()
        
        let tileWidth = (frame.width-view!.safeAreaLeft-view!.safeAreaRight)/18
        let tileHeight = 194/128*tileWidth
        let leftBegin = tileWidth/2+view!.safeAreaLeft+tileWidth*2
        let bottomBegin = view!.safeAreaBottom+tileHeight/2

        getMyTiles()
        sortMyTiles()
        
        for (i,tile) in myTiles.enumerated() {
            var left = leftBegin+CGFloat(i)*tileWidth
            if i == 13 {
                left += 10
            }
            let tileNode = SKSpriteNode(imageNamed: tile.imageName)
            tileNode.size = CGSize(width: tileWidth, height: tileHeight)
            tileNode.position = CGPoint(x: left, y: bottomBegin)
            addChild(tileNode)
        }
    }
    
    func getMyTiles() {
        if let userWind = gamer1.wind {
            myTiles = table.getMyTiles(userWind)
        }
    }
    
    func sortMyTiles() {
        myTiles = myTiles.sort()
    }
}
