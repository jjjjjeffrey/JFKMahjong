//
//  GuanNanMahjongScene.swift
//  JFKMahjong
//
//  Created by build on 2020/4/8.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit

enum MahjongTile: CustomStringConvertible {
    //数牌
    case rank(Int, Rank)
    //东南西北
    case wind(Wind)
    //中发白
    case dragon(Dragon)
    //春夏秋冬梅兰竹菊
    case flower(Flower)
    
    enum Rank: String, CaseIterable, CustomStringConvertible {
        case character, bamboo, dot //万条筒
        var description: String {
            get {
                switch self {
                case .character:
                    return "万"
                case .bamboo:
                    return "条"
                case .dot:
                    return "筒"
                }
            }
        }
    }
    
    enum Wind: String, CaseIterable, CustomStringConvertible {
        case east, south, west, north //东南西北
        var description: String {
            get {
                switch self {
                case .east:
                    return "东风"
                case .south:
                    return "南风"
                case .west:
                    return "西风"
                case .north:
                    return "北风"
                }
            }
        }
    }
    
    enum Dragon: String, CaseIterable, CustomStringConvertible {
        case red, green, white //中发白
        var description: String {
            get {
                switch self {
                case .red:
                    return "红中"
                case .green:
                    return "发财"
                case .white:
                    return "白板"
                }
            }
        }
    }
    
    enum Flower: String, CaseIterable, CustomStringConvertible {
        //春夏秋冬
        case spring, summer, autumn, winter
        //梅兰竹菊
        case plum, orchid, bamboo, chrysanthemum
        var description: String {
            get {
                switch self {
                case .spring:
                    return "春"
                case .summer:
                    return "夏"
                case .autumn:
                    return "秋"
                case .winter:
                    return "冬"
                case .plum:
                    return "梅"
                case .orchid:
                    return "兰"
                case .bamboo:
                    return "竹"
                case .chrysanthemum:
                    return "菊"
                }
            }
        }
    }
    
    var description: String {
        get {
            switch self {
            case let .rank(number, rank):
                return "\(number)\(rank)"
            case let .wind(wind):
                return "\(wind)"
            case let .dragon(dragon):
                return "\(dragon)"
            case let .flower(flower):
                return "\(flower)"
            }
        }
    }
}

class GuanNanMahjongScene: SKScene {
    
    
    
    override func sceneDidLoad() {
        let tiles = self.tiles
        print("共 \(tiles.count) 张牌")
        for tile in tiles {
            print(tile)
        }
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
