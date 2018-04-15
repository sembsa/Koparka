//
//  ChartsData.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 03.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation
import Charts

class ChartsDataMulti {
    private var xTemp: Double = 0
    private var firstRunChartTemp:Bool = false
    private var arrayDataBase = [chartsDataBase]()
    private var data = LineChartData()
    
    init(name: String) {
        print("[Chart] \(name) run...")
        firstRunChartTemp = true
    }
    
    convenience init () {
        self.init(name: "Bez nazwy")
    }
    /**
     Dodawanie danych do bazy danych.
     
     - returns: Nothing
     - Parameters:
        - gpu: Numer karty
        - yValue: Wartość Y
        - countCard: Ilość kart
     */
    
    func addValuetoChart(gpu: Int, yValue: Double, countCard: Int) {
        
        let realCountcard = countCard - 1
        
        if firstRunChartTemp {
            arrayDataBase.append(chartsDataBase(gpu: gpu, value: ChartDataEntry(x: xTemp, y: yValue)))
        } else {
            arrayDataBase[gpu].addToArray(temp: ChartDataEntry(x: xTemp, y: yValue))
        }
        
        if gpu == realCountcard {
            firstRunChartTemp = false
            setDataBase(realCountcard: realCountcard)
            
            xTemp += 1
        }
        
    }
    
    /**
     Method return LineChartData
     
     - returns: LineChartData
     */
    
    func getDataBase() -> LineChartData {
        return data
    }
    
    private func setDataBase(realCountcard: Int) {
        data.clearValues()
        for x in 0...realCountcard {
            let dataSet = LineChartDataSet(values: arrayDataBase[x].array, label: "GPU\(String(x))")
            dataSet.colors = [arrayDataBase[x].colorArray[x]]
            dataSet.drawCirclesEnabled = false
            dataSet.drawCircleHoleEnabled = false
            dataSet.drawValuesEnabled = false
            dataSet.lineWidth = 2.0
            data.addDataSet(dataSet)
        }
    }
    
}
