//
//  Nanopool.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 15.03.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation

class Nanopool {
    private var generalInfoAddress = "https://api.nanopool.org/v1/eth/user/"
    private var calculatorAddress = "https://api.nanopool.org/v1/eth/approximated_earnings/"
    private var payoutLimitAddress = "https://api.nanopool.org/v1/eth/usersettings/"
    
    var address = ""
    
    enum addressNanopool {
        case GeneralInfoAddress
        case CalculatorAddress
        case PayoutAddress
    }
    
    init() {
        
    }
    
    init(mode: addressNanopool, addressWallet: String) {
        address = getAddress(mode: mode, addressWallet: addressWallet)
    }
    
    init(hashrateAddress hashrate: String) {
        address = getAddressCalculator(hashrate: hashrate)
    }
    
    private func getAddress(mode: addressNanopool, addressWallet: String) -> String {
        switch mode {
        case .GeneralInfoAddress:
            return generalInfoAddress + addressWallet
        case .PayoutAddress:
            return payoutLimitAddress + addressWallet
        default:
            print("Problem z adresem")
            return "OK"
        }
    }
    
    private func getAddressCalculator(hashrate: String) -> String {
        return calculatorAddress + hashrate
    }
}

class NanopoolGeneralInfo {
    struct avgHash: Codable {
        let h1: String
        let h3: String
        let h6: String
        let h12: String
        let h24: String
    }
    
    struct workersDict: Codable {
        let id: String
        let uid: Int
        let hashrate: String
        let lastshare: Int
        let rating: Int
        let h1: String
        let h3: String
        let h6: String
        let h12: String
        let h24: String
    }
    
    struct dataTemp: Codable {
        let account: String
        let unconfirmed_balance: String
        let balance: String
        let hashrate: String
        let avgHashrate: avgHash
        let workers: [workersDict]
    }
    
    struct generalInfo: Codable {
        let status: Bool
        let data: dataTemp
    }
    
    private let jsonDecoder = JSONDecoder()
    
    private func decodeJsonGeneralInfo(data: Data) -> generalInfo {
        do {
            return try jsonDecoder.decode(generalInfo.self, from: data)
        } catch {
            print("Error JSON GeneralInfo")
        }
        return generalInfo(status: false, data: dataTemp.init(account: "0", unconfirmed_balance: "0", balance: "0", hashrate: "0", avgHashrate: avgHash.init(h1: "0", h3: "0", h6: "0", h12: "0", h24: "0"), workers: [workersDict(id: "0", uid: 0, hashrate: "0", lastshare: 0, rating: 0, h1: "0", h3: "0", h6: "0", h12: "0", h24: "0")]))
    }
    
    private var generalInfoData: generalInfo!
    
    init() {
    }
    
    func getGeneralInfo() -> generalInfo {
        return generalInfoData
    }
    
    func setGeneralInfo(data: Data) {
        generalInfoData = decodeJsonGeneralInfo(data: data)
    }

}

class NanopoolPayoutLimit {
    
    struct Payment: Codable {
        let status: Bool
        let data: PaymentPayout
    }
    
    struct PaymentPayout: Codable {
        let payout: Double
    }
    
    private let jsonDecoder = JSONDecoder()
    
    private func decodeJsonGeneralInfo(data: Data) -> Payment {
        do {
            return try jsonDecoder.decode(Payment.self, from: data)
        } catch {
            print("Error JSON Payout")
        }
        return Payment(status: false, data: PaymentPayout(payout: 0.0))
    }
    
    private var payoutLimit: Payment!
    
    init() {
    }
    
    func getPayoutLimit() -> Payment {
        return payoutLimit
    }
    
    func setPayloadLimit(data: Data) {
        payoutLimit = decodeJsonGeneralInfo(data: data)
    }
    
}

class NanopoolCalculator {
    struct Calculator: Codable {
        let status: Bool
        let data: CoinPerTime
    }
    
    struct CoinPerTime: Codable {
        let minute: CoinVarialbe
        let hour: CoinVarialbe
        let day: CoinVarialbe
        let week: CoinVarialbe
        let month: CoinVarialbe
    }
    
    struct CoinVarialbe: Codable {
        let coins: Double
        let dollars: Double
        let yuan: Double
        let euros: Double
        let rubles: Double
        let bitcoins: Double
    }
    
    private let jsonDecoder = JSONDecoder()
    
    private func decodeJsonCalculator(data: Data) -> Calculator {
        do {
            return try jsonDecoder.decode(Calculator.self, from: data)
        } catch {
            print("Error JSON Calculator")
        }
        return Calculator(status: false, data: CoinPerTime(minute: CoinVarialbe.init(coins: 0, dollars: 0, yuan: 0, euros: 0, rubles: 0, bitcoins: 0), hour: CoinVarialbe.init(coins: 0, dollars: 0, yuan: 0, euros: 0, rubles: 0, bitcoins: 0), day: CoinVarialbe.init(coins: 0, dollars: 0, yuan: 0, euros: 0, rubles: 0, bitcoins: 0), week: CoinVarialbe.init(coins: 0, dollars: 0, yuan: 0, euros: 0, rubles: 0, bitcoins: 0), month: CoinVarialbe.init(coins: 0, dollars: 0, yuan: 0, euros: 0, rubles: 0, bitcoins: 0)))
    }
    
    private var calculator: Calculator!
    
    init() {
    }
    
    func getCalculator() -> Calculator {
        return calculator
    }
    
    func setCalculator(data: Data) {
        calculator = decodeJsonCalculator(data: data)
    }
    
}
