//
//  MahjongTableTests.swift
//  MahjongTableTests
//
//  Created by build on 2020/3/27.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import XCTest
@testable import JFKMahjong

class MahjongTableTests: XCTestCase {
    
    var table = MahjongTable()
    
    //所有的牌
    let allTiles: [MahjongTile] = [
        .rank(1, .character),.rank(1, .character),.rank(1, .character),.rank(1, .character),
        .rank(2, .character),.rank(2, .character),.rank(2, .character),.rank(2, .character),
        .rank(3, .character),.rank(3, .character),.rank(3, .character),.rank(3, .character),
        .rank(4, .character),.rank(4, .character),.rank(4, .character),.rank(4, .character),
        .rank(5, .character),.rank(5, .character),.rank(5, .character),.rank(5, .character),
        .rank(6, .character),.rank(6, .character),.rank(6, .character),.rank(6, .character),
        .rank(7, .character),.rank(7, .character),.rank(7, .character),.rank(7, .character),
        .rank(8, .character),.rank(8, .character),.rank(8, .character),.rank(8, .character),
        .rank(9, .character),.rank(9, .character),.rank(9, .character),.rank(9, .character),
        .rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),
        .rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),
        .rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),
        .rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),
        .rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),
        .rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),
        .rank(7, .bamboo),.rank(7, .bamboo),.rank(7, .bamboo),.rank(7, .bamboo),
        .rank(8, .bamboo),.rank(8, .bamboo),.rank(8, .bamboo),.rank(8, .bamboo),
        .rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),
        .rank(1, .dot),.rank(1, .dot),.rank(1, .dot),.rank(1, .dot),
        .rank(2, .dot),.rank(2, .dot),.rank(2, .dot),.rank(2, .dot),
        .rank(3, .dot),.rank(3, .dot),.rank(3, .dot),.rank(3, .dot),
        .rank(4, .dot),.rank(4, .dot),.rank(4, .dot),.rank(4, .dot),
        .rank(5, .dot),.rank(5, .dot),.rank(5, .dot),.rank(5, .dot),
        .rank(6, .dot),.rank(6, .dot),.rank(6, .dot),.rank(6, .dot),
        .rank(7, .dot),.rank(7, .dot),.rank(7, .dot),.rank(7, .dot),
        .rank(8, .dot),.rank(8, .dot),.rank(8, .dot),.rank(8, .dot),
        .rank(9, .dot),.rank(9, .dot),.rank(9, .dot),.rank(9, .dot),
        .dragon(.red), .dragon(.red), .dragon(.red), .dragon(.red)
    ]
    
    //起始抓牌顺序
    let tilesForDraw: [MahjongTile] = [
        .rank(4, .character),.rank(4, .character),.rank(4, .character),.rank(4, .character),
        .rank(5, .character),.rank(5, .character),.rank(5, .character),.rank(5, .character),
        .rank(6, .character),.rank(6, .character),.rank(6, .character),.rank(6, .character),
        .rank(7, .character),.rank(7, .character),.rank(7, .character),.rank(7, .character),
        .rank(4, .dot),.rank(4, .dot),.rank(4, .dot),.rank(4, .dot),
        .rank(5, .dot),.rank(5, .dot),.rank(5, .dot),.rank(5, .dot),
        .rank(6, .dot),.rank(6, .dot),.rank(6, .dot),.rank(6, .dot),
        .rank(7, .dot),.rank(7, .dot),.rank(7, .dot),.rank(7, .dot),
        .rank(8, .dot),.rank(8, .dot),.rank(8, .dot),.rank(8, .dot),
        .rank(9, .dot),.rank(9, .dot),.rank(9, .dot),.rank(9, .dot),
        .dragon(.red), .dragon(.red), .dragon(.red), .dragon(.red),
        .rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),
        .rank(7, .bamboo),.rank(7, .bamboo),.rank(7, .bamboo),.rank(7, .bamboo),
        .rank(8, .bamboo),.rank(8, .bamboo),.rank(8, .bamboo),.rank(8, .bamboo),
        .rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),
        .rank(1, .dot),.rank(1, .dot),.rank(1, .dot),.rank(1, .dot),
        .rank(2, .dot),.rank(2, .dot),.rank(2, .dot),.rank(2, .dot),
        .rank(3, .dot),.rank(3, .dot),.rank(3, .dot),.rank(3, .dot),
        .rank(8, .character),.rank(8, .character),.rank(8, .character),.rank(8, .character),
        .rank(9, .character),.rank(9, .character),.rank(9, .character),.rank(9, .character),
        .rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),
        .rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),
        .rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),
        .rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),
        .rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),
        .rank(1, .character),.rank(1, .character),.rank(1, .character),.rank(1, .character),
        .rank(2, .character),.rank(2, .character),.rank(2, .character),.rank(2, .character),
        .rank(3, .character),.rank(3, .character),.rank(3, .character),.rank(3, .character)
    ]
    
    //起始手牌
    let startTiles: [MahjongTile.Wind : [MahjongTile]] = [
        .east: [
            .rank(4, .character),.rank(4, .character),.rank(4, .character),.rank(4, .character),
            .rank(4, .dot),.rank(4, .dot),.rank(4, .dot),.rank(4, .dot),
            .rank(8, .dot),.rank(8, .dot),.rank(8, .dot),.rank(8, .dot),
            .rank(7, .bamboo),.rank(8, .bamboo)
        ],
        .south: [
            .rank(5, .character),.rank(5, .character),.rank(5, .character),.rank(5, .character),
            .rank(5, .dot),.rank(5, .dot),.rank(5, .dot),.rank(5, .dot),
            .rank(9, .dot),.rank(9, .dot),.rank(9, .dot),.rank(9, .dot),
            .rank(7, .bamboo)
        ],
        .west: [
            .rank(6, .character),.rank(6, .character),.rank(6, .character),.rank(6, .character),
            .rank(6, .dot),.rank(6, .dot),.rank(6, .dot),.rank(6, .dot),
            .dragon(.red), .dragon(.red), .dragon(.red), .dragon(.red),
            .rank(7, .bamboo)
        ],
        .north: [
            .rank(7, .character),.rank(7, .character),.rank(7, .character),.rank(7, .character),
            .rank(7, .dot),.rank(7, .dot),.rank(7, .dot),.rank(7, .dot),
            .rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),.rank(6, .bamboo),
            .rank(7, .bamboo)
        ]
    ]
    
    //起始抓牌后剩余牌
    let tilesRemainingAfterDrawBeginning: [MahjongTile] = [
        .rank(8, .bamboo),.rank(8, .bamboo),.rank(8, .bamboo),
        .rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),.rank(9, .bamboo),
        .rank(1, .dot),.rank(1, .dot),.rank(1, .dot),.rank(1, .dot),
        .rank(2, .dot),.rank(2, .dot),.rank(2, .dot),.rank(2, .dot),
        .rank(3, .dot),.rank(3, .dot),.rank(3, .dot),.rank(3, .dot),
        .rank(8, .character),.rank(8, .character),.rank(8, .character),.rank(8, .character),
        .rank(9, .character),.rank(9, .character),.rank(9, .character),.rank(9, .character),
        .rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),.rank(1, .bamboo),
        .rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),.rank(2, .bamboo),
        .rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),.rank(3, .bamboo),
        .rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),.rank(4, .bamboo),
        .rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),.rank(5, .bamboo),
        .rank(1, .character),.rank(1, .character),.rank(1, .character),.rank(1, .character),
        .rank(2, .character),.rank(2, .character),.rank(2, .character),.rank(2, .character),
        .rank(3, .character),.rank(3, .character),.rank(3, .character),.rank(3, .character)
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAllTiles() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let tiles = table.allTiles()
        XCTAssertEqual(tiles, allTiles)
    }
    
    func testShufflingTheTiles() throws {
        let tilesWall = table.shufflingTheTiles()
        var tiles: [MahjongTile] = []
        for wind in tilesWall.keys {
            if let windTiles = tilesWall[wind] {
                tiles.append(contentsOf: windTiles)
            }
        }
        tiles = tiles.sorted()
        XCTAssertEqual(tiles, allTiles)
    }
    
    func testConfirmDealerByDies() throws {
        var dies = [Die(value: 3), Die(value: 4)]
        var dealerWind = table.confirmDealerByDies(dies)
        XCTAssertEqual(dealerWind, .north)
        
        dies = [Die(value: 6), Die(value: 6)]
        dealerWind = table.confirmDealerByDies(dies)
        XCTAssertEqual(dealerWind, .east)
        
        dies = [Die(value: 1), Die(value: 5)]
        dealerWind = table.confirmDealerByDies(dies)
        XCTAssertEqual(dealerWind, .west)
        
        dies = [Die(value: 2), Die(value: 3)]
        dealerWind = table.confirmDealerByDies(dies)
        XCTAssertEqual(dealerWind, .south)
    }
    
    func testGetDrawBeginningSiteByDies() throws {
        var dies = [Die(value: 3), Die(value: 4)]
        var dealer = MahjongTile.Wind.east
        var beginSite = table.getDrawBeginningSiteByDies(dies, dealer: dealer)
        XCTAssertEqual(beginSite, .west)
        
        dies = [Die(value: 4), Die(value: 5)]
        dealer = MahjongTile.Wind.east
        beginSite = table.getDrawBeginningSiteByDies(dies, dealer: dealer)
        XCTAssertEqual(beginSite, .south)
        
        dies = [Die(value: 5), Die(value: 6)]
        dealer = MahjongTile.Wind.east
        beginSite = table.getDrawBeginningSiteByDies(dies, dealer: dealer)
        XCTAssertEqual(beginSite, .east)
        
        dies = [Die(value: 6), Die(value: 6)]
        dealer = MahjongTile.Wind.east
        beginSite = table.getDrawBeginningSiteByDies(dies, dealer: dealer)
        XCTAssertEqual(beginSite, .north)
    }
    
    func testGetTilesForDrawByDies() throws {
        let dies = [Die(value: 3), Die(value: 4)]
        let beginSite = MahjongTile.Wind.east
        var tilesWall: [MahjongTile.Wind: [MahjongTile]] = [:]
        let allTiles = table.allTiles()
        let tilesCount = allTiles.count
        for (i,wind) in MahjongTile.Wind.allCases.enumerated() {
            tilesWall[wind] = [MahjongTile](allTiles[i*tilesCount/4..<i*tilesCount/4+tilesCount/4])
        }
        let currentTiles = table.getTilesForDrawByDies(dies, beginSite: beginSite, tilesWall: tilesWall)
        XCTAssertEqual(currentTiles, tilesForDraw)
    }
    
    func testGetStartTiles() throws {
        var tilesForDraw = self.tilesForDraw
        let winds: [MahjongTile.Wind] = [.east, .south, .west, .north]
        let startTiles = table.getStartTiles(&tilesForDraw, winds: winds)
        XCTAssertEqual(startTiles, self.startTiles)
        XCTAssertEqual(tilesForDraw, tilesRemainingAfterDrawBeginning)
    }
    
    func testFlowerSupplementForTiles() throws {
        var tiles: [MahjongTile] = [
            .rank(1, .character), .rank(2, .character), .rank(3, .character),
            .rank(1, .bamboo), .rank(2, .bamboo), .rank(3, .bamboo),
            .rank(1, .dot), .rank(2, .dot), .rank(3, .dot),
            .dragon(.red), .dragon(.red), .rank(7, .bamboo), .rank(9, .bamboo)
        ]
        
        var drawFrom: [MahjongTile] = [
            .rank(5, .character), .rank(6, .character), .rank(7, .character), .rank(8, .character),
            .rank(6, .bamboo), .rank(7, .bamboo), .rank(8, .bamboo), .rank(9, .bamboo)
        ]
        
        var flowerCount = 0
        
        table.flowerSupplementForTiles(&tiles, drawFrom: &drawFrom, flowerCount: &flowerCount)
        
        let tilesAfter: [MahjongTile] = [
            .rank(1, .character), .rank(2, .character), .rank(3, .character),
            .rank(1, .bamboo), .rank(2, .bamboo), .rank(3, .bamboo),
            .rank(1, .dot), .rank(2, .dot), .rank(3, .dot),
            .rank(7, .bamboo), .rank(9, .bamboo), .rank(9, .bamboo), .rank(8, .bamboo)
        ]
        
        let drawFromAfter: [MahjongTile] = [
            .rank(5, .character), .rank(6, .character), .rank(7, .character), .rank(8, .character),
            .rank(6, .bamboo), .rank(7, .bamboo)
        ]
        
        let flowerCountAfter = 2
        
        XCTAssertEqual(tiles, tilesAfter)
        XCTAssertEqual(drawFrom, drawFromAfter)
        XCTAssertEqual(flowerCount, flowerCountAfter)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
