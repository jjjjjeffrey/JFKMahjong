//
//  MahjongTable.swift
//  JFKMahjong
//
//  Created by build on 2020/4/14.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import Foundation
import Combine

class Die {
    var value: Int = 1
    func throwMe() {
        value = [1, 2, 3, 4, 5, 6].shuffled().first!
    }
}

class MahjongTable {
    
    let dies = [Die(), Die()]
    var seats: [MahjongTile.Wind] = [.east, .south, .west, .north] {
        didSet {
            isFull.send(seats.isEmpty)
        }
    }
    var gamers: [Gamer] = []
    
    //是否坐满
    var isFull = PassthroughSubject<Bool, Never>()
    //流局
    var isEnd = PassthroughSubject<Void, Never>()
    //轮到谁出牌
    var takeTurns = PassthroughSubject<MahjongTile.Wind, Never>()
    //出牌变化
    var discardedTilesChanged = PassthroughSubject<(MahjongTile.Wind,[MahjongTile]), Never>()
    //玩家手牌变化
    var gamerTilesChanged = PassthroughSubject<(MahjongTile.Wind,[MahjongTile]), Never>()
    
    //牌墙
    private var tilesWall: [MahjongTile.Wind: [MahjongTile]] = [:]
    //起始手牌
    private var startTiles: [MahjongTile.Wind: [MahjongTile]] = [.east:[], .south:[], .west:[], .north:[]] {
        didSet {
            eastTiles = startTiles[.east]?.sort() ?? []
            southTiles = startTiles[.south]?.sort() ?? []
            westTiles = startTiles[.west]?.sort() ?? []
            northTiles = startTiles[.north]?.sort() ?? []
        }
    }
    
    //当前出牌位置
    private(set) var currentTurnWind: MahjongTile.Wind? {
        didSet {
            if let wind = currentTurnWind {
                takeTurns.send(wind)
            }
        }
    }
    
    //当前手牌
    private var eastTiles: [MahjongTile] = [] {
        didSet {
            gamerTilesChanged.send((.east, eastTiles))
        }
    }
    private var southTiles: [MahjongTile] = [] {
           didSet {
               gamerTilesChanged.send((.south, eastTiles))
           }
    }
    private var westTiles: [MahjongTile] = [] {
           didSet {
               gamerTilesChanged.send((.west, eastTiles))
           }
    }
    private var northTiles: [MahjongTile] = [] {
           didSet {
               gamerTilesChanged.send((.north, eastTiles))
           }
    }
    //出过的牌
    private var eastDiscardedTiles: [MahjongTile] = []
    private var southDiscardedTiles: [MahjongTile] = []
    private var westDiscardedTiles: [MahjongTile] = []
    private var northDiscardedTiles: [MahjongTile] = []
    
    //剩余待抓牌
    private var tilesRemaining: [MahjongTile] = [] {
        didSet {
            print("剩余张数: \(tilesRemaining.count)")
        }
    }
    //剩余不摸的牌（用来补花和杠后摸牌，发牌后起始余8张）
    private var tailTiles : [MahjongTile] = []
    //庄家
    private(set) var dealerWind: MahjongTile.Wind = .east
    
    //上桌
    func join(_ gamer: Gamer) throws -> MahjongTile.Wind {
        guard !seats.isEmpty else {
            throw TableError.noRemainingSeats
        }
        gamers.append(gamer)
        return seats.removeFirst()
    }
    
    enum TableError: Error {
        case noRemainingSeats //没有剩余座位
        case discardLogicError //出牌逻辑错误
        
        var localizedDescription: String {
            get {
                switch self {
                case .noRemainingSeats:
                    return "已坐满"
                case .discardLogicError:
                    return "出牌逻辑错误"
                }
            }
        }
    }
    
    //掷骰子
    func throwDies() {
        dies.forEach { (die) in
            die.throwMe()
        }
        print("骰子: \(dies[0].value) \(dies[1].value)")
    }
    //洗牌
    func shufflingTheTiles() {
        var tiles: [MahjongTile] = []
        for rank in MahjongTile.Rank.allCases {
            for i in 0..<9 {
                tiles.append(contentsOf: [.rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank)])
            }
        }
        tiles.append(contentsOf: [.dragon(.red), .dragon(.red), .dragon(.red), .dragon(.red)])
        
        tiles = tiles.shuffled()
        
        print("共 \(tiles.count) 张牌")
        for tile in tiles {
            print(tile)
        }
        
        for (i,wind) in MahjongTile.Wind.allCases.enumerated() {
            let subtiles = tiles[i*28..<i*28+28]
            self.tilesWall[wind] = [MahjongTile](subtiles)
            print("\(wind) \(self.tilesWall[wind]!.count)张 \(self.tilesWall[wind]!)")
        }
    }
    //确定庄家Dealer
    func confirmDealer() {
        throwDies()
        let diesValue = dies[0].value + dies[1].value
        dealerWind = MahjongTile.Wind(diesValue%4)!
        print("庄家: \(dealerWind)")
    }
    
    //发牌
    //发牌规则：比如骰子3、5，从庄家开始顺时针数到3的位置牌墙，从牌墙右手边留3*4张牌开始抓牌
    //骰子5、6，从庄家开始顺时针数到5的位置牌墙，从牌墙右手边留5*4张牌开始抓牌
    func deal() {
        
        let minDieValue = dies.min { (die1, die2) -> Bool in
            die1.value < die2.value
        }.map { (die) -> Int in
            return die.value
        }!
        
        //确定起始抓牌牌墙
        var beginTilesWallWind : MahjongTile.Wind = dealerWind
        for _ in 0..<minDieValue-1 {
            beginTilesWallWind = beginTilesWallWind.previous()
        }
        
        print("起始牌墙: \(beginTilesWallWind)")
        
        //抓牌起始留牌数
        let keepCount = minDieValue*4
        //待抓的牌
        var currentTilesWallWind = beginTilesWallWind
        var currentTilesWall = tilesWall[currentTilesWallWind]!
        var currentTiles: [MahjongTile] = []
        for i in 0..<4 {
            if i == 0 {
                currentTiles.append(contentsOf: currentTilesWall[keepCount..<currentTilesWall.endIndex])
            } else {
                currentTiles.append(contentsOf: currentTilesWall)
            }
            currentTilesWallWind = currentTilesWallWind.previous()
            currentTilesWall = tilesWall[currentTilesWallWind]!
        }
        currentTiles.append(contentsOf: tilesWall[beginTilesWallWind]![0..<keepCount])
        print("待抓牌\(currentTiles.count)张：\(currentTiles)")
        
        //尾部留8张牌
        tailTiles = [MahjongTile](currentTiles[currentTiles.endIndex-8..<currentTiles.endIndex])
        print("尾部留8张牌: \(tailTiles)")
        
        currentTiles = currentTiles.dropLast(8)
        print("剩余待抓牌\(currentTiles.count)张：\(currentTiles)")
        
        //抓4圈，前3圈每人依次抓4张，最后一圈庄家抓2张，其他人抓1张，庄家14张，其他人13张
        let secondUser = dealerWind.next()
        let thirdUser = secondUser.next()
        let fourthUser = thirdUser.next()
        //抓牌顺序
        let winds = [dealerWind, secondUser, thirdUser, fourthUser]

        for i in 0..<4 {
            if i < 3 {
                for (j,wind) in winds.enumerated() {
                    let tiles = currentTiles[i*16+j*4..<i*16+(j+1)*4]
                    startTiles[wind]?.append(contentsOf: tiles)
                    print("\(wind)拿牌 \(tiles)")
                }
            } else {
                //前三轮抓走48张牌
                currentTiles = [MahjongTile](currentTiles[48..<currentTiles.endIndex])
                
                for (i,wind) in winds.enumerated() {
                    if i == 0 {
                        startTiles[wind]?.append(currentTiles.remove(at: 0))
                        startTiles[wind]?.append(currentTiles.remove(at: 3))
                    } else {
                        startTiles[wind]?.append(currentTiles.remove(at: 0))
                    }
                }
            }
        }
        let dealResult = """
        发牌结果: \r
        \(dealerWind)\(startTiles[dealerWind]!)\r
        \(secondUser)\(startTiles[secondUser]!)\r
        \(thirdUser)\(startTiles[thirdUser]!)\r
        \(fourthUser)\(startTiles[fourthUser]!)\r
        """
        print(dealResult)
        tilesRemaining = currentTiles
        print("剩余待摸牌\(tilesRemaining.count)张: \(tilesRemaining)")

        currentTurnWind = dealerWind
    }
    
    //获取手牌
    func getTiles(_ wind: MahjongTile.Wind) -> [MahjongTile] {
        switch wind {
        case .east:
            return eastTiles
        case .south:
            return southTiles
        case .west:
            return westTiles
        case .north:
            return northTiles
        }
    }
    
    //摸牌
    func draw(wind: MahjongTile.Wind) {
        guard tilesRemaining.count > 0 else {
            return
        }
        let tile = tilesRemaining.removeLast()
        switch wind {
        case .east:
            eastTiles.append(tile)
            eastTiles = eastTiles.sort()
        case .south:
            southTiles.append(tile)
            southTiles = southTiles.sort()
        case .west:
            westTiles.append(tile)
            westTiles = westTiles.sort()
        case .north:
            northTiles.append(tile)
            northTiles = northTiles.sort()
        }
        print("[\(wind)摸牌] \(tile)")
    }
    
    //出牌
    func discard(wind: MahjongTile.Wind, tileIndex: Int) {
        var tile: MahjongTile
        switch wind {
        case .east:
            tile = eastTiles.remove(at: tileIndex)
            eastDiscardedTiles.append(tile)
            discardedTilesChanged.send((wind, eastDiscardedTiles))
        case .south:
            tile = southTiles.remove(at: tileIndex)
            southDiscardedTiles.append(tile)
            discardedTilesChanged.send((wind, southDiscardedTiles))
        case .west:
            tile = westTiles.remove(at: tileIndex)
            westDiscardedTiles.append(tile)
            discardedTilesChanged.send((wind, westDiscardedTiles))
        case .north:
            tile = northTiles.remove(at: tileIndex)
            northDiscardedTiles.append(tile)
            discardedTilesChanged.send((wind, northDiscardedTiles))
        }
        print("[\(wind)出牌] \(tile)")
        if tilesRemaining.count > 0 {
            currentTurnWind = wind.next()
        } else {
            isEnd.send()
        }
    }
}
