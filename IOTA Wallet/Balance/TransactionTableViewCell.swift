//
//  TransactionTableViewCell.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 22/01/2018.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import IotaKit

class TransactionTableViewCell: UITableViewCell {

	fileprivate static let plusColor = UIColor(red: 58.0/255.0, green: 182.0/255.0, blue: 77.0/255.0, alpha: 1.0)
	fileprivate static let minusColor = UIColor(red: 245.0/255.0, green: 94.0/255.0, blue: 78.0/255.0, alpha: 1.0)
	
	@IBOutlet weak var inclusionLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var valueLabel: UILabel!
	@IBOutlet weak var signLabel: UILabel!
	@IBOutlet weak var reattachLabel: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setup(withTx tx: IotaHistoryTransaction) {
		self.valueLabel.text = "\(abs(tx.value))i"
		if tx.value >= 0 {
			self.signLabel.text = "+"
			self.signLabel.textColor = TransactionTableViewCell.plusColor
		}else {
			self.signLabel.text = "-"
			self.signLabel.textColor = TransactionTableViewCell.minusColor
		}
		if tx.persistence {
			self.inclusionLabel.text = "confirmed"
			self.contentView.alpha = 1.0
			self.inclusionLabel.font = UIFont(name: "HelveticaNeue-BoldItalic", size: self.inclusionLabel.font.pointSize)
		}else{
			self.inclusionLabel.text = "pending"
			self.contentView.alpha = 0.4
			self.inclusionLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: self.inclusionLabel.font.pointSize)
		}
		
		if tx.transactions.count <= 1 {
			self.reattachLabel.text = ""
		}else{
			self.reattachLabel.text = "+\(tx.transactions.count - 1) reattach"
		}
		
		let date = Date(timeIntervalSince1970: TimeInterval(tx.timestamp))
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
		self.timeLabel.text = dateFormatter.string(from: date)
	}

}
