//
//  LoginViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 12/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import Font_Awesome_Swift
import IotaKit

class LoginViewController: UIViewController {

	@IBOutlet weak var checksumLabel: UILabel!
	@IBOutlet weak var underlineBorder: UIView!
	@IBOutlet weak var seedTextField: UITextField!
	@IBOutlet weak var qrButton: UIButton!
	
	@IBOutlet weak var logoImageView: UIImageView!
	weak var overlay: UIView?
	override func viewDidLoad() {
        super.viewDidLoad()
		self.setupUI()
		self.setup()
    }
	
	fileprivate func setup() {
		self.qrButton.addTarget(self, action: #selector(LoginViewController.openQrCodeReader), for: .touchUpInside)
	}
	
	fileprivate func setupUI() {
		self.view.backgroundColor = .white
		self.underlineBorder.backgroundColor = Colors.foregroundColor
		self.logoImageView.image = self.logoImageView.image?.withRenderingMode(.alwaysTemplate)
		self.logoImageView.tintColor = Colors.foregroundColor
		self.qrButton.setFAIcon(icon: .FAQrcode, forState: .normal)
		self.qrButton.setTitleColor(Colors.foregroundColor, for: .normal)
		self.seedTextField.attributedPlaceholder = NSAttributedString(string:self.seedTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: Colors.foregroundColor])
		self.seedTextField.textColor = Colors.foregroundColor
		self.seedTextField.text = "DOWOCCYJILZYRVCMDKWOMWHMFB9KGGBNVXJSAXRBQJJOSIC9XQIYAFJSZPSPKYXWGAH9DRQSBY9PAGHUA"
		self.seedTextField.delegate = self
		self.updateChecksum()
	}
	
	fileprivate weak var scannerView: QRCodeScanView!
	@objc func openQrCodeReader() {
		let scanner = QRCodeScanView(frame: self.view.bounds)
		scanner.onString = { qrcode in
			if IotaAPIUtils.isSeed(qrcode) {
				self.onQRCodeReceived(qrCode: qrcode)
			}
		}
		scanner.onCancel = { self.closeQRView() }
		scanner.setup()
		self.view.addSubview(scanner)
		self.scannerView = scanner
		scanner.start()
	}
	
	fileprivate weak var loggingLabel: UILabel?
	func addLoadingOverlay() {
		let background = UIView(frame: self.view.bounds)
		background.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		self.view.addSubview(background)
		
		let title = UILabel()
		title.textColor = .white
		title.font = UIFont(name: "HelveticaNeue-Light", size: 20)
		title.textAlignment = .center
		title.text = "Logging in..."
		title.frame = CGRect(x: 0, y: 0, width: background.frame.size.width, height: 80)
		title.numberOfLines = 2
		title.center = background.center
		loggingLabel = title
		background.addSubview(title)
		
		background.alpha = 0.0
		UIView.animate(withDuration: 0.2) {
			background.alpha = 1.0
		}
		self.overlay = background
	}
	
	@IBAction func onLogin(_ sender: UIButton) {
//		if let pasteboard = UIPasteboard.general.string {
//			if IotaAPIUtils.isSeed(pasteboard) {
//				UIPasteboard.general.string = nil
//			}
//		}
		self.addLoadingOverlay()
		let seed = self.seedTextField.text!
		UserSession.current.seed = seed
		if UserSession.current.settings!.numberOfAddresses > 0 {
			//Percentage loading
		}
//		self.iota = Iota(prefersHTTPS: true) { (i) in
//			self.getAccountData(seed: seed)
//		}
		UserSession.current.iota = Iota(node: Constants.iotaAddress)
		self.getAccountData(seed: seed)
	}
	
	fileprivate func getAccountData(seed: String) {
		var numberOfAddresses = -1
		
		if let settings = UserSession.current.settings {
			numberOfAddresses = settings.numberOfAddresses
		}
		UserSession.current.iota.debug = true
		let address = UserSession.current.iota.address
		UserSession.current.iota.accountData(seed: seed, minimumNumberOfAddresses: numberOfAddresses, security: 2, requestTransactions: true, { (account) in
			UserSession.current.account = account
			DispatchQueue.main.async {
				self.overlay?.removeFromSuperview()
				let controller = self.storyboard!.instantiateViewController(withIdentifier: "MainViewController")
				self.navigationController?.pushViewController(controller, animated: true)
			}
		}, error: { (error) in
			DispatchQueue.main.async {
				self.overlay?.removeFromSuperview()
			}
			print(error)
		}) { (log) in
			DispatchQueue.main.async {
				self.loggingLabel?.text = "\(address)\n\(log.message)"
			}
		}
	}
	
	func onQRCodeReceived(qrCode: String) {
		self.seedTextField.text = qrCode
		self.updateChecksum()
		self.closeQRView()
	}
	
	func closeQRView() {
		self.scannerView.removeFromSuperview()
	}
	
	fileprivate func updateChecksum() {
		let seed = self.seedTextField.text ?? ""
		var message = ""
		if seed.count > 1 && seed.count < 81 {
			message = "Less than 81 characters"
		}else if seed.count == 81 {
			message = "Checksum: "+IotaAPIUtils.checksumForSeed(seed)
		}
		self.checksumLabel.text = message
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	@IBAction func seedTextFieldValueChanged(_ sender: UITextField) {
		self.updateChecksum()
	}
}

extension LoginViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentText = textField.text ?? ""
		let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
		if newText.count > 0 {
			return IotaAPIUtils.isSeed(newText)
		}
		return true
	}
}
