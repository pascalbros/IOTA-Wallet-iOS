//
//  SendViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 28/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import IotaKit
import MBProgressHUD

fileprivate enum AddressError {
	case network
	case invalid
	case doNotExist
	case spent
}

class SendViewController: UIViewController {
	
	@IBOutlet weak var valuePicker: UIIotaValuePicker!
	
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var addressLabel: UILabel!
	
	fileprivate var currentUnit: IotaUnits = .i
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
	}
	
	fileprivate func setupUI() {
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	fileprivate func addAddress(_ address: String) {
		
		let hud = MBProgressHUD.showAdded(to: self.tabBarController!.view, animated: true)
		hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
		hud.mode = .indeterminate
		hud.animationType = .zoomIn
		hud.label.text = "Checking address..."

		func error(type: AddressError) {
			var message = ""
			switch type {
			case .network: message = "Network error, please try again"
			case .doNotExist: message = "The address does not exist"
			case .invalid: message = "The address is invalid"
			case .spent: message = "The address has been used already, ask to the owner to generate a new one"
			}
			self.addressLabel.text = ""
			self.showError(title: "An error as occurred", message: message)
		}
		
		func success(addr: String) {
			DispatchQueue.main.async {
				self.addressLabel.text = addr
			}
			self.showDone()
		}
		
		var isValid = false
		if IotaAPIUtils.isAddress(address) {
			if IotaChecksum.isAddressWithChecksum(address: address) {
				if IotaChecksum.isValidChecksum(address: address) {
					isValid = true
				}
			}else{
				isValid = true
			}
		}
		
		guard isValid else {
			error(type: .invalid)
			return
		}
		let normalized = IotaChecksum.isAddressWithoutChecksum(address: address) ? address : IotaChecksum.removeChecksum(address: address)!
		
		UserSession.current.iota.findTransactions(addresses: [normalized], { (txs) in
			if txs.count == 0 {
				error(type: .doNotExist)
				return
			}
			UserSession.current.iota.wereAddressesSpentFrom(addresses: [normalized], { (spent) in
				if spent.first! {
					error(type: .spent)
				}else{
					success(addr: normalized)
				}
			}, { (e) in
				error(type: .network)
			})
		}) { (e) in
			error(type: .network)
		}
	}
	
	fileprivate weak var scannerView: QRCodeScanView!
	@IBAction func scanAddress(_ sender: Any) {
		let scanner = QRCodeScanView(frame: self.tabBarController!.view.bounds)
		scanner.onString = { qrcode in
			self.scannerView.removeFromSuperview()
			self.addAddress(qrcode)
		}
		scanner.onCancel = { self.scannerView.removeFromSuperview() }
		scanner.setup()
		self.tabBarController!.view.addSubview(scanner)
		self.scannerView = scanner
		scanner.start()
	}
	
	@IBAction func pasteAddress(_ sender: Any) {
		self.addAddress(UIPasteboard.general.string ?? "")
	}
	
	@IBAction func reviewTransfer(_ sender: Any) {
		
		guard let amount = UInt(self.amountTextField.text!) else { showError(title: "Error with value", message: "Cannot convert to a number"); return }
		guard let address = self.addressLabel.text else {
			showError(title: "Address error", message: "Please type a valid address"); return
		}
		guard IotaAPIUtils.isAddress(address) else {
			showError(title: "Address error", message: "Please type a valid address"); return
		}
		if amount > 0 {
			let tx = PaymentReview(value: UInt64(amount), valueLabel: self.amountTextField.text! + " \(self.currentUnit.string)", address: address)
			let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReviewPaymentViewController") as! ReviewPaymentViewController
			controller.transaction = tx
			self.tabBarController?.present(controller, animated: true, completion: nil)
			return
			//self.sendTransfer(amountInIota: amount, toAddress: self.addressLabel.text!)
		}else{
			showError(title: "Error with value", message: "It must be better than 0")
		}
	}
	
	fileprivate func sendTransfer(amountInIota: UInt64, toAddress to: String) {
		
		let hud = MBProgressHUD.showAdded(to: self.tabBarController!.view, animated: true)
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
				//self.showDone()
				self.showError(title: "Tx test", message: "Elapsed time \(Date().timeIntervalSince(startTime))")
				UserSession.current.updateAccount()
			}) { (error) in
				self.showError(title: "An error as occurred", message: (error as! IotaAPIError).message)
				DispatchQueue.main.async {
				}
			}
		}
		sendTransfers()
	}
	
	fileprivate func showDone() {
		DispatchQueue.main.async {
			guard let hud = MBProgressHUD(for: self.tabBarController!.view) else { return }
			hud.mode = .text
			hud.label.setFAIcon(icon: .FACheck, iconSize: 30)
			hud.detailsLabel.text = "Done"
			hud.hide(animated: true, afterDelay: 1.5)
		}
	}
	
	fileprivate func showError(title: String, message: String) {
		DispatchQueue.main.async {
			_ = MBProgressHUD.hide(for: self.tabBarController!.view, animated: false)
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
			let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
			alertController.addAction(action1)
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	@IBAction func showValuePicker(_ sender: UIButton) {
		let picker = UIIotaValuePicker(elementSize: sender.bounds.size)
		picker.backgroundColor = .lightGray
		let y = picker.elementSize.height*0
		var frame = picker.frame
		frame.origin = sender.frame.origin
		frame.origin.y += y
		picker.frame = frame
		picker.setup(currentUnit: self.currentUnit)
		self.view.addSubview(picker)
		
		picker.onElementSelected = { unit, picker in
			self.currentUnit = unit
			sender.setTitle(unit.string, for: .normal)
			picker.removeFromSuperview()
		}
	}
	
}
