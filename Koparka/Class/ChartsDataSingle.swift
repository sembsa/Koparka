//
//  ChartsDataSingle.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 06.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation
import Charts

class ChartsDataSingle: VariableChartsSingle {
    
    init(name: String) {
        print("[Chart] \(name) run...")
        firstRunChartTemp = true
    }
    
    convenience init () {
        self.init(name: "Bez nazwy")
    }

    func addXTemp() {
        xTemp += 1
    }
    
    var arrayDataBase: [ChartDataEntry] = [ChartDataEntry]()

    var xTemp: Double = 0.0
    
    var firstRunChartTemp: Bool = false
    
    var data: LineChartData = LineChartData()
    
    func setDataBase() {
        data.clearValues()
        
        let dataSet = LineChartDataSet(values: arrayDataBase, label: "Speed")
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.colors = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        dataSet.lineWidth = 2.0
        dataSet.drawValuesEnabled = false
        data.addDataSet(dataSet)
        
    }
    
    func getDataBase() -> LineChartData {
        return data
    }
    
    func addValuetoChart(yValue: Double) {
        arrayDataBase.append(ChartDataEntry(x: xTemp, y: yValue))
        setDataBase()
        addXTemp()
    }
    
}
