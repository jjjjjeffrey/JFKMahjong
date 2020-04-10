//
//  GuanNanMahjongScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class Die {
    var value: Int = 1
    func throwMe() {
        value = [1, 2, 3, 4, 5, 6].shuffled().first!
    }
}

class MahjongTable {
    
    let dies = [Die(), Die()]
    
    func throwDies() {
        dies.forEach { (die) in
            die.throwMe()
        }
        print("骰子: \(dies[0].value) \(dies[1].value)")
    }
    
}


class GuanNanMahjongScene: JKScene {
    
    let table = MahjongTable()
    
    var exitButtonClicked = PassthroughSubject<Void, Never>()
    
    override func sceneDidLoad() {
        
        let tiles = self.tiles
        print("共 \(tiles.count) 张牌")
        for tile in tiles {
            print(tile)
        }
        
        startGame()
    }
    
    override func didMove(to view: SKView) {
        
        let backButton = JKButtonNode()
        backButton.setTitle("退出", for: .normal)
        backButton.position = CGPoint(x: view.safeAreaLeft+20, y: view.height-view.safeAreaTop-backButton.calculateAccumulatedFrame().height-20)
        backButton.clicked.sink { [weak self] in
            self?.exitButtonClicked.send()
        }.store(in: &cancellables)
        addChild(backButton)
        
        
        
        let tileWidth = (frame.width-view.safeAreaLeft-view.safeAreaRight)/18
        let tileHeight = 194/128*tileWidth
        let leftBegin = tileWidth/2+view.safeAreaLeft+tileWidth*2
        let bottomBegin = view.safeAreaBottom+tileHeight/2

        let myTiles = tiles[0..<14]
        for (i,tile) in myTiles.enumerated() {
            let tileNode = SKSpriteNode(imageNamed: tile.imageName)
            tileNode.size = CGSize(width: tileWidth, height: tileHeight)
            tileNode.position = CGPoint(x: leftBegin+CGFloat(i)*tileWidth, y: bottomBegin)
            addChild(tileNode)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    func startGame() {
        table.throwDies()
    }
    
    private var tiles: [MahjongTile] {
        get {
            var tiles: [MahjongTile] = []
            for rank in MahjongTile.Rank.allCases {
                for i in 0..<9 {
                    tiles.append(contentsOf: [.rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank)])
                }
            }
            for wind in MahjongTile.Wind.allCases {
                tiles.append(contentsOf: [.wind(wind), .wind(wind), .wind(wind), .wind(wind)])
            }
            return tiles.shuffled()
        }
    }
}
