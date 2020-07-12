//
//  MainViewController.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 12/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import UIKit
import IotaKit
import Font_Awesome_Swift
import MBProgressHUD

class BalanceViewController: UIViewController {
	
	@IBOutlet weak var logoutButton: UIButton!
	@IBOutlet weak var balanceLabel: BalanceLabel!
	@IBOutlet weak var underlineBalanceBorder: UIView!
	@IBOutlet weak var historyTableView: UITableView!
	@IBOutlet weak var topBarView: UIView!
	var transactions: [IotaHistoryTransaction] = []
	var rawTransactions: [IotaHistoryTransaction] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.historyTableView.dataSource = self
		self.historyTableView.delegate = self
		self.setupUI()
		self.setupHistory()
		self.checkAddressesMismatch()
		UserSession.current.addListener(self)
		
		for a in UserSession.current.account.addresses {
			print("\(a.hash) \(a.canSpend!)")
		}
    }
	
	fileprivate func setupUI() {
		self.historyTableView.tableFooterView = UIView(frame: .zero)
		self.balanceLabel.textColor = Colors.foregroundColor
		self.underlineBalanceBorder.backgroundColor = Colors.foregroundColor

		self.logoutButton.setFAIcon(icon: .FASignOut, forState: .normal)
	}
	
	fileprivate func checkAddressesMismatch() {
		if UserSession.current.needsToAttachAddresses {
			let numberOfAddresses = UserSession.current.settings!.numberOfAddresses - UserSession.current.account.addresses.count
			let alertController = UIAlertController(title: "Wrong balance?", message: "Your balance seems incorrect, this happens for multiple reasons, we can fix that!\n Do you want to start the sync process? It can take a while. Estimated time \(numberOfAddresses*12) seconds", preferredStyle: .alert)
			
			let action1 = UIAlertAction(title: "Yes", style: .default) { (action:UIAlertAction) in
				let hud = MBProgressHUD.showAdded(to: self.tabBarController!.view, animated: true)
				hud.mode = MBProgressHUDMode.determinate
				hud.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
				self.reattachAfterSnapshotProcess({
					DispatchQueue.main.async {
						hud.hide(animated: true)
						self.showReattachAfterSnapshotProcessResult()
					}
				}, error: { (error) in
					DispatchQueue.main.async {
						hud.hide(animated: true)
						self.showReattachAfterSnapshotProcessError(error: error)
					}
				}, log: { (log) in
					DispatchQueue.main.async {
						hud.progress = log.percentage!
						hud.label.text = log.message
					}
				})
			}
			
			let action2 = UIAlertAction(title: "Later (next login)", style: .default) { (action:UIAlertAction) in }
			
			alertController.addAction(action1)
			alertController.addAction(action2)
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func dismiss(_ sender: Any) {
		self.navigationController?.popViewController(animated: true)
	}
	
	func setupHistory() {
		self.setupBalance()
		
		var txs = UserSession.current.account.addresses.flatMap { $0.transactions ?? [] }
		txs = txs.filter { $0.value != 0 }
		txs.sort { $0.timestamp > $1.timestamp }
		
		self.transactions = IotaAPIUtils.historyTransactions(addresses: UserSession.current.account.addresses).reversed()
		self.rawTransactions = self.transactions.map { $0 }
		self.historyTableView.reloadData()
	}
	
	func setupBalance() {
		self.balanceLabel.iotaBalance = UInt64(UserSession.current.account.balance)
	}
	
	@IBAction func onFilterChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			self.transactions = self.rawTransactions.map { $0 }
		}else if sender.selectedSegmentIndex == 1 {
			self.transactions = self.transactions.filter { $0.value != 0 }
		}
		self.historyTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
	}
}

extension BalanceViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 81
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.transactions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
		cell.setup(withTx: self.transactions[indexPath.row])
		return cell
	}
}

//Reattach after snapshot
extension BalanceViewController {
	
	func showReattachAfterSnapshotProcessError(error: Error) {
		let alertController = UIAlertController(title: "An error as occurred", message: "Seems like there was an error in the process.\nNo worries, your funds are safe as always, just login again and we will sort it out for you.", preferredStyle: .alert)
		
		let action1 = UIAlertAction(title: "Let me login", style: .default) { (action:UIAlertAction) in
			self.navigationController?.popViewController(animated: true)
		}
		
		alertController.addAction(action1)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func showReattachAfterSnapshotProcessResult() {
		let alertController = UIAlertController(title: "Done", message: "Everything seems to be fine, please login again.", preferredStyle: .alert)
		
		let action1 = UIAlertAction(title: "Let me login", style: .default) { (action:UIAlertAction) in
			self.navigationController?.popViewController(animated: true)
		}
		
		alertController.addAction(action1)
		self.present(alertController, animated: true, completion: nil)
	}
	
	func _reattachAfterSnapshotProcess(_ success: @escaping () -> Void, error: @escaping (Error) -> Void, log: ((_ log: WalletLog) -> Void)? = nil) {
		DispatchQueue.global(qos: .userInitiated).async {
			log?(WalletLog(message: "Generating address 1", percentage: 0.25))
		}
		
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2.0, execute: {
			log?(WalletLog(message: "Generating address 2", percentage: 0.5))
		})
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 4.0, execute: {
			log?(WalletLog(message: "Generating address 3", percentage: 0.75))
		})
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 6.0, execute: {
			success()
		})
	}
	
	func reattachAfterSnapshotProcess(_ success: @escaping () -> Void, error: @escaping (Error) -> Void, log: ((_ log: WalletLog) -> Void)? = nil) {
		let initialIndex = UserSession.current.account.addresses.count
		let endIndex = UserSession.current.settings!.numberOfAddresses
		
		func reattach(index: Int) {
			if index == endIndex {
				success()
				return
			}
			log?(WalletLog(message: "Updating address at index \(index)", percentage: Float(index-initialIndex)/Float(endIndex-initialIndex)))
			UserSession.current.iota.attachToTangle(seed: UserSession.current.seed, index: index, security: 2, { (_) in
				reattach(index: index+1)
			}, error: error)
		}
		let index = UserSession.current.account.addresses.count
		reattach(index: index)
	}
}

extension BalanceViewController: UserSessionListener {
	func onAccountUpdate(account: IotaAccount) {
		self.setupHistory()
	}
}
