//
//  ViewController.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 12.02.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Cocoa
import Charts

class ViewController: NSViewController {

    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var tempChartView: LineChartView!
    @IBOutlet weak var fanChartView: LineChartView!
    
    //Miner
    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var speedLabel: NSTextField!
    @IBOutlet weak var sharesLabel: NSTextField!
    @IBOutlet weak var gpuInfoLabel: NSTextField!
    @IBOutlet weak var connectionInfoLabel: NSTextField!
    @IBOutlet weak var timeLabel: NSTextField!
    @IBOutlet weak var lastUpdateLabel: NSTextField!
    @IBOutlet weak var poolLabel: NSTextField!
    @IBOutlet weak var odczytButton: NSButton!
    
    //Pool
    @IBOutlet weak var currentHashrate: NSTextField!
    @IBOutlet weak var sixHashrate: NSTextField!
    @IBOutlet weak var twelveHashrate: NSTextField!
    @IBOutlet weak var balancePayoutStatus: NSProgressIndicator!
    @IBOutlet weak var balanceLabel: NSTextField!
    @IBOutlet weak var dayEth: NSTextField!
    @IBOutlet weak var weekEth: NSTextField!
    @IBOutlet weak var mounthEth: NSTextField!
    @IBOutlet weak var dayUsd: NSTextField!
    @IBOutlet weak var weekUsd: NSTextField!
    @IBOutlet weak var mounthUsd: NSTextField!
    
    
    @IBOutlet weak var walletTextField: NSTextField!
    
    var readTimer: Timer!
    var readNanopool: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let wallet = UserDefaults.standard.object(forKey: "wallet") {
            self.walletTextField.stringValue = wallet as! String
        } else {
            self.walletTextField.stringValue = ""
        }
        NotificationCenter.default.addObserver(self, selector: #selector(updateWalletAddress), name: NSNotification.Name.init("refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readStart), name: NSNotification.Name.init("Read"), object: nil)
        
        self.lineChartView.chartDescription?.text = ""
        self.tempChartView.chartDescription?.text = ""
        self.fanChartView.chartDescription?.text = ""
    }
    
    func setupFanChart() -> Bool {
        self.fanChartView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let leftAxis = self.fanChartView.leftAxis
        leftAxis.labelTextColor = #colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)
        leftAxis.drawGridLinesEnabled = true
//      leftAxis.granularityEnabled = true
        leftAxis.drawLabelsEnabled = true
        
        let rightAxis = self.fanChartView.rightAxis
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        let bottomAxis = self.fanChartView.xAxis
        bottomAxis.labelPosition = .bottom
        bottomAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bottomAxis.drawGridLinesEnabled = false
        bottomAxis.drawLabelsEnabled = false
        
        let legend = self.fanChartView.legend
        legend.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        return true
    }
    
    func setupTempChart() -> Bool {
        self.tempChartView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let leftAxis = self.tempChartView.leftAxis
        leftAxis.labelTextColor = #colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)
        leftAxis.drawGridLinesEnabled = true
//      leftAxis.granularityEnabled = true
        leftAxis.drawLabelsEnabled = true
        
        let rightAxis = self.tempChartView.rightAxis
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        let bottomAxis = self.tempChartView.xAxis
        bottomAxis.labelPosition = .bottom
        bottomAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bottomAxis.drawGridLinesEnabled = false
        bottomAxis.drawLabelsEnabled = false
        
        let legend = self.tempChartView.legend
        legend.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        return true
    }
    
    func setupSpeedChart() -> Bool {
        self.lineChartView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let leftAxis = self.lineChartView.leftAxis
        leftAxis.labelTextColor = #colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)
        leftAxis.drawGridLinesEnabled = true
        //      leftAxis.granularityEnabled = true
        leftAxis.drawLabelsEnabled = true
        
        let rightAxis = self.lineChartView.rightAxis
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        
        let bottomAxis = self.lineChartView.xAxis
        bottomAxis.labelPosition = .bottom
        bottomAxis.labelTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        bottomAxis.drawGridLinesEnabled = false
        bottomAxis.drawLabelsEnabled = false
        
        let legend = self.lineChartView.legend
        legend.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        return true
        
    }
    
    var chartTemperature = ChartsDataMulti()
    var chartFan = ChartsDataMulti()
    var chartSpeed = ChartsDataSingle(name: "Speed")
    
    func reloadChart() {
        //Temperature
        self.tempChartView.data = chartTemperature.getDataBase()
        self.tempChartView.data?.notifyDataChanged()
        //Fan
        self.fanChartView.data = chartFan.getDataBase()
        self.fanChartView.data?.notifyDataChanged()
        //Speed
        self.lineChartView.data = chartSpeed.getDataBase()
        self.lineChartView.data?.notifyDataChanged()
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func readData(_ sender: Any) {
        //TouchBar.changeValue()
        readStart()
    }
    
    var runTimerBool = true
    
    @objc func readStart() {
        if walletTextField.stringValue == "" {
            alertOK(text: "Wprowadź adres wallet")
        } else {
            if runTimerBool {
                runMinerStat()
                runNanopool()
                readTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runMinerStat), userInfo: nil, repeats: true)
                readNanopool = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(runNanopool), userInfo: nil, repeats: true)
                runTimerBool = false
                odczytButton.title = "Stop"
                if setupTempChart() {
                    print("Setup Temp Chart....")
                }
                if setupFanChart() {
                    print("Setup Fan Chart...")
                }
                if setupSpeedChart() {
                    print("Setup Speed Chart...")
                }
                
            } else {
                readTimer.invalidate()
                readNanopool.invalidate()
                runTimerBool = true
                odczytButton.title = "Odczyt"
            }
        }
    }
    
    @objc func updateWalletAddress() {
            if let wallet = UserDefaults.standard.object(forKey: "wallet") {
                DispatchQueue.main.async {
                    self.walletTextField.stringValue = wallet as! String
                }
            } else {
                DispatchQueue.main.async {
                    self.walletTextField.stringValue = ""
                }
            }
    }
    
    let generalInfo = NanopoolGeneralInfo()
    let payoutLimitInfo = NanopoolPayoutLimit()
    let calculatorInfo = NanopoolCalculator()
    
    let generalInfoConnect = connectToPool(pool: PoolList.Nanopool)
    let payoutLimitConnect = connectToPool(pool: PoolList.Nanopool)
    let calculatorConnect = connectToPool(pool: PoolList.Nanopool)
    
    @objc func runNanopool() {
        print("Read nanopool...")
        let walletAddress = walletTextField.stringValue
        DispatchQueue.main.async {
            self.generalInfoConnect.startRead(adress: PoolAdress.init(pool: PoolList.Nanopool).setupAddress(mode: PoolMode.GeneralInfoAddress, walletAddress: walletAddress))
            self.generalInfo.setGeneralInfo(data: self.generalInfoConnect.getData())
            self.setupNanopoolHashrate(result: self.generalInfo)
            
            self.payoutLimitConnect.startRead(adress: PoolAdress.init(pool: PoolList.Nanopool).setupAddress(mode: PoolMode.PayoutAddress, walletAddress: walletAddress))
            self.payoutLimitInfo.setPayloadLimit(data: self.payoutLimitConnect.getData())
            self.setupPayoutLimit(result: self.payoutLimitInfo)
            
            self.calculatorConnect.startRead(adress: Nanopool(hashrateAddress: self.generalInfo.getGeneralInfo().data.avgHashrate.h24).address)
            self.calculatorInfo.setCalculator(data: self.calculatorConnect.getData())
            self.setupCalculator(result: self.calculatorInfo)
        }
        
    }
    
    let minerStatInfo = MinerStatistic()
    
    let minerStatConnect = connectToPool(pool: .MinerStat)
    
    @objc func runMinerStat() {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let info = "[\(dateFormatter.string(from: date))] Read from server..."
        DispatchQueue.main.async {
            self.minerStatConnect.startRead(adress: PoolAdress.init(pool: PoolList.MinerStat).setupAddress(mode: PoolMode.GeneralInfoAddress, walletAddress: ""))
            self.setValueLabel(data: self.minerStatConnect.getData())
        }
        
        print(info)
        
    }
    
    func stringToInt(string: String) -> Int {
        return Int(string)!
    }
    
    let stat = MinerStatistic()
    
    func setValueLabel(data: Data) {
        let temp = stat.readJSON(data: data)
        //let temp = readJSON(data: data)
        DispatchQueue.main.async {
            self.versionLabel.stringValue = temp.version
            self.speedLabel.stringValue = String(Double(temp.currentSpeedAndShares[0])! / 1000) + " Mh/s"
            NotificationCenter.default.post(name: NSNotification.Name.init("TBSpeed"), object: nil, userInfo: ["Speed": String(Double(temp.currentSpeedAndShares[0])! / 1000)])
            self.sharesLabel.stringValue = temp.currentSpeedAndShares[1] as String
            var gpus = ""
            for x in 0...temp.singleCardSpeed.count-1 {
                let gpuInfo = self.stat.gpuStat(gpu: x, data: temp)
                //let gpuInfo = self.gpuStat(gpu: x, data: temp)
                self.chartTemperature.addValuetoChart(gpu: x, yValue: Double(gpuInfo.temp), countCard: temp.singleCardSpeed.count)
                self.chartFan.addValuetoChart(gpu: x, yValue: Double(gpuInfo.fan), countCard: temp.singleCardSpeed.count)
                gpus += "GPU" + String(x) + ": " + String(gpuInfo.speed) + " Mh/s Shares: " + String(gpuInfo.shares) + " Temp: " + String(gpuInfo.temp) + "C Fan: " + String(gpuInfo.fan) + "%\n"
            }
            self.gpuInfoLabel.stringValue = gpus
            let datecomponent = DateComponentsFormatter()
            datecomponent.allowedUnits = [.day, .hour, .minute, .second]
            datecomponent.unitsStyle = .abbreviated
            self.timeLabel.stringValue = datecomponent.string(from: TimeInterval(self.stringToInt(string: temp.runTime)*60))!
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:ss"
            self.lastUpdateLabel.stringValue = dateFormatter.string(from: date)
            self.chartSpeed.addValuetoChart(yValue: Double(temp.currentSpeedAndShares[0])! / 1000)
            //self.addDataToChart(y: Double(temp.currentSpeedAndShares[0])! / 1000)
            
            self.connectionInfoLabel.stringValue = "Działa"
            
            self.poolLabel.stringValue = temp.currentPoolConnect
            
            //Reload Charts
            self.reloadChart()
            
        }
    }

    
    
    //////////////////////////////////////////////////////////////////
    //Metody ustawiania widoku
    func setupNanopoolHashrate(result: NanopoolGeneralInfo) {
        
        let temp = result.getGeneralInfo()
        
        if !temp.status {
            print("Setup Nanopool GeneralInfo Done with error")
        } else {
            print("Setup Nanopool GeneralInfo Done...")
        }
        
        DispatchQueue.main.async {
            self.currentHashrate.stringValue = temp.data.hashrate + " Mh/s"
            self.sixHashrate.stringValue = temp.data.avgHashrate.h6 + " Mh/s"
            self.twelveHashrate.stringValue = temp.data.avgHashrate.h12 + " Mh/s"
            self.balanceLabel.stringValue = temp.data.balance
            self.balancePayoutStatus.doubleValue = Double(temp.data.balance)!
        }

    }
    
    func setupPayoutLimit(result: NanopoolPayoutLimit) {
        
        let temp = result.getPayoutLimit()
        
        if !temp.status {
            print("Setup Nanopool PayoutLimit Done with error")
        } else {
            print("Setup Nanopool PayoutLimit Done...")
        }
        
        DispatchQueue.main.async {
            self.balancePayoutStatus.minValue = 0.0
            self.balancePayoutStatus.maxValue = temp.data.payout
        }
        
    }
    
    func setupCalculator(result: NanopoolCalculator) {
        
        let temp = result.getCalculator()
        
        if !temp.status {
            print("Setup Nanopool Calculator Done with error")
        } else {
            print("Setup Nanopool Calculator Done...")
        }
        
        DispatchQueue.main.async {
            self.dayEth.stringValue = self.coinToStringAndSymbol(number: temp.data.day.coins, currency: "ETH")
            self.weekEth.stringValue = self.coinToStringAndSymbol(number: temp.data.week.coins, currency: "ETH")
            self.mounthEth.stringValue = self.coinToStringAndSymbol(number: temp.data.month.coins, currency: "ETH")
            self.dayUsd.stringValue = self.coinToStringAndSymbol(number: temp.data.day.dollars, currency: "$")
            self.weekUsd.stringValue = self.coinToStringAndSymbol(number: temp.data.week.dollars, currency: "$")
            self.mounthUsd.stringValue = self.coinToStringAndSymbol(number: temp.data.month.dollars, currency: "$")
        }
        
    }
    
    func coinToStringAndSymbol(number: Double, currency: String) -> String {
        switch currency {
        case "ETH":
            return String(format:"%.2f", number) + currency
        case "$":
            return String(format:"%.2f", number) + currency
        default:
            return "0"
        }
    }
    
    func alertOK(text: String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Ok")
        DispatchQueue.main.async {
            alert.runModal()
        }
    }
}
