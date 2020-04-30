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

struct Die: Comparable {
    var value: Int
    
    mutating func throwMe() {
        value = [1, 2, 3, 4, 5, 6].shuffled().first!
    }
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.value < rhs.value
    }

    static func <= (lhs: Self, rhs: Self) -> Bool {
        return lhs.value <= rhs.value
    }

    static func >= (lhs: Self, rhs: Self) -> Bool {
        return lhs.value >= rhs.value
    }

    static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.value > rhs.value
    }
}

class MahjongTable {
    
    var dies = [Die(value: 1), Die(value: 1)]
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
    //轮到谁决定是否杠出牌方的牌(杠方，被杠方)
    var kongOther = PassthroughSubject<(MahjongTile.Wind, MahjongTile.Wind), Never>()
    //碰牌变化
    var pongTilesChanged = PassthroughSubject<(MahjongTile.Wind,[[MahjongTile]]), Never>()
    //杠牌变化
    var kongTilesChanged = PassthroughSubject<(MahjongTile.Wind,[[MahjongTile]]), Never>()
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
            eastTiles = startTiles[.east]?.sorted() ?? []
            southTiles = startTiles[.south]?.sorted() ?? []
            westTiles = startTiles[.west]?.sorted() ?? []
            northTiles = startTiles[.north]?.sorted() ?? []
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
    private var eastPongTiles: [[MahjongTile]] = [] {
        didSet {
            pongTilesChanged.send((.east, eastPongTiles))
        }
    }
    private var southPoneTiles: [[MahjongTile]] = [] {
        didSet {
            pongTilesChanged.send((.south, southPoneTiles))
        }
    }
    private var westPoneTiles: [[MahjongTile]] = [] {
        didSet {
            pongTilesChanged.send((.west, westPoneTiles))
        }
    }
    private var northPoneTiles: [[MahjongTile]] = [] {
        didSet {
            pongTilesChanged.send((.north, northPoneTiles))
        }
    }
    //当前杠 过的牌
    private var eastKongTiles: [[MahjongTile]] = [] {
        didSet {
            kongTilesChanged.send((.east, eastKongTiles))
        }
    }
    private var southKongTiles: [[MahjongTile]] = [] {
        didSet {
            kongTilesChanged.send((.south, southKongTiles))
        }
       }
    private var westKongTiles: [[MahjongTile]] = [] {
        didSet {
            kongTilesChanged.send((.west, westKongTiles))
        }
    }
    private var northKongTiles: [[MahjongTile]] = [] {
        didSet {
            kongTilesChanged.send((.north, northKongTiles))
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
    //开始一局游戏
    func startGame() {
        //洗牌
        tilesWall = shufflingTheTiles()
        //掷骰子确定庄家
        dies = throwDies()
        dealerWind = confirmDealerByDies(dies)
        //掷骰子确定抓牌位置
        dies = throwDies()
        //发牌
        dealByDies(dies)
    }
    
    //掷骰子
    func throwDies() -> [Die] {
        var die1 = Die(value: 1)
        var die2 = Die(value: 1)
        die1.throwMe()
        die2.throwMe()
        let dies = [die1, die2]
        print("骰子: \(dies[0].value) \(dies[1].value)")
        return dies
    }
    //洗牌
    func shufflingTheTiles() -> [MahjongTile.Wind: [MahjongTile]] {
        var tiles: [MahjongTile] = allTiles()
        tiles = tiles.shuffled()
        print("共 \(tiles.count) 张牌")
        var tilesWall: [MahjongTile.Wind: [MahjongTile]] = [:]
        for (i,wind) in MahjongTile.Wind.allCases.enumerated() {
            let subtiles = tiles[i*28..<i*28+28]
            tilesWall[wind] = [MahjongTile](subtiles)
            print("\(wind) \(tilesWall[wind]!.count)张 \(tilesWall[wind]!)")
        }
        return tilesWall
    }
    //顺序排列的所有牌
    func allTiles() -> [MahjongTile] {
        var tiles: [MahjongTile] = []
        for rank in MahjongTile.Rank.allCases {
            for i in 0..<9 {
                tiles.append(contentsOf: [.rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank), .rank(i+1, rank)])
            }
        }
        tiles.append(contentsOf: [.dragon(.red), .dragon(.red), .dragon(.red), .dragon(.red)])
        return tiles
    }
    
    //确定庄家Dealer
    func confirmDealerByDies(_ dies: [Die]) -> MahjongTile.Wind {
        let diesValue = dies[0].value + dies[1].value
        let dealerWind = MahjongTile.Wind(diesValue%4)!
        print("庄家: \(dealerWind)")
        return dealerWind
    }
    
    //发牌
    //发牌规则：比如骰子3、5，从庄家开始顺时针数到3的位置牌墙，从牌墙右手边留3*4张牌开始抓牌
    //骰子5、6，从庄家开始顺时针数到5的位置牌墙，从牌墙右手边留5*4张牌开始抓牌
    func dealByDies(_ dies: [Die]) {
        //确定起始抓牌牌墙
        let beginSite = getDrawBeginningSiteByDies(dies, dealer: dealerWind)
        print("起始牌墙: \(beginSite)")
        
        //排序要抓的牌
        var tilesForDraw = getTilesForDrawByDies(dies, beginSite: beginSite, tilesWall: tilesWall)
        print("待抓牌\(tilesForDraw.count)张：\(tilesForDraw)")
        
        //尾部留8张牌
        tailTiles = [MahjongTile](tilesForDraw[tilesForDraw.endIndex-8..<tilesForDraw.endIndex])
        print("尾部留8张牌: \(tailTiles)")
        
        tilesForDraw = tilesForDraw.dropLast(8)
        print("剩余待抓牌\(tilesForDraw.count)张：\(tilesForDraw)")
        
        //抓4圈，前3圈每人依次抓4张，最后一圈庄家抓2张，其他人抓1张，庄家14张，其他人13张
        let secondUser = dealerWind.next()
        let thirdUser = secondUser.next()
        let fourthUser = thirdUser.next()
        //抓牌顺序
        let winds = [dealerWind, secondUser, thirdUser, fourthUser]
        
        startTiles = getStartTiles(&tilesForDraw, winds: winds)
        let dealResult = """
        发牌结果: \r
        \(dealerWind)\(startTiles[dealerWind]!)\r
        \(secondUser)\(startTiles[secondUser]!)\r
        \(thirdUser)\(startTiles[thirdUser]!)\r
        \(fourthUser)\(startTiles[fourthUser]!)\r
        """
        print(dealResult)
        tilesRemaining = tilesForDraw
        print("剩余待摸牌\(tilesRemaining.count)张: \(tilesRemaining)")
        
        //补花
        flowerSupplement()

        currentTurnWind = dealerWind
        takeTurns.send((dealerWind, false))
    }
    
    //根据骰子确定起始抓牌位置
    func getDrawBeginningSiteByDies(_ dies: [Die], dealer: MahjongTile.Wind) -> MahjongTile.Wind {
        let minDieValue = dies.min { (die1, die2) -> Bool in
            die1 < die2
        }.map { (die) -> Int in
            return die.value
        }!
        
        //从庄家位置顺时针数
        var site = dealer
        for _ in 0..<minDieValue-1 {
            site = site.previous()
        }
        return site
    }
    //根据骰子和开始位置给出排序后的牌
    func getTilesForDrawByDies(_ dies: [Die], beginSite: MahjongTile.Wind, tilesWall: [MahjongTile.Wind: [MahjongTile]]) -> [MahjongTile] {
        let minDieValue = dies.min { (die1, die2) -> Bool in
            die1 < die2
        }.map { (die) -> Int in
            return die.value
        }!
        //抓牌起始留牌数
        let keepCount = minDieValue*4
        //待抓的牌
        var currentTilesWallWind = beginSite
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
        currentTiles.append(contentsOf: tilesWall[beginSite]![0..<keepCount])
        return currentTiles
    }
    
    //分配起始手牌
    func getStartTiles(_ tilesForDraw: inout [MahjongTile], winds: [MahjongTile.Wind]) -> [MahjongTile.Wind: [MahjongTile]] {
        var startTiles: [MahjongTile.Wind: [MahjongTile]] = [.east:[], .south:[], .west:[], .north:[]]

        for i in 0..<4 {
            if i < 3 {
                for (j,wind) in winds.enumerated() {
                    let tiles = tilesForDraw[i*16+j*4..<i*16+(j+1)*4]
                    startTiles[wind]?.append(contentsOf: tiles)
                    print("\(wind)拿牌 \(tiles)")
                }
            } else {
                //前三轮抓走48张牌
                tilesForDraw = [MahjongTile](tilesForDraw[48..<tilesForDraw.endIndex])
                
                for (i,wind) in winds.enumerated() {
                    if i == 0 {
                        startTiles[wind]?.append(tilesForDraw.remove(at: 0))
                        startTiles[wind]?.append(tilesForDraw.remove(at: 3))
                    } else {
                        startTiles[wind]?.append(tilesForDraw.remove(at: 0))
                    }
                }
            }
        }
        
        return startTiles
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
        print("[\(wind) 补花]")
        switch wind {
        case .east:
            flowerSupplementForTiles(&eastTiles, drawFrom: &tailTiles, flowerCount: &eastFlowerTilesCount)
            eastTiles.sort()
        case .south:
            flowerSupplementForTiles(&southTiles, drawFrom: &tailTiles, flowerCount: &southFlowerTilesCount)
            southTiles.sort()
        case .west:
            flowerSupplementForTiles(&westTiles, drawFrom: &tailTiles, flowerCount: &westFlowerTilesCount)
            westTiles.sort()
        case .north:
            flowerSupplementForTiles(&northTiles, drawFrom: &tailTiles, flowerCount: &northFlowerTilesCount)
            northTiles.sort()
        }
    }
    
    //tiles: 需要补花的手牌
    //drawFrom: 补花要抓的牌
    //flowerCount: 用于更新的花牌数量
    func flowerSupplementForTiles(_ tiles: inout [MahjongTile], drawFrom: inout [MahjongTile], flowerCount: inout Int) {
        //补花前牌数量
        let originalCount = tiles.count
        //去掉花牌
        tiles.removeAll { (tile) -> Bool in
            switch tile {
            case .dragon:
                return true
            default:
                return false
            }
        }
        //花牌数量
        let countForSupplement = originalCount - tiles.count
        flowerCount += countForSupplement
        
        for _ in 0..<countForSupplement {
            let supplementTile = drawFrom.removeLast()
            tiles.append(supplementTile)
            print("[补花 \(supplementTile)]")
            switch supplementTile {
            case .dragon:
                flowerSupplementForTiles(&tiles, drawFrom: &drawFrom, flowerCount: &flowerCount)
            default:
                 break
            }
        }
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
            eastTiles = eastTiles.sorted()
            eastDiscardedTiles.append(tile)
        case .south:
            tile = southTiles.remove(at: tileIndex)
            southTiles = southTiles.sorted()
            southDiscardedTiles.append(tile)
        case .west:
            tile = westTiles.remove(at: tileIndex)
            westTiles = westTiles.sorted()
            westDiscardedTiles.append(tile)
        case .north:
            tile = northTiles.remove(at: tileIndex)
            northTiles = northTiles.sorted()
            northDiscardedTiles.append(tile)
        }
        print("[\(wind)出牌] \(tile)")
        
        var `continue` = true
        if let pongWind = pongCheckForWind(wind, tile: tile) {
            print("[\(pongWind) 决定是否碰 \(wind) 打出的 \(tile)]")
            `continue` = false
            pong.send((pongWind, wind))
        }
        
        if let kongWind = kongOtherCheckForWind(wind, tile: tile) {
            print("[\(kongWind) 决定是否杠 \(wind) 打出的 \(tile)]")
            `continue` = false
            kongOther.send((kongWind, wind))
        }
        
        guard `continue` else {
            return
        }
        
        if tilesRemaining.count > 0 {
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
                tile == t
            }
            //手牌有两张相同的牌说明可以碰牌
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
        var pongTile: MahjongTile
        switch currentTurnWind {
        case .east:
            pongTile = eastDiscardedTiles.removeLast()
        case .south:
            pongTile = southDiscardedTiles.removeLast()
        case .west:
            pongTile = westDiscardedTiles.removeLast()
        case .north:
            pongTile = northDiscardedTiles.removeLast()
        }
        //从碰牌方手牌中找出要碰的牌
        let tiles = getTiles(wind)
        var tilesForPong = tiles.filter { (t) -> Bool in
            pongTile == t
        }
        tilesForPong.append(pongTile)
        //删除手牌中要碰的牌
        remove(pongTile, for: wind)
        
        switch wind {
        case .east:
            eastPongTiles.append(tilesForPong)
        case .south:
            southPoneTiles.append(tilesForPong)
        case .west:
            westPoneTiles.append(tilesForPong)
        case .north:
            northPoneTiles.append(tilesForPong)
        }
        
        print("[\(wind) 碰 \(tilesForPong)]")
        
        self.currentTurnWind = wind
        takeTurns.send((wind, false))
    }
    //放弃碰杠胡牌
    func `continue`(_ wind: MahjongTile.Wind) {
        print("[\(wind) 放弃了碰杠胡]")
        if let nextTurnWind = currentTurnWind?.next() {
            currentTurnWind = nextTurnWind
            takeTurns.send((nextTurnWind,true))
        }
    }
    
    //外杠牌检测
    private func kongOtherCheckForWind(_ discardWind: MahjongTile.Wind, tile: MahjongTile) -> MahjongTile.Wind? {
        let wind1 = discardWind.next()
        let wind2 = wind1.next()
        let wind3 = wind2.next()
        
        let winds = [wind1, wind2, wind3]
        
        for wind in winds {
            let tiles = getTiles(wind)
            let tilesForPone = tiles.filter { (t) -> Bool in
                tile == t
            }
            //手牌有三张相同的牌说明可以杠牌
            if tilesForPone.count == 3 {
                return wind
            }
        }
        return nil
    }
    //外杠
    func kongOther(_ wind: MahjongTile.Wind) {
        guard let currentTurnWind = currentTurnWind else {
            return
        }
        //要杠的牌是最后出的牌
        var koneTile: MahjongTile
        switch currentTurnWind {
        case .east:
            koneTile = eastDiscardedTiles.removeLast()
        case .south:
            koneTile = southDiscardedTiles.removeLast()
        case .west:
            koneTile = westDiscardedTiles.removeLast()
        case .north:
            koneTile = northDiscardedTiles.removeLast()
        }
        //从杠牌方手牌中找出要杠的牌
        let tiles = getTiles(wind)
        var tilesForKong = tiles.filter { (t) -> Bool in
            koneTile == t
        }
        tilesForKong.append(koneTile)
        //删除手牌中要碰的牌
        remove(koneTile, for: wind)
        
        switch wind {
        case .east:
            eastKongTiles.append(tilesForKong)
        case .south:
            southKongTiles.append(tilesForKong)
        case .west:
            westKongTiles.append(tilesForKong)
        case .north:
            northKongTiles.append(tilesForKong)
        }
        
        print("[\(wind) 杠 \(tilesForKong)]")
        
        self.currentTurnWind = wind
        takeTurns.send((wind, false))
    }
    
    private func remove(_ tile: MahjongTile, for wind: MahjongTile.Wind) {
        switch wind {
        case .east:
            eastTiles.removeAll { (t) -> Bool in
                tile == t
            }
        case .south:
            southTiles.removeAll { (t) -> Bool in
                tile == t
            }
        case .west:
            westTiles.removeAll { (t) -> Bool in
                tile == t
            }
        case .north:
            northTiles.removeAll { (t) -> Bool in
                tile == t
            }
        }
    }
}
