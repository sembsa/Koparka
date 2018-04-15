//
//  MinerStat.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 06.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation

class MinerStatistic {
    
    init() {
        
    }
    
    struct Miner: Codable {
        let result: [String]
    }

    struct minerStat {
        var version: String
        var runTime: String
        var currentSpeedAndShares: [String]
        var singleCardSpeed: [String]
        var currentTempAndFanSpeed: [String]
        var currentPoolConnect: String
        var sharesCard: [String]
    }

    struct oneGPU {
        var speed = 0.0
        var shares = 0
        var temp = 0
        var fan = 0
        
        init(oneGPU speed: Double, shares: Int, temp: Int, fan: Int) {
            self.speed = (speed / 1000)
            self.shares = shares
            self.temp = temp
            self.fan = fan
        }
        
    }

    func createArrayData(dane: String) -> [String] {
        let temp = dane.components(separatedBy: ";")
        return temp
    }

    func readJSON(data: Data) -> minerStat {
        let decoder = JSONDecoder()
        //        let product = try! decoder.decode(Miner.self, from: data)
        
        do {
            let product = try decoder.decode(Miner.self, from: data)
            return minerStat(version: product.result[0], runTime: product.result[1], currentSpeedAndShares: createArrayData(dane: product.result[2]), singleCardSpeed: createArrayData(dane: product.result[3]), currentTempAndFanSpeed: createArrayData(dane: product.result[6]), currentPoolConnect: product.result[7], sharesCard: createArrayData(dane: product.result[9]))
        } catch {
            print(error.localizedDescription)
            return minerStat(version: "0", runTime: "0", currentSpeedAndShares: ["0"], singleCardSpeed: ["0"], currentTempAndFanSpeed: ["0"], currentPoolConnect: "0", sharesCard: ["0"])
        }
        
        
        
    }

    func gpuStat(gpu: Int, data: minerStat) -> oneGPU {
        var temp = 0
        
        if gpu != 0 {
            for _ in 1...gpu {
                temp += 2
            }
        }
        
        return oneGPU(oneGPU: Double(data.singleCardSpeed[gpu])!, shares: stringToInt(string: data.sharesCard[gpu]), temp: stringToInt(string: data.currentTempAndFanSpeed[temp]), fan: stringToInt(string: data.currentTempAndFanSpeed[temp+1]))
    }
    
    func stringToInt(string: String) -> Int {
        return Int(string)!
    }
}
