//
//  MahjongTable.swift
//  JFKMahjong
//
//  Created by build on 2020/4/14.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import Foundation
import Combine
import SwifterSwift

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
    //轮到谁出牌(出牌方，是否需要先抓牌)，碰牌后不需要抓牌
    var takeTurns = PassthroughSubject<(MahjongTile.Wind, Bool), Never>()
    //轮到谁决定是否碰牌(碰方，被碰方)
    var pong = PassthroughSubject<(MahjongTile.Wind, MahjongTile.Wind), Never>()
    //碰牌变化
    var poneTilesChanged = PassthroughSubject<(MahjongTile.Wind,[[MahjongTile]]), Never>()
    //出牌变化
    var discardedTilesChanged = PassthroughSubject<(MahjongTile.Wind,[MahjongTile]), Never>()
    //玩家手牌变化
    var gamerTilesChanged = PassthroughSubject<(MahjongTile.Wind,[MahjongTile]), Never>()
    //玩家花牌变化
    var gamerFlowerTilesChanged = PassthroughSubject<(MahjongTile.Wind,Int), Never>()
    
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
    private(set) var currentTurnWind: MahjongTile.Wind?
    
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
    //当前花牌数量
    private var eastFlowerTilesCount: Int = 0 {
        didSet {
            gamerFlowerTilesChanged.send((.east, eastFlowerTilesCount))
        }
    }
    private var southFlowerTilesCount: Int = 0 {
           didSet {
               gamerFlowerTilesChanged.send((.south, southFlowerTilesCount))
           }
    }
    private var westFlowerTilesCount: Int = 0 {
           didSet {
               gamerFlowerTilesChanged.send((.west, westFlowerTilesCount))
           }
    }
    private var northFlowerTilesCount: Int = 0 {
           didSet {
               gamerFlowerTilesChanged.send((.north, northFlowerTilesCount))
           }
    }
    //当前碰过的牌
    private var eastPoneTiles: [[MahjongTile]] = [] {
        didSet {
            poneTilesChanged.send((.east, eastPoneTiles))
        }
    }
    private var southPoneTiles: [[MahjongTile]] = [] {
           didSet {
               poneTilesChanged.send((.south, southPoneTiles))
           }
       }
    private var westPoneTiles: [[MahjongTile]] = [] {
           didSet {
               poneTilesChanged.send((.west, westPoneTiles))
           }
       }
    private var northPoneTiles: [[MahjongTile]] = [] {
           didSet {
               poneTilesChanged.send((.north, northPoneTiles))
           }
       }
    
    //出过的牌
    private var eastDiscardedTiles: [MahjongTile] = [] {
        didSet {
            discardedTilesChanged.send((.east, eastDiscardedTiles))
        }
    }
    private var southDiscardedTiles: [MahjongTile] = [] {
        didSet {
            discardedTilesChanged.send((.south, southDiscardedTiles))
        }
    }
    private var westDiscardedTiles: [MahjongTile] = [] {
        didSet {
            discardedTilesChanged.send((.west, westDiscardedTiles))
        }
    }
    private var northDiscardedTiles: [MahjongTile] = [] {
        didSet {
            discardedTilesChanged.send((.north, northDiscardedTiles))
        }
    }
    
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
        
        //补花
        flowerSupplement()

        currentTurnWind = dealerWind
        takeTurns.send((dealerWind, false))
    }
    
    //补花
    func flowerSupplement() {
        let secondUser = dealerWind.next()
        let thirdUser = secondUser.next()
        let fourthUser = thirdUser.next()
        //补花顺序
        let winds = [dealerWind, secondUser, thirdUser, fourthUser]
        
        for wind in winds {
            flowerSupplementForWind(wind)
        }
    }
    
    func flowerSupplementForWind(_ wind: MahjongTile.Wind) {
        switch wind {
        case .east:
            eastTiles = flowerSupplementForWind(wind, tiles: eastTiles).sort()
        case .south:
            southTiles = flowerSupplementForWind(wind, tiles: southTiles).sort()
        case .west:
            westTiles = flowerSupplementForWind(wind, tiles: westTiles).sort()
        case .north:
            northTiles = flowerSupplementForWind(wind, tiles: northTiles).sort()
        }
    }
    
    private func flowerSupplementForWind(_ wind: MahjongTile.Wind, tiles: [MahjongTile]) -> [MahjongTile] {
        print("[\(wind) 补花]")
        var tilesWithoutDragon = tiles
        tilesWithoutDragon.removeAll { (tile) -> Bool in
            switch tile {
            case .dragon:
                return true
            default:
                return false
            }
        }
        let countForSupplement = tiles.count - tilesWithoutDragon.count
        if countForSupplement > 0 {
            switch wind {
            case .east:
                eastFlowerTilesCount += countForSupplement
            case .south:
                southFlowerTilesCount += countForSupplement
            case .west:
                westFlowerTilesCount += countForSupplement
            case .north:
                northFlowerTilesCount += countForSupplement
            }
        }
        for _ in 0..<countForSupplement {
            let supplementTile = tailTiles.removeLast()
            tilesWithoutDragon.append(supplementTile)
            print("[补花 \(supplementTile)]")
            switch supplementTile {
            case .dragon:
                tilesWithoutDragon = flowerSupplementForWind(wind, tiles: tilesWithoutDragon)
            default:
                 break
            }
        }
        return tilesWithoutDragon
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
        case .south:
            southTiles.append(tile)
        case .west:
            westTiles.append(tile)
        case .north:
            northTiles.append(tile)
        }
        print("[\(wind)摸牌] \(tile)")
        
        //如果抓到花牌进行补花
        switch tile {
        case .dragon:
            flowerSupplementForWind(wind)
        default:
            break
        }
    }
    
    //出牌
    func discard(wind: MahjongTile.Wind, tileIndex: Int) {
        var tile: MahjongTile
        switch wind {
        case .east:
            tile = eastTiles.remove(at: tileIndex)
            eastTiles = eastTiles.sort()
            eastDiscardedTiles.append(tile)
        case .south:
            tile = southTiles.remove(at: tileIndex)
            southTiles = southTiles.sort()
            southDiscardedTiles.append(tile)
        case .west:
            tile = westTiles.remove(at: tileIndex)
            westTiles = westTiles.sort()
            westDiscardedTiles.append(tile)
        case .north:
            tile = northTiles.remove(at: tileIndex)
            northTiles = northTiles.sort()
            northDiscardedTiles.append(tile)
        }
        print("[\(wind)出牌] \(tile)")
        
        if let pongWind = pongCheckForWind(wind, tile: tile) {
            print("[\(pongWind) 决定是否碰 \(wind) 打出的 \(tile)]")
            pong.send((pongWind, wind))
        } else if tilesRemaining.count > 0 {
            currentTurnWind = wind.next()
            takeTurns.send((wind.next(), true))
        } else {
            isEnd.send()
        }
    }
    
    //碰牌检测
    private func pongCheckForWind(_ discardWind: MahjongTile.Wind, tile: MahjongTile) -> MahjongTile.Wind? {
        
        let wind1 = discardWind.next()
        let wind2 = wind1.next()
        let wind3 = wind2.next()
        
        let winds = [wind1, wind2, wind3]
        
        for wind in winds {
            let tiles = getTiles(wind)
            let tilesForPone = tiles.filter { (t) -> Bool in
                tile.sortValue == t.sortValue
            }
            if tilesForPone.count == 2 {
                return wind
            }
        }
        return nil
    }
    
    //碰
    func pong(_ wind: MahjongTile.Wind) {
        guard let currentTurnWind = currentTurnWind else {
            return
        }
        //要碰的牌是最后出的牌
        var poneTile: MahjongTile
        switch currentTurnWind {
        case .east:
            poneTile = eastDiscardedTiles.removeLast()
        case .south:
            poneTile = southDiscardedTiles.removeLast()
        case .west:
            poneTile = westDiscardedTiles.removeLast()
        case .north:
            poneTile = northDiscardedTiles.removeLast()
        }
        //从碰牌方手牌中找出要碰的牌
        let tiles = getTiles(wind)
        var tilesForPone = tiles.filter { (t) -> Bool in
            poneTile.sortValue == t.sortValue
        }
        tilesForPone.append(poneTile)
        //删除手牌中要碰的牌
        remove(poneTile, for: wind)
        
        switch wind {
        case .east:
            eastPoneTiles.append(tilesForPone)
        case .south:
            southPoneTiles.append(tilesForPone)
        case .west:
            westPoneTiles.append(tilesForPone)
        case .north:
            northPoneTiles.append(tilesForPone)
        }
        
        print("[\(wind) 碰 \(tilesForPone)]")
        
        self.currentTurnWind = wind
        takeTurns.send((wind, false))
    }
    
    private func remove(_ tile: MahjongTile, for wind: MahjongTile.Wind) {
        switch wind {
        case .east:
            eastTiles.removeAll { (t) -> Bool in
                tile.sortValue == t.sortValue
            }
        case .south:
            southTiles.removeAll { (t) -> Bool in
                tile.sortValue == t.sortValue
            }
        case .west:
            westTiles.removeAll { (t) -> Bool in
                tile.sortValue == t.sortValue
            }
        case .north:
            northTiles.removeAll { (t) -> Bool in
                tile.sortValue == t.sortValue
            }
        }
    }
}
