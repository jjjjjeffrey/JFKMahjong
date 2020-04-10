//
//  MahjongTile.swift
//  JFKMahjong
//
//  Created by build on 2020/4/9.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import Foundation

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
}
