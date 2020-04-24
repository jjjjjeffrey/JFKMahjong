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
    
    var allTiles: [MahjongTile] = [
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
        tiles = tiles.sort()
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

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
