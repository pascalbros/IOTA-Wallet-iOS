//
//  QRCodeScanView.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 31/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import IotaKit

class QRCodeScanView: UIView {

	var onString: ((String)->())?
	@objc var onCancel: (()->())?
	fileprivate weak var scannerView: QRScannerView!
	
	func setup() {
		var frame = CGRect(x: 0, y: 0, width: self.frame.size.width*0.5, height: self.frame.size.width*0.5)
		frame.origin = CGPoint(x: self.center.x - frame.size.width*0.5, y: self.center.y - frame.size.height*0.5)
		let v = QRScannerView(frame: frame)
		let background = UIView(frame: self.bounds)
		background.backgroundColor = UIColor.black.withAlphaComponent(0.8)
		v.layer.cornerRadius = frame.size.width * 0.25
		v.clipsToBounds = true
		v.backgroundColor = .white
		background.addSubview(v)
		self.addSubview(background)
		
		let button = UIButton(frame: CGRect(x: v.frame.origin.x, y: v.frame.maxY + 15, width: v.frame.size.width, height: 60))
		button.layer.cornerRadius = button.frame.size.height * 0.3
		button.backgroundColor = .white
		button.setTitleColor(.black, for: .normal)
		button.setTitle("Cancel", for: .normal)
		button.addTarget(self, action: #selector(onCancel(sender:)), for: .touchUpInside)
		background.addSubview(button)
		
		v.onString = self.onString
		self.scannerView = v
	}
	
	@objc func onCancel(sender: Any) {
		self.onCancel?()
	}
	
	func start() {
		self.scannerView.start()
	}

}

