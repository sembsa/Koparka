//
//  Pool.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 14.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation

enum PoolList {
    case Nanopool
    case MinerStat
}

enum PoolMode {
    case GeneralInfoAddress
    case PayoutAddress
}

class PoolAdress {
    var pooll: PoolList
    
    init(pool: PoolList) {
        pooll = pool
    }
    
    func setupAddress(mode: PoolMode, walletAddress: String) -> String {
        switch pooll {
        case .Nanopool:
            switch mode {
            case .GeneralInfoAddress:
                return Nanopool.init(mode: Nanopool.addressNanopool.GeneralInfoAddress, addressWallet: walletAddress).address
            case .PayoutAddress:
                return Nanopool.init(mode: Nanopool.addressNanopool.PayoutAddress, addressWallet: walletAddress).address
            }
        case .MinerStat:
            return "http://sembsa.synology.me:8098/pawel.json"
        }
    }
}
