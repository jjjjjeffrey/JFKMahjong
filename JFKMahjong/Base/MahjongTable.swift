//
//  MahjongTable.swift
//  JFKMahjong
//
//  Created by build on 2020/4/14.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import Foundation

class Die {
    var value: Int = 1
    func throwMe() {
        value = [1, 2, 3, 4, 5, 6].shuffled().first!
    }
}

class MahjongTable {
    
    let dies = [Die(), Die()]
    var seatsRemaining: [MahjongTile.Wind] = [.east, .south, .west, .north]
    
    //牌墙
    private var tilesWall: [MahjongTile.Wind: [MahjongTile]] = [:]
    //手牌
    private var userTiles: [MahjongTile.Wind: [MahjongTile]] = [.east:[], .south:[], .west:[], .north:[]]
    //剩余待抓牌
    private var tilesRemaining: [MahjongTile] = []
    //剩余不摸的牌（用来补花和杠后摸牌，发牌后起始余8张）
    private var tailTiles : [MahjongTile] = []
    //庄家
    private(set) var dealer: MahjongTile.Wind = .east
    
    //上桌
    func join() throws -> MahjongTile.Wind {
        if seatsRemaining.count > 0 {
            return seatsRemaining.remove(at: 0)
        } else {
            throw TableError.noRemainingSeats
        }
    }
    
    enum TableError: Error {
        case noRemainingSeats //没有剩余座位
        
        var localizedDescription: String {
            get {
                switch self {
                case .noRemainingSeats:
                    return "已坐满"
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
        dealer = MahjongTile.Wind(diesValue%4)!
        print("庄家: \(dealer)")
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
        var beginTilesWallWind : MahjongTile.Wind = dealer
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
        let secondUser = dealer.next()
        let thirdUser = secondUser.next()
        let fourthUser = thirdUser.next()
        for i in 0..<4 {
            if i < 3 {
                userTiles[dealer]?.append(contentsOf: currentTiles[i*16..<i*16+4])
                userTiles[secondUser]?.append(contentsOf: currentTiles[i*16+4..<i*16+4+4])
                userTiles[thirdUser]?.append(contentsOf: currentTiles[i*16+4+4..<i*16+4+4+4])
                userTiles[fourthUser]?.append(contentsOf: currentTiles[i*16+4+4+4..<i*16+4+4+4+4])
            } else {
                //前三轮抓走48张牌
                currentTiles = [MahjongTile](currentTiles[48..<currentTiles.endIndex])
                userTiles[dealer]?.append(currentTiles.remove(at: 0))
                userTiles[dealer]?.append(currentTiles.remove(at: 3))
                userTiles[secondUser]?.append(currentTiles.remove(at: 0))
                userTiles[thirdUser]?.append(currentTiles.remove(at: 0))
                userTiles[fourthUser]?.append(currentTiles.remove(at: 0))
            }
        }
        let dealResult = """
        发牌结果: \r
        \(dealer)\(userTiles[dealer]!)\r
        \(secondUser)\(userTiles[secondUser]!)\r
        \(thirdUser)\(userTiles[thirdUser]!)\r
        \(fourthUser)\(userTiles[fourthUser]!)\r
        """
        print(dealResult)
        tilesRemaining = currentTiles
        print("剩余待摸牌\(tilesRemaining.count)张: \(tilesRemaining)")
    }
    
    //获取手牌
    func getMyTiles(_ userWind: MahjongTile.Wind) -> [MahjongTile] {
        return userTiles[userWind] ?? []
    }
    
    //摸牌
    func draw() -> MahjongTile {
        
        
        
        return .wind(.east)
    }
}
