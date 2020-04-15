//
//  SKView+Extensions.swift
//  JFKMahjong
//
//  Created by build on 2020/4/10.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import SpriteKit

extension SKView {
    var safeAreaLeft: CGFloat {
        get {
            safeAreaInsets.left
        }
    }
    var safeAreaRight: CGFloat {
        get {
            safeAreaInsets.right
        }
    }
    var safeAreaTop: CGFloat {
        get {
            safeAreaInsets.top
        }
    }
    var safeAreaBottom: CGFloat {
        get {
            safeAreaInsets.bottom
        }
    }
}
