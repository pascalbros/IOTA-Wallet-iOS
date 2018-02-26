//
//  IotaValuePicker.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 30/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import IotaKit
class UIIotaValuePicker: UIView {
	
	fileprivate let selectedColor: UIColor = UIColor(red: 45.0/255.0, green: 148.0/255.0, blue: 254.0/255.0, alpha: 1.0)
	
	var elementSize: CGSize
	var onElementSelected : ((_ unit: IotaUnits, _ picker: UIIotaValuePicker)->Void)?
	init(elementSize: CGSize) {
		self.elementSize = elementSize
		var rect = CGRect(origin: .zero, size: elementSize)
		rect.size.height *= 6
		super.init(frame: rect)
	}
	
	func setup(currentUnit: IotaUnits) {
		
		let units: [IotaUnits] = [.i, .Ki, .Mi, .Gi, .Ti, .Pi]
		var y: CGFloat = 0
		for u in units {
			let button = self.setupButton(frame: CGRect(origin: CGPoint(x: 0, y: y), size: self.elementSize), unit: u)
			button.backgroundColor = self.backgroundColor
			if u == currentUnit {
				button.backgroundColor = self.selectedColor
			}
			self.addSubview(button)
			y += self.elementSize.height
		}
		self.layer.cornerRadius = 4
		self.clipsToBounds = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupButton(frame: CGRect, unit: IotaUnits) -> UIButton {
		let button = UIButton(type: .system)
		button.frame = frame
		button.setTitle(unit.string, for: .normal)
		button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 19)
		button.setTitleColor(.white, for: .normal)
		button.addTarget(self, action: #selector(UIIotaValuePicker.selectButton(sender:)), for: .touchUpInside)
		return button
	}
	
	@objc func selectButton(sender: UIButton) {
		for v in self.subviews where v.isKind(of: UIButton.self) {
			if v != sender {
				let b = v as! UIButton
				b.backgroundColor = self.backgroundColor
			}
		}
		sender.backgroundColor = self.selectedColor
		let units: [IotaUnits] = [.i, .Ki, .Mi, .Gi, .Ti, .Pi]
		let value = units.filter { sender.title(for: .normal)! == $0.string }.first!
		self.onElementSelected?(value, self)
	}
}

