//
//  BalanceLabel.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 31/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import IotaKit

class BalanceLabel: UILabel {
	
	var extendedFormat = false
	var iotaBalance: UInt64 = 0 {
		didSet(oldValue) {
			self.onBalanceChanged()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.isUserInteractionEnabled = true
		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BalanceLabel.changeFormat(sender:))))
	}
	
	@objc func changeFormat(sender: Any) {
		self.changeFormat(animated: true)
	}
	
	func changeFormat(animated: Bool) {
		self.extendedFormat = !self.extendedFormat
		if !animated { self.onBalanceChanged(); return }
		
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, animations: {
				self.alpha = 0.0
			}, completion: { (completed) in
				self.onBalanceChanged()
				UIView.animate(withDuration: 0.2) { self.alpha = 1.0 }
			})
		}
	}
	
	fileprivate func onBalanceChanged() {
		self.text = IotaUnitsConverter.iotaToString(amount: self.iotaBalance, extended: self.extendedFormat)
	}
}
