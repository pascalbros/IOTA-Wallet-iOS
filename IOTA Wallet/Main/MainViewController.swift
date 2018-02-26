//
//  MainViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 28/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import Font_Awesome_Swift

fileprivate var icons: [FAType] = [.FACreditCardAlt, .FAMoney, .FAPaperPlane]

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
	
	var isFirstTime = true
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if isFirstTime {
			isFirstTime = false
			for i in 0..<self.tabBar.items!.count {
				self.tabBar.items![i].setFAIcon(icon: icons[i], textColor: .lightGray, selectedTextColor: self.tabBar.tintColor)
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
