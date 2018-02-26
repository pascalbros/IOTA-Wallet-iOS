//
//  ReviewPaymentViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 05/02/2018.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import MBProgressHUD
import IotaKit

struct PaymentReview {
	let value: UInt64
	let valueLabel: String
	let address: String
}

class ReviewPaymentViewController: UIViewController {

	var transaction: PaymentReview!
	@IBOutlet weak var valueLabel: UILabel!
	
	@IBOutlet weak var addressLabel: UILabel!
	override func viewDidLoad() {
        super.viewDidLoad()
		self.valueLabel.text = self.transaction.valueLabel
		self.addressLabel.text = self.transaction.address
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func sendPayment(_ sender: Any) {
		self.sendTransfer(amountInIota: UInt(self.transaction.value), toAddress: self.transaction.address)
	}
	
	@IBAction func dismiss(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	fileprivate func sendTransfer(amountInIota: UInt, toAddress to: String) {
		
		let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
		hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		hud.mode = .indeterminate
		hud.animationType = .zoomIn
		hud.label.text = "Checking account"
		let startTime = Date()
		func sendTransfers() {
			DispatchQueue.main.async {
				hud.label.text = "Sending transaction"
			}
			let normalized = IotaChecksum.isAddressWithoutChecksum(address: to) ? to : IotaChecksum.removeChecksum(address: to)!
			let transfers = [IotaTransfer(address: normalized, value: amountInIota, timestamp: nil, hash: nil, persistence: false, message: "", tag: "")]
			
			UserSession.current.iota.sendTransfers(seed: UserSession.current.seed, transfers: transfers, inputs: nil, remainderAddress: nil, { (txs) in
				self.showDone()
				//self.showError(title: "Tx test", message: "Elapsed time \(Date().timeIntervalSince(startTime))")
				UserSession.current.updateAccount()
			}) { (error) in
				self.showError(title: "An error as occurred", message: (error as! IotaAPIError).message)
				DispatchQueue.main.async {
				}
			}
		}
		sendTransfers()
	}
	
	fileprivate func showError(title: String, message: String) {
		DispatchQueue.main.async {
			_ = MBProgressHUD.hide(for: self.view, animated: false)
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
			alertController.addAction(action1)
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	fileprivate func showDone() {
		DispatchQueue.main.async {
			guard let hud = MBProgressHUD(for: self.view) else { return }
			hud.mode = .text
			hud.label.setFAIcon(icon: .FACheck, iconSize: 30)
			hud.detailsLabel.text = "Payment sent"
			hud.hide(animated: true, afterDelay: 3.0)
			hud.completionBlock = {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}

}
