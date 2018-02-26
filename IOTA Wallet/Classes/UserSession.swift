//
//  UserSession.swift
//  IOTA Wallet
//
//  Created by Pasquale Ambrosini on 28/01/18.
//  Copyright © 2018 Pasquale Ambrosini. All rights reserved.
//

import Foundation
import IotaKit

struct UserSettings {
	var checksum: String
	var numberOfAddresses: Int
	
	init(checksum: String, numberOfAddresses: Int) {
		self.checksum = checksum
		self.numberOfAddresses = numberOfAddresses
	}
	
	init?(checksum: String) {
		guard let dictionary = UserDefaults.standard.dictionary(forKey: "user-settings-\(checksum)") else { return nil }
		self.checksum = checksum
		self.numberOfAddresses = dictionary["numberOfAddresses"]! as! Int
	}
	
	func toDictionary() -> [String: Any] {
		return ["numberOfAddresses": self.numberOfAddresses]
	}
	func save() {
		print("Saved \(self.checksum) \(self.toDictionary())")
		UserDefaults.standard.set(self.toDictionary(), forKey: "user-settings-\(self.checksum)")
		UserDefaults.standard.synchronize()
	}
}

protocol UserSessionListener: AnyObject {
	func onAccountUpdate(account: IotaAccount)
}

class UserSession {
	static let current: UserSession = UserSession()
	
	private var listeners: [WeakRefListener] = []
	
	var iota: Iota!
	var seed: String! {
		didSet(oldValue) {
			let checksum = IotaAPIUtils.checksumForSeed(seed)
			if let us = UserSettings(checksum: checksum) {
				self.settings = us
			}else{
				self.settings = UserSettings(checksum: checksum, numberOfAddresses: 0)
			}
		}
	}
	var account: IotaAccount! {
		didSet(oldValue) {
			if self.settings != nil {
				if account.addresses.count <= self.settings!.numberOfAddresses { return }
				self.settings!.numberOfAddresses = account.addresses.count
				self.settings!.save()
				DispatchQueue.main.async {
					self.listeners.onAccountUpdate(account: self.account)
				}
			}
		}
	}
	
	var needsToAttachAddresses: Bool {
		return self.account.addresses.count < self.settings!.numberOfAddresses
	}
	var settings: UserSettings?
	fileprivate init() { }
	
	func updateAccount(afterDelay delay: TimeInterval = 0) {
		DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
			self.iota.accountData(seed: self.seed, requestTransactions: true, { (account) in
				self.account = account
			}, error: { (e) in })
		}
	}
	
	func addListener(_ listener: UserSessionListener) {
		self.listeners.clean()
		for e in self.listeners {
			let a = e.value! as AnyObject
			let b = listener as AnyObject
			if a === b { return }
		}
		self.listeners.append(WeakRefListener(value: listener))
	}
	
	func removeListener(_ listener: UserSessionListener) {
		self.listeners.clean()
		var index: Int?
		for i in 0..<self.listeners.count {
			let a = self.listeners[i].value! as AnyObject
			let b = listener as AnyObject
			if a === b { index = i; break }
		}
		if let i = index {
			self.listeners.remove(at: i)
		}
	}
}

extension Array where Element == WeakRefListener {
	mutating func clean() {
		self = self.filter { $0.value != nil }
	}
	
	mutating func onAccountUpdate(account: IotaAccount) {
		self.clean()
		for e in self {
			e.value!.onAccountUpdate(account: account)
		}
	}
}
