//
//  JKViewController.swift
//  JFKMahjong
//
//  Created by build on 2020/4/10.
//  Copyright © 2020 qianmeitech. All rights reserved.
//

import UIKit
import Combine

class JKViewController: UIViewController {
    
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    deinit {
        cancellables.forEach { (cancellable) in
            cancellable.cancel()
        }
    }

}
