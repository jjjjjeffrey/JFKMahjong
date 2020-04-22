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
    
    //自动抓牌出牌
    func autoDrawDiscardTile() {
        guard let wind = wind else {
            return
        }
        var tiles = table?.getTiles(wind) ?? []
        if tiles.count < 14 {
            table?.draw(wind: wind)
            tiles = table?.getTiles(wind) ?? []
        }
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            let tiles = self?.table?.getTiles(wind) ?? []
            self?.table?.discard(wind: wind, tileIndex: tiles.endIndex-1)
        }
    }
}

class GuanNanMahjongScene: JKScene {
    
    var table = MahjongTable()
    
    var exitButtonClicked = PassthroughSubject<Void, Never>()
    
    var gamer1: Gamer = Gamer(name: "Jeffrey1")
    var gamer2: Gamer = Gamer(name: "Jeffrey2")
    var gamer3: Gamer = Gamer(name: "Jeffrey3")
    var gamer4: Gamer = Gamer(name: "Jeffrey4")
    
    //当前玩家手牌node
    private var myTileNodes: [JKButtonNode] = []
    //对家手牌node
    private var topTileNodes: [JKButtonNode] = []
    //上家手牌node
    private var leftTileNodes: [JKButtonNode] = []
    //下家手牌node
    private var rightTileNodes: [JKButtonNode] = []
    //出过的牌
    private var eastDiscardedNodes: [JKButtonNode] = []
    private var southDiscardedNodes: [JKButtonNode] = []
    private var westDiscardedNodes: [JKButtonNode] = []
    private var northDiscardedNodes: [JKButtonNode] = []
    //花牌
    private var myFlowerTileNodes: [JKButtonNode] = []
    private var topFlowerTileNodes: [JKButtonNode] = []
    private var leftFlowerTileNodes: [JKButtonNode] = []
    private var rightFlowerTileNodes: [JKButtonNode] = []
    
    override func sceneDidLoad() {
        bindActions()
        gamer1.joinTable(table)
        gamer2.joinTable(table)
        gamer3.joinTable(table)
        gamer4.joinTable(table)
    }
    
    override func didMove(to view: SKView) {
        
        startButton.position = CGPoint(x: view.width/2,
                                      y:view.height/2)
        addChild(startButton)
        
        let restartButton = JKButtonNode()
        restartButton.setTitle("重新开始", for: .normal)
        restartButton.clicked.sink { [weak self] button in
            self?.restart()
        }.store(in: &cancellables)
        restartButton.position = CGPoint(x: view.width-restartButton.calculateAccumulatedFrame().width,
                                      y:view.height-restartButton.calculateAccumulatedFrame().height)
        addChild(restartButton)
        
        let backButton = JKButtonNode()
        backButton.setTitle("退出", for: .normal)
        backButton.position = CGPoint(x: view.safeAreaLeft+20, y: view.height-view.safeAreaTop-backButton.calculateAccumulatedFrame().height-20)
        backButton.clicked.sink { [weak self] button in
            self?.exitButtonClicked.send()
        }.store(in: &cancellables)
        addChild(backButton)
    }
    
    private func bindActions() {
        table.isFull.assign(to: \.isEnabled, on: startButton).store(in: &cancellables)
        
        table.isFull.sink { (full) in
            print("是否满员: \(full)")
        }.store(in: &cancellables)
        
        table.takeTurns.sink { [weak self] (wind) in
            if wind == self?.gamer1.wind, let tiles = self?.table.getTiles(wind), tiles.count < 14 {
                self?.table.draw(wind: wind)
            } else if wind == self?.gamer2.wind {
                self?.gamer2.autoDrawDiscardTile()
            } else if wind == self?.gamer3.wind {
                self?.gamer3.autoDrawDiscardTile()
            } else if wind == self?.gamer4.wind {
                self?.gamer4.autoDrawDiscardTile()
            }
        }.store(in: &cancellables)
        
        table.gamerTilesChanged.sink { [weak self] (wind, tiles) in
            if wind == self?.gamer1.wind?.previous().previous() {
                self?.updateTopTilesUI()
            } else if wind == self?.gamer1.wind?.previous() {
                self?.updateLeftTilesUI()
            } else if wind == self?.gamer1.wind?.next() {
                self?.updateRightTilesUI()
            } else {
                self?.updateMyTilesUI()
            }
        }.store(in: &cancellables)
        
        table.discardedTilesChanged.sink { [weak self] (wind, tiles) in
            self?.updateDiscardedTilesUI(wind: wind, tiles: tiles)
        }.store(in: &cancellables)
        
        table.gamerFlowerTilesChanged.sink { [weak self] (wind, count) in
            self?.updateFlowerTilesUI(wind: wind, count: count)
        }.store(in: &cancellables)
        
        table.isEnd.sink { [weak self] in
            print("游戏结束")
        }.store(in: &cancellables)
    }
    
    private func restart() {
        removeAllTilesNode()
        
        table = MahjongTable()
        bindActions()
        gamer1.joinTable(table)
        gamer2.joinTable(table)
        gamer3.joinTable(table)
        gamer4.joinTable(table)
        startGame()
    }
    
    private func removeAllTilesNode() {
        //手牌
        myTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        topTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        leftTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        rightTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        //出过的牌
        eastDiscardedNodes.forEach { (node) in
            node.removeFromParent()
        }
        southDiscardedNodes.forEach { (node) in
            node.removeFromParent()
        }
        westDiscardedNodes.forEach { (node) in
            node.removeFromParent()
        }
        northDiscardedNodes.forEach { (node) in
            node.removeFromParent()
        }
        //花牌
        myFlowerTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        topFlowerTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        leftFlowerTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        rightFlowerTileNodes.forEach { (node) in
            node.removeFromParent()
        }
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
    
    //当前玩家手牌布局参数
    //当前玩家手牌宽度
    private var myTileWidth: CGFloat {
        get {
            return (frame.width-view!.safeAreaLeft-view!.safeAreaRight)/18
        }
    }
    //当前玩家手牌高度
    private var myTileHeight: CGFloat {
        get {
            return 194/128*myTileWidth
        }
    }
    
    //当前玩家手牌左侧起始位置
    private var myTileLeftBegin: CGFloat {
        get {
            return myTileWidth/2+view!.safeAreaLeft+myTileWidth*2
        }
    }
    //当前玩家手牌底部起始位置
    private var myTileBottomBegin: CGFloat {
        get {
            return view!.safeAreaBottom+myTileHeight/2
        }
    }
    
    //对家手牌宽度
    private var topTileWidth: CGFloat {
        get {
            return bottomDiscardTileWidth
        }
    }
    //对家手牌高度
    private var topTileHeight: CGFloat {
        get {
            return bottomDiscardTileHeight
        }
    }
    
    //对家手牌左侧起始位置
    private var topTileLeftBegin: CGFloat {
        get {
            return view!.width-(view!.width-topTileWidth*14)/2
        }
    }
    //对家手牌底部起始位置
    private var topTileBottomBegin: CGFloat {
        get {
            return view!.height-topTileHeight/2-10
        }
    }
    
    //上家手牌宽度
    private var leftTileWidth: CGFloat {
        get {
            return leftTileHeight*58/134
        }
    }
    //上家手牌高度
    private var leftTileHeight: CGFloat {
        get {
            return topTileHeight
        }
    }
    
    //上家手牌左侧起始位置
    private var leftTileLeftBegin: CGFloat {
        get {
            return leftDiscardTileLeftBegin-6*leftDiscardTileWidth
        }
    }
    //上家手牌底部起始位置
    private var leftTileBottomBegin: CGFloat {
        get {
            //牌顶部宽度
            let topWidth = leftTileHeight*73/134
            return view!.height-(view!.height-13*topWidth+leftTileHeight)/2+myTileHeight
        }
    }
    
    //下家手牌宽度
    private var rightTileWidth: CGFloat {
        get {
            return leftTileWidth
        }
    }
    //下家手牌高度
    private var rightTileHeight: CGFloat {
        get {
            return leftTileHeight
        }
    }
    
    //下家手牌左侧起始位置
    private var rightTileLeftBegin: CGFloat {
        get {
            return rightDiscardTileLeftBegin+6*rightDiscardTileWidth
        }
    }
    //下家手牌底部起始位置
    private var rightTileBottomBegin: CGFloat {
        get {
            //牌顶部宽度
            let topWidth = rightTileHeight*73/134
            return view!.height-(view!.height-13*topWidth+rightTileHeight)/2-13*topWidth+myTileHeight
        }
    }
    
    //中心区域宽高
    private var centerAreaWidth: CGFloat {
        get {
            return bottomDiscardTileWidth*6
        }
    }
    private var centerAreaHeight: CGFloat {
        get {
            let tileFaceHeight = leftDiscardTileHeight*118/170
            return tileFaceHeight*5+leftDiscardTileHeight
        }
    }
    
    //中心区域坐标
    private var centerAreaTopLeftPoint: CGPoint {
        get {
            let x = (view!.width-centerAreaWidth)/2
            let y = (view!.height-centerAreaHeight)/2 + centerAreaHeight
            return CGPoint(x: x, y: y)
        }
    }
    private var centerAreaTopRightPoint: CGPoint {
        get {
            let x = centerAreaWidth+(view!.width-centerAreaWidth)/2
            let y = (view!.height-centerAreaHeight)/2 + centerAreaHeight
            return CGPoint(x: x, y: y)
        }
    }
    private var centerAreaBottomLeftPoint: CGPoint {
        get {
            let x = (view!.width-centerAreaWidth)/2
            let y = (view!.height-centerAreaHeight)/2 + bottomDiscardTileHeight
            return CGPoint(x: x, y: y)
        }
    }
    private var centerAreaBottomRightPoint: CGPoint {
        get {
            let x = centerAreaWidth+(view!.width-centerAreaWidth)/2
            let y = (view!.height-centerAreaHeight)/2
            return CGPoint(x: x, y: y)
        }
    }
    
    //当前玩家出过的牌布局参数
    private var bottomDiscardTileWidth: CGFloat {
        get {
            return (frame.width-view!.safeAreaLeft-view!.safeAreaRight)/36
        }
    }
    
    private var bottomDiscardTileHeight: CGFloat {
        get {
            return 194/128*bottomDiscardTileWidth
        }
    }
    
    private var bottomDiscardTileLeftBegin: CGFloat {
        get {
            return (view!.width-bottomDiscardTileWidth*6)/2+bottomDiscardTileWidth/2
        }
    }
    
    private var bottomDiscardTileBottomBegin: CGFloat {
        get {
            return centerAreaBottomLeftPoint.y - bottomDiscardTileHeight/2
        }
    }
    
    //上家出过的牌布局参数
    private var leftDiscardTileWidth: CGFloat {
        get {
            return (frame.width-view!.safeAreaLeft-view!.safeAreaRight)/36
        }
    }
    
    private var leftDiscardTileHeight: CGFloat {
        get {
            return 185/170*leftDiscardTileWidth
        }
    }
    
    private var leftDiscardTileLeftBegin: CGFloat {
        get {
            return bottomDiscardTileLeftBegin-leftDiscardTileWidth/2-bottomDiscardTileWidth/2
        }
    }
    
    private var leftDiscardTileBottomBegin: CGFloat {
        get {
            //118/170是牌面和牌侧面比例
            let tileFaceHeight = leftDiscardTileHeight*118/170
            return bottomDiscardTileBottomBegin+(bottomDiscardTileHeight-leftDiscardTileHeight)/2+tileFaceHeight*6
        }
    }
    
    //对家出过的牌布局参数
    private var topDiscardTileWidth: CGFloat {
        get {
            return bottomDiscardTileWidth
        }
    }
    
    private var topDiscardTileHeight: CGFloat {
        get {
            return bottomDiscardTileHeight
        }
    }
    
    private var topDiscardTileLeftBegin: CGFloat {
        get {
            return bottomDiscardTileLeftBegin+5*topDiscardTileWidth
        }
    }
    
    private var topDiscardTileBottomBegin: CGFloat {
        get {
            //118/170是牌面和牌侧面比例
            return bottomDiscardTileBottomBegin+6*leftDiscardTileHeight*118/170+topDiscardTileHeight
        }
    }
    
    //下家出过的牌布局参数
    private var rightDiscardTileWidth: CGFloat {
        get {
            return leftDiscardTileWidth
        }
    }
    
    private var rightDiscardTileHeight: CGFloat {
        get {
            return leftDiscardTileHeight
        }
    }
    
    private var rightDiscardTileLeftBegin: CGFloat {
        get {
            return leftDiscardTileLeftBegin+6*topDiscardTileWidth+rightDiscardTileWidth
        }
    }
    
    private var rightDiscardTileBottomBegin: CGFloat {
        get {
            //118/170是牌面和牌侧面比例
            let tileFaceHeight = rightDiscardTileHeight*118/170
            return leftDiscardTileBottomBegin-5*tileFaceHeight
        }
    }
    
    //本家花牌布局参数
    private var bottomFlowerTileWidth: CGFloat {
        get {
            return myTileWidth/2
        }
    }
    
    private var bottomFlowerTileHeight: CGFloat {
        get {
            return myTileHeight/2
        }
    }
    
    private var bottomFlowerTileLeftBegin: CGFloat {
        get {
            return myTileLeftBegin
        }
    }
    
    private var bottomFlowerTileBottomBegin: CGFloat {
        get {
            return myTileBottomBegin + myTileHeight/2 + bottomFlowerTileHeight/2 + 5
        }
    }
    //上家花牌布局参数
    private var leftFlowerTileWidth: CGFloat {
        get {
            return leftDiscardTileWidth
        }
    }
    
    private var leftFlowerTileHeight: CGFloat {
        get {
            return leftDiscardTileHeight
        }
    }
    
    private var leftFlowerTileLeftBegin: CGFloat {
        get {
            return leftTileLeftBegin + leftTileWidth/2 + leftFlowerTileWidth/2 + 5
        }
    }
    
    private var leftFlowerTileBottomBegin: CGFloat {
        get {
            return leftTileBottomBegin
        }
    }
    //对家花牌布局参数
    private var topFlowerTileWidth: CGFloat {
        get {
            return topDiscardTileWidth
        }
    }
    
    private var topFlowerTileHeight: CGFloat {
        get {
            return topDiscardTileHeight
        }
    }
    
    private var topFlowerTileLeftBegin: CGFloat {
        get {
            return topTileLeftBegin
        }
    }
    
    private var topFlowerTileBottomBegin: CGFloat {
        get {
            return topTileBottomBegin - topTileHeight/2 - topFlowerTileHeight/2 - 5
        }
    }
    
    //下家花牌布局参数
    private var rightFlowerTileWidth: CGFloat {
        get {
            return rightDiscardTileWidth
        }
    }
    
    private var rightFlowerTileHeight: CGFloat {
        get {
            return rightDiscardTileHeight
        }
    }
    
    private var rightFlowerTileLeftBegin: CGFloat {
        get {
            return rightTileLeftBegin - rightTileWidth/2 - rightFlowerTileWidth/2 - 5
        }
    }
    
    private var rightFlowerTileBottomBegin: CGFloat {
        get {
            return rightTileBottomBegin
        }
    }
    
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
        //补花
        table.flowerSupplement()
        
    }
    
    //刷新当前玩家手牌UI
    private func updateMyTilesUI() {
        guard let wind = gamer1.wind else {
            return
        }
        myTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        let mytiles = table.getTiles(wind)
        
        for (i,tile) in mytiles.enumerated() {
            var left = myTileLeftBegin+CGFloat(i)*myTileWidth
            if i == 13 {
                left += 10
            }
            let tileNode = JKButtonNode()
            tileNode.tag = i
            tileNode.setImage(tile.imageName, size: CGSize(width: myTileWidth, height: myTileHeight), for: .normal)
            tileNode.position = CGPoint(x: left, y: myTileBottomBegin)
            tileNode.clicked.sink { [weak self] button in
                if button.isSelected {
                    self?.discardTile(button.tag)
                } else {
                    self?.activeTile(button)
                }
            }.store(in: &cancellables)
            addChild(tileNode)
            myTileNodes.append(tileNode)
        }
    }
    //刷新对家手牌UI
    private func updateTopTilesUI() {
        guard let wind = gamer1.wind?.previous().previous() else {
            return
        }
        topTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        let tilesCount = table.getTiles(wind).count
        for i in 0..<tilesCount {
            var left = topTileLeftBegin-CGFloat(i)*topTileWidth
            if i == 13 {
                left -= 5
            }
            let tileNode = JKButtonNode()
            tileNode.setImage("tile-reverse-top", size: CGSize(width: topTileWidth, height: topTileHeight), for: .normal)
            tileNode.position = CGPoint(x: left, y: topTileBottomBegin)
            addChild(tileNode)
            topTileNodes.append(tileNode)
        }
    }
    
    //刷新上家手牌UI
    private func updateLeftTilesUI() {
        guard let wind = gamer1.wind?.previous() else {
            return
        }
        leftTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        var z: CGFloat = 0
        let tilesCount = table.getTiles(wind).count
        for i in 0..<tilesCount {
            var bottom = leftTileBottomBegin-CGFloat(i)*leftTileHeight*73/134
            if i == 13 {
                bottom -= 5
            }
            let tileNode = JKButtonNode()
            tileNode.setImage("tile-reverse-left", size: CGSize(width: leftTileWidth, height: leftTileHeight), for: .normal)
            tileNode.position = CGPoint(x: leftTileLeftBegin, y: bottom)
            tileNode.zPosition = z
            addChild(tileNode)
            leftTileNodes.append(tileNode)
            z += 0.01
        }
    }
    
    //刷新下家手牌UI
    private func updateRightTilesUI() {
        guard let wind = gamer1.wind?.next() else {
            return
        }
        rightTileNodes.forEach { (node) in
            node.removeFromParent()
        }
        var z: CGFloat = 0
        let tilesCount = table.getTiles(wind).count
        for i in 0..<tilesCount {
            var bottom = rightTileBottomBegin+CGFloat(i)*rightTileHeight*73/134
            if i == 13 {
                bottom += 5
            }
            let tileNode = JKButtonNode()
            tileNode.setImage("tile-reverse-right", size: CGSize(width: rightTileWidth, height: rightTileHeight), for: .normal)
            tileNode.position = CGPoint(x: rightTileLeftBegin, y: bottom)
            tileNode.zPosition = z
            addChild(tileNode)
            rightTileNodes.append(tileNode)
            z -= 0.01
        }
    }
    
    //更新已出牌UI
    private func updateDiscardedTilesUI(wind: MahjongTile.Wind, tiles: [MahjongTile]) {
        
        switch wind {
        case .east:
            eastDiscardedNodes.forEach { (node) in
                node.removeFromParent()
            }
        case .south:
            southDiscardedNodes.forEach { (node) in
                node.removeFromParent()
            }
        case .west:
            westDiscardedNodes.forEach { (node) in
                node.removeFromParent()
            }
        case .north:
            northDiscardedNodes.forEach { (node) in
                node.removeFromParent()
            }
        }
        
        var z: CGFloat = 0
        
        for (i,tile) in tiles.enumerated() {
            let tileNode = JKButtonNode()
            
            if gamer1.wind == wind {
                //一排中的第几张，一排6张
                let lineTileIndex = i%6
                let lineIndex = i/6
                let left = bottomDiscardTileLeftBegin+CGFloat(lineTileIndex)*bottomDiscardTileWidth
                tileNode.setImage(tile.discardedBottomImageName, size: CGSize(width: bottomDiscardTileWidth, height: bottomDiscardTileHeight), for: .normal)
                //145/193是牌面和牌侧面比例
                tileNode.position = CGPoint(x: left, y: bottomDiscardTileBottomBegin-CGFloat(lineIndex)*bottomDiscardTileHeight*145/193)
                tileNode.zPosition = z
                addChild(tileNode)
                z += 0.01
            } else if gamer1.wind?.previous() == wind {
                //上家
                //一排中的第几张，一排6张
                let lineTileIndex = i%6
                let lineIndex = i/6
                //118/170是牌面和牌侧面比例
                let bottom = leftDiscardTileBottomBegin-CGFloat(lineTileIndex)*leftDiscardTileHeight*118/170
                tileNode.setImage(tile.discardedLeftImageName, size: CGSize(width: leftDiscardTileWidth, height: leftDiscardTileHeight), for: .normal)
                tileNode.position = CGPoint(x: leftDiscardTileLeftBegin-leftDiscardTileWidth*CGFloat(lineIndex), y: bottom)
                tileNode.zPosition = z
                addChild(tileNode)
                z += 0.01
            } else if gamer1.wind?.previous().previous() == wind {
                //一排中的第几张，一排6张
                //对家
                let lineTileIndex = i%6
                let lineIndex = i/6
                let left = topDiscardTileLeftBegin-CGFloat(lineTileIndex)*topDiscardTileWidth
                tileNode.setImage(tile.discardedTopImageName, size: CGSize(width: topDiscardTileWidth, height: topDiscardTileHeight), for: .normal)
                //145/193是牌面和牌侧面比例
                tileNode.position = CGPoint(x: left, y: topDiscardTileBottomBegin+CGFloat(lineIndex)*topDiscardTileHeight*145/193)
                tileNode.zPosition = z
                addChild(tileNode)
                z -= 0.01
            } else if gamer1.wind?.next() == wind {
                //下家
                //一排中的第几张，一排6张
                let lineTileIndex = i%6
                let lineIndex = i/6
                //118/170是牌面和牌侧面比例
                let bottom = rightDiscardTileBottomBegin+CGFloat(lineTileIndex)*rightDiscardTileHeight*118/170
                tileNode.setImage(tile.discardedRightImageName, size: CGSize(width: rightDiscardTileWidth, height: rightDiscardTileHeight), for: .normal)
                tileNode.position = CGPoint(x: rightDiscardTileLeftBegin+rightDiscardTileWidth*CGFloat(lineIndex), y: bottom)
                tileNode.zPosition = z
                addChild(tileNode)
                z -= 0.01
            }
            
            switch wind {
            case .east:
                eastDiscardedNodes.append(tileNode)
            case .south:
                southDiscardedNodes.append(tileNode)
            case .west:
                westDiscardedNodes.append(tileNode)
            case .north:
                northDiscardedNodes.append(tileNode)
            }
        }
        
        
    }
    //更新花牌UI
    private func updateFlowerTilesUI(wind: MahjongTile.Wind, count: Int) {
        
        if wind == gamer1.wind?.previous().previous() {
            //对家
            topFlowerTileNodes.forEach { (node) in
                node.removeFromParent()
            }
        } else if wind == gamer1.wind?.previous() {
            //上家
            leftFlowerTileNodes.forEach { (node) in
                node.removeFromParent()
            }
        } else if wind == gamer1.wind?.next() {
            //下家
            rightFlowerTileNodes.forEach { (node) in
                node.removeFromParent()
            }
        } else {
            //本家
            myFlowerTileNodes.forEach { (node) in
                node.removeFromParent()
            }
        }
        
        var z: CGFloat = 0
        for i in 0..<count {
            let tileNode = JKButtonNode()
            if wind == gamer1.wind?.previous().previous() {
                //对家
                tileNode.setImage(MahjongTile.dragon(.red).discardedTopImageName, size: CGSize(width: topFlowerTileWidth, height: topFlowerTileHeight), for: .normal)
                tileNode.position = CGPoint(x: topFlowerTileLeftBegin-CGFloat(i)*topFlowerTileWidth, y: topFlowerTileBottomBegin)
                tileNode.zPosition = z
                addChild(tileNode)
                z += 0.01
                topFlowerTileNodes.append(tileNode)
            } else if wind == gamer1.wind?.previous() {
                //上家
                tileNode.setImage(MahjongTile.dragon(.red).discardedLeftImageName, size: CGSize(width: leftFlowerTileWidth, height: leftFlowerTileHeight), for: .normal)
                tileNode.position = CGPoint(x: leftFlowerTileLeftBegin, y: leftFlowerTileBottomBegin-CGFloat(i)*leftFlowerTileHeight*118/170)
                tileNode.zPosition = z
                addChild(tileNode)
                z += 0.01
                leftFlowerTileNodes.append(tileNode)
            } else if wind == gamer1.wind?.next() {
                //下家
                tileNode.setImage(MahjongTile.dragon(.red).discardedRightImageName, size: CGSize(width: rightFlowerTileWidth, height: rightFlowerTileHeight), for: .normal)
                tileNode.position = CGPoint(x: rightFlowerTileLeftBegin, y: rightFlowerTileBottomBegin+CGFloat(i)*rightFlowerTileHeight*118/170)
                tileNode.zPosition = z
                addChild(tileNode)
                z -= 0.01
                rightFlowerTileNodes.append(tileNode)
            } else {
                //本家
                z -= 0.01
                tileNode.setImage(MahjongTile.dragon(.red).discardedBottomImageName, size: CGSize(width: bottomFlowerTileWidth, height: bottomFlowerTileHeight), for: .normal)
                tileNode.position = CGPoint(x: bottomFlowerTileLeftBegin+CGFloat(i)*bottomFlowerTileWidth, y: bottomFlowerTileBottomBegin)
                tileNode.zPosition = z
                addChild(tileNode)
                z -= 0.01
                myFlowerTileNodes.append(tileNode)
            }
            
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
        guard table.currentTurnWind == gamer1.wind else {
            return
        }
        if let userWind = gamer1.wind {
            table.discard(wind: userWind, tileIndex: index)
            self.updateMyTilesUI()
        }
    }
}
