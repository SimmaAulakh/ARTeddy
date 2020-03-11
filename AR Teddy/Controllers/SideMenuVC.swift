//
//  SideMenuVC.swift
//  AR Teddy
//
//  Created by Aulakh on 14/03/19.
//  Copyright © 2019 VajinderSingh. All rights reserved.
//
import UIKit

class SideMenuVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
    }
    

    @IBAction func aboutRooseveltBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func earlyLifeBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EarlyLifeViewController") as? EarlyLifeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
