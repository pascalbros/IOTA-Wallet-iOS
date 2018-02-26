//
//  Utils.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 28/01/2018.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import Foundation
import CoreImage
import UIKit

private extension String {
	
	func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
		let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
		return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
	}
}

extension String {
	var QRCodeImage: UIImage? {
		let data = self.data(using: String.Encoding.ascii)
		if let filter = CIFilter(name: "CIQRCodeGenerator") {
			filter.setValue(data, forKey: "inputMessage")
			let transform = CGAffineTransform(scaleX: 3, y: 3)
			
			if let output = filter.outputImage?.transformed(by: transform) {
				return UIImage(ciImage: output)
			}
		}
		return nil
	}
}

public struct WalletLog {
	public internal(set) var message: String = ""
	public internal(set) var percentage: Float?
}

class WeakRefListener {
	private(set) weak var value: UserSessionListener?
	init(value: UserSessionListener?) {
		self.value = value
	}
}

extension UITextField{
	
	@IBInspectable var doneAccessory: Bool{
		get{
			return self.doneAccessory
		}
		set (hasDone) {
			if hasDone{
				addDoneButtonOnKeyboard()
			}
		}
	}
	
	func addDoneButtonOnKeyboard()
	{
		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
		doneToolbar.barStyle = .default
		
		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
		
		let items = [flexSpace, done]
		doneToolbar.items = items
		doneToolbar.sizeToFit()
		
		self.inputAccessoryView = doneToolbar
	}
	
	@objc func doneButtonAction()
	{
		self.endEditing(true)
	}
}
