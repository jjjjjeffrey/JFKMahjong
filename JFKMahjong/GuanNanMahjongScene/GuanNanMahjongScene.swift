//
//  GuanNanMahjongScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit
import Combine

class GuanNanMahjongScene: JKScene {
    
    let table = MahjongTable()
    
    var exitButtonClicked = PassthroughSubject<Void, Never>()
    
    var currentUserWind: MahjongTile.Wind?
    
    var myTiles: [MahjongTile] = []
    
    override func sceneDidLoad() {
        do {
            currentUserWind = try joinGame()
        } catch {
            print("\(error.localizedDescription)")
        }
    }
    
    override func didMove(to view: SKView) {
        
        if currentUserWind != nil {
            startGame()
        }
        
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
    
    //加入游戏
    func joinGame() throws -> MahjongTile.Wind {
        //上桌
        return try table.join()
    }
    
    func startGame() {
        
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
        if let userWind = currentUserWind {
            myTiles = table.getMyTiles(userWind)
        }
    }
    
    func sortMyTiles() {
        myTiles = myTiles.sort()
    }
}
