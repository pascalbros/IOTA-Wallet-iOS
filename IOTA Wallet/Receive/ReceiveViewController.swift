//
//  ReceiveViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 28/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import IotaKit
import MBProgressHUD

class ReceiveViewController: UIViewController {

	@IBOutlet weak var qrCodeImageView: UIImageView!
	@IBOutlet weak var logoutButton: UIButton!
	@IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var copyToClipboardButton: UIButton!
	override func viewDidLoad() {
        super.viewDidLoad()
		self.setupUI()
		self.setupAddress()
    }
	
	@IBAction func dismiss(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	fileprivate func setupUI() {
		self.logoutButton.setFAIcon(icon: .FASignOut, forState: .normal)
		self.qrCodeImageView.layer.magnificationFilter = CALayerContentsFilter.nearest
	}
	
	fileprivate func setupAddress() {
		let session = UserSession.current
		let addresses = session.account.addresses
		for address in addresses.reversed() {
			if address.canSpend! {
				self.setupUIWithAddress(address: address.hash)
				return
			}
		}
		
		self.setupUIForAddressGenerationOnly()
	}
	
	fileprivate func setupUIWithAddress(address: String) {
		self.qrCodeImageView.isHidden = false
		self.addressLabel.isHidden = false
		self.copyToClipboardButton.isHidden = false
		self.addressLabel.textAlignment = .left
		self.addressLabel.numberOfLines = 1
		
		self.qrCodeImageView.image = address.QRCodeImage
		self.addressLabel.text = address
	}
	
	fileprivate func setupUIForAddressGenerationOnly() {
		self.qrCodeImageView.setFAIconWithName(icon: .FAThumbsODown, textColor: .lightGray)
		self.addressLabel.numberOfLines = 2
		self.addressLabel.textAlignment = .center
		self.addressLabel.text = "No address available.\nGenerate a new one below"
		self.copyToClipboardButton.isHidden = true
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func copyToClipboard(_ sender: Any) {
		UIPasteboard.general.string = self.addressLabel.text!
		let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
		hud.mode = .text
		hud.animationType = .zoomIn
		hud.label.setFAIcon(icon: .FAClipboard, iconSize: hud.label.font.capHeight*2)
		hud.detailsLabel.text = "Copied!"
		hud.minShowTime = 1.0
		hud.backgroundView.isUserInteractionEnabled = true
		hud.hide(animated: true)
	}
	
	@IBAction func generateNewAddress(_ sender: Any) {
		
		let hud = MBProgressHUD.showAdded(to: self.tabBarController!.view, animated: true)
		hud.mode = .indeterminate
		hud.label.text = "Generating address..."
		hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		func error(_ e: Error) {
			DispatchQueue.main.async {
				hud.hide(animated: false)
				let alertController = UIAlertController(title: "An error as occurred", message: "Please try again", preferredStyle: .alert)
				let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
				alertController.addAction(action1)
				self.present(alertController, animated: true, completion: nil)
			}
		}
		
		func endWithAddress(_ address: String) {
			DispatchQueue.main.async {
				self.setupUIWithAddress(address: address)
				hud.mode = .text
				hud.label.setFAIcon(icon: .FACheck, iconSize: hud.label.font.capHeight*2)
				hud.detailsLabel.text = "Done!"
				hud.hide(animated: true, afterDelay: 1.0)
				UserSession.current.updateAccount(afterDelay: 5)
			}
		}
		
		UserSession.current.iota.attachToTangle(seed: UserSession.current.seed, index: UserSession.current.account.addresses.count, { (tx) in
			endWithAddress(tx.address)
		}, error: error)
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
