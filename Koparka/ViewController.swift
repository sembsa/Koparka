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
    
    var xTemp: Double = 0
    var firstRunChartTemp = true
    
    class chartsDataBase {
        var _gpu: Int
        var array = [ChartDataEntry]()
        var colorArray = [#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1), #colorLiteral(red: 0.6679978967, green: 0.4751212597, blue: 0.2586010993, alpha: 1), #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)]
        
        init(gpu: Int, value: ChartDataEntry) {
            _gpu = gpu
            array.append(value)
            
        }
        func addToArray(temp: ChartDataEntry)  {
            array.append(temp)
        }
    }
    
    var arrayTempCharts = [chartsDataBase]()
    
    func addTempToChart(gpu: Int, temp: Double, countCard: Int) {
        
        let realCountcard = countCard - 1
        
        if firstRunChartTemp {
            arrayTempCharts.append(chartsDataBase(gpu: gpu, value: ChartDataEntry(x: xTemp, y: temp)))
        } else {
            arrayTempCharts[gpu].addToArray(temp: ChartDataEntry(x: xTemp, y: temp))
        }
        
        if gpu == realCountcard {
            firstRunChartTemp = false
            
            let data = LineChartData()
            
            var lineWidthChart = 0.9
            
            for x in 0...realCountcard {
                lineWidthChart += 0.5
                let dataSet = LineChartDataSet(values: arrayTempCharts[x].array, label: "GPU\(String(x))")
                dataSet.colors = [arrayTempCharts[x].colorArray[x]]
                dataSet.drawCirclesEnabled = false
                dataSet.drawCircleHoleEnabled = false
                dataSet.drawValuesEnabled = false
                dataSet.lineWidth = CGFloat(lineWidthChart)
                data.addDataSet(dataSet)
            }
            
            self.tempChartView.data = data

            self.tempChartView.data?.notifyDataChanged()
            self.tempChartView.notifyDataSetChanged()
            
            xTemp += 1
        }

    }
    
    var xFan: Double = 0
    var firstRunChartFan = true
    
    var arrayFanCharts = [chartsDataBase]()
    
    func addFanToChart(gpu: Int, fan: Double, countCard: Int) {
        
        let realCountcard = countCard - 1
        
        if firstRunChartFan {
            arrayFanCharts.append(chartsDataBase(gpu: gpu, value: ChartDataEntry(x: xFan, y: fan)))
        } else {
            arrayFanCharts[gpu].addToArray(temp: ChartDataEntry(x: xFan, y: fan))
        }
        
        if gpu == realCountcard {
            firstRunChartFan = false
            
            let data = LineChartData()
            
            for x in 0...realCountcard {
                let dataSet = LineChartDataSet(values: arrayFanCharts[x].array, label: "GPU\(String(x))")
                dataSet.colors = [arrayFanCharts[x].colorArray[x]]
                dataSet.drawCirclesEnabled = false
                dataSet.drawCircleHoleEnabled = false
                dataSet.drawValuesEnabled = false
                dataSet.lineWidth = 2.0
                data.addDataSet(dataSet)
            }
            
            self.fanChartView.data = data
            
            self.fanChartView.data?.notifyDataChanged()
            self.fanChartView.notifyDataSetChanged()
            
            xFan += 1
        }
        
    }
    
    var wyniki = [ChartDataEntry]()
    
    var x: Double = 0
    
    func addDataToChart(y: Double) {
        self.lineChartView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        wyniki.append(ChartDataEntry(x: x, y: y))
        x = x + 1
        
        let dataSet = LineChartDataSet(values: wyniki, label: "Speed")
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.colors = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]
        dataSet.lineWidth = 2.0
        dataSet.drawValuesEnabled = false
        
        let leftAxis = self.lineChartView.leftAxis
        leftAxis.labelTextColor = #colorLiteral(red: 1, green: 0.1474981606, blue: 0, alpha: 1)
        leftAxis.drawGridLinesEnabled = true
//        leftAxis.granularityEnabled = true
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
        
        let data = LineChartData()
        data.addDataSet(dataSet)
        self.lineChartView.data = data
        
        self.lineChartView.data?.notifyDataChanged()
        self.lineChartView.notifyDataSetChanged()
    }
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
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
    var runTimerBool = true
    
    @IBAction func readData(_ sender: Any) {
        //TouchBar.changeValue()
        readStart()
    }
    
    @objc func readStart() {
        if walletTextField.stringValue == "" {
            alertOK(text: "Wprowadź adres wallet")
        } else {
            if runTimerBool {
                runTimer()
                runNanopool()
                readTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
                readNanopool = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(runNanopool), userInfo: nil, repeats: true)
                runTimerBool = false
                odczytButton.title = "Stop"
                if setupTempChart() {
                    print("Setup Temp Chart....")
                }
                if setupFanChart() {
                    print("Setip Fan Chart...")
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
    
    @objc func runNanopool() {
        print("Read nanopool...")
        let walletAddress = walletTextField.stringValue
        connectGeneralInfo(pool: .Nanopool, walletAddress: walletAddress)
        connectPaymentLimit(pool: .Nanopool, walletAddress: walletAddress)
    }
    
    @objc func runTimer() {
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let info = "[\(dateFormatter.string(from: date))] Read from server..."
        let url = URL(string: "http://sembsa.synology.me:8098/pawel.json")
        print(info)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (dane, response, error) in
            if (dane != nil) {
                self.setValueLabel(data: dane!)
            } else {
                DispatchQueue.main.async {
                    self.connectionInfoLabel.stringValue = "Problem z połączeniem"
                }
            }
        }
        
        task.resume()
    }
    
    func setValueLabel(data: Data) {
        let temp = readJSON(data: data)
        DispatchQueue.main.async {
            self.versionLabel.stringValue = temp.version
            self.speedLabel.stringValue = String(Double(temp.currentSpeedAndShares[0])! / 1000) + " Mh/s"
            NotificationCenter.default.post(name: NSNotification.Name.init("TBSpeed"), object: nil, userInfo: ["Speed": String(Double(temp.currentSpeedAndShares[0])! / 1000)])
            self.sharesLabel.stringValue = temp.currentSpeedAndShares[1] as String
            var gpus = ""
            for x in 0...temp.singleCardSpeed.count-1 {
                let gpuInfo = self.gpuStat(gpu: x, data: temp)
                self.addTempToChart(gpu: x, temp: Double(gpuInfo.temp), countCard: temp.singleCardSpeed.count)
                self.addFanToChart(gpu: x, fan: Double(gpuInfo.fan), countCard: temp.singleCardSpeed.count)
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
            self.addDataToChart(y: Double(temp.currentSpeedAndShares[0])! / 1000)
            
            self.connectionInfoLabel.stringValue = "Działa"
            
            self.poolLabel.stringValue = temp.currentPoolConnect
        }
    }

    
    func createArrayData(dane: String) -> [String] {
        let temp = dane.components(separatedBy: ";")
        return temp
    }
    
    
    func stringToInt(string: String) -> Int {
        return Int(string)!
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
    
    
    //////////////////////////////////////////////////////////////////
    
    enum Pool {
        case Nanopool
    }
  
    //Metody łączenia z Pool
    //General Info
    func connectGeneralInfo(pool: Pool, walletAddress: String) {
        
        var urlString = ""
        
        switch pool {
        case .Nanopool:
            urlString = Nanopool(mode: .GeneralInfoAddress, addressWallet: walletAddress).address
            break
        }
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: request) { (dane, response, error) in
            if (dane != nil) {
                self.setupNanopoolHashrate(result: NanopoolGeneralInfo(data: dane!))
                
            } else {
                DispatchQueue.main.async {
                    
                }
            }
        }
        task.resume()
    }
    
    func connectPaymentLimit(pool: Pool, walletAddress: String) {
        
        var urlString = ""
        
        switch pool {
        case .Nanopool:
            urlString = Nanopool(mode: .PayoutAddress, addressWallet: walletAddress).address
            break
        }
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (dane, response, error) in
            if (dane != nil) {
                self.setupPayoutLimit(result: NanopoolPayoutLimit(data: dane!))
                
            } else {
                DispatchQueue.main.async {
                    
                }
            }
        }
        task.resume()
    }
    
    func connectCalculator(pool: Pool, hashrate: String) {
        
        var urlString = ""
        
        switch pool {
        case .Nanopool:
            urlString = Nanopool(hashrateAddress: hashrate).address
            break
        }
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (dane, response, error) in
            if (dane != nil) {
                self.setupCalculator(result: NanopoolCalculator(data: dane!))
                
            } else {
                DispatchQueue.main.async {
                    
                }
            }
        }
        task.resume()
    }
    
    
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
            self.connectCalculator(pool: ViewController.Pool.Nanopool, hashrate: temp.data.avgHashrate.h24)
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



