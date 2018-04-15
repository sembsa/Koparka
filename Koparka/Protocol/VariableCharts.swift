//
//  VariableCharts.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 06.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation
import Charts

protocol VariableChartsMulti {
    var xTemp: Double {get set}
    var firstRunChartTemp:Bool {get set}
    var arrayDataBase: [chartsDataBase] {get set}
    var data: LineChartData {set get}
    func setDataBase()
    func getDataBase() -> LineChartData
    func addValuetoChart(yValue: Double)
    func addXTemp()
}

protocol VariableChartsSingle {
    var xTemp: Double {get set}
    var firstRunChartTemp:Bool {get set}
    var arrayDataBase: [ChartDataEntry] {get set}
    var data: LineChartData {set get}
    func setDataBase()
    /**
     Method return LineChartData
     
     - returns: LineChartData
     */
    func getDataBase() -> LineChartData
    /**
     Dodawanie danych do bazy danych.
     
     - returns: Nothing
     - Parameters:
        - yValue: Wartość Y
     */
    func addValuetoChart(yValue: Double)
    func addXTemp()
}

