//
//  MainViewController.swift
//  AR Teddy
//
//  Created by Aulakh on 01/03/19.
//  Copyright © 2019 VajinderSingh. All rights reserved.
//
import UIKit
import AVKit

class MainViewController: UIViewController {
    //MARK:- Outlets
    @IBOutlet weak var scanTeddyBtn: UIButton!

    //MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    //MARK:- IBActions
    @IBAction func scanTeddyBtnClicked(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
