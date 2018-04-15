//
//  TouchBar.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 30.03.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Cocoa

protocol onOff {
    static var on: Bool {get set}
    static func changeValue()
}

class TouchBar: NSWindowController, onOff {
    static var on: Bool = false
    
    static func changeValue() {
        on = !on
    }
    
    @IBOutlet weak var readButton: NSButton!
    @IBOutlet weak var speedLabel: NSTextField!
    
    //var speed: String = ""
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(readStartTB), name: NSNotification.Name.init("TBRead"), object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.init("TBSpeed"), object: nil, queue: OperationQueue.current) { (dane) in
            self.setSpeedTB(speed: dane.userInfo!["Speed"] as! String)
        }
    }

    
    @IBAction func readButtonAction(_ sender: Any) {
        //readStartTB()
        //TouchBar.changeValue()
    }
    
    var runCheck:Bool = false
    
    @objc func readStartTB() {
        DispatchQueue.main.async {
            if !self.runCheck {
                self.readButton.title = "Stop"
                NotificationCenter.default.post(name: NSNotification.Name.init("Read"), object: nil)
                self.runCheck = !self.runCheck
            } else {
                self.readButton.title = "Odczyt"
                NotificationCenter.default.post(name: NSNotification.Name.init("Read"), object: nil)
                self.runCheck = !self.runCheck
            }
        }
        
    }
    
    func setSpeedTB(speed: String) {
        speedLabel.stringValue = "Speed: " + speed + " Mh/s"
    }
    
}
