//
//  MahjongTile.swift
//  JFKMahjong
//
//  Created by build on 2020/4/9.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import Foundation

extension Sequence where Element == MahjongTile {
    func sort() -> [Element] {
        return sorted { (tile1, tile2) -> Bool in
            return tile1.sortValue < tile2.sortValue
        }
    }
}

enum MahjongTile: CustomStringConvertible {
    //数牌
    case rank(Int, Rank)
    //东南西北
    case wind(Wind)
    //中发白
    case dragon(Dragon)
    //春夏秋冬梅兰竹菊
    case flower(Flower)
    
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
    
    var imageName: String {
        get {
            switch self {
            case let .rank(number, rank):
                return "\(rank.rawValue)-\(number)"
            case let .wind(wind):
                return "\(wind.rawValue)"
            case let .dragon(dragon):
                return "\(dragon.rawValue)"
            case let .flower(flower):
                return "\(flower.rawValue)"
            }
        }
    }
    
    var sortValue: Int {
        get {
            switch self {
            case let .rank(number, rank): //1~27
                return number+rank.sortValue
            case let .wind(wind): //28~31
                return 28+wind.value
            case let .dragon(dragon): //32~34
                return 32+dragon.value
            case let .flower(flower): //35~42
                return 35+flower.value
            }
        }
    }
    
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
        
        var sortValue: Int {
            get {
                switch self {
                case .character:
                    return 0
                case .bamboo:
                    return 9
                case .dot:
                    return 18
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
        var value: Int {
            get {
                switch self {
                case .east:
                    return 0
                case .south:
                    return 1
                case .west:
                    return 2
                case .north:
                    return 3
                }
            }
        }
        
        init?(_ value: Int) {
            switch value {
            case 0:
                self = .east
            case 1:
                self = .south
            case 2:
                self = .west
            case 3:
                self = .north
            default:
                return nil
            }
        }
        
        func next() -> Self {
            return Wind((value+1)%4)!
        }
        
        func previous() -> Self {
            let previousValue = value == 0 ? 3 : value-1
            return Wind(previousValue)!
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
        
        var value: Int {
            get {
                switch self {
                case .red:
                    return 0
                case .green:
                    return 1
                case .white:
                    return 2
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
        
        var value: Int {
            get {
                switch self {
                case .spring:
                    return 0
                case .summer:
                    return 1
                case .autumn:
                    return 2
                case .winter:
                    return 3
                case .plum:
                    return 4
                case .orchid:
                    return 5
                case .bamboo:
                    return 6
                case .chrysanthemum:
                    return 7
                }
            }
        }
    }
}
