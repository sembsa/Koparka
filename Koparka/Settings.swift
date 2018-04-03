//
//  Settings.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 06.03.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Cocoa

class Settings: NSViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let wallet = UserDefaults.standard.object(forKey: "wallet") {
            walletTF.stringValue = wallet as! String
        } else {
            walletTF.stringValue = ""
        }
        
        if let id = UserDefaults.standard.object(forKey: "id") {
            idTF.stringValue = id as! String
        } else {
            idTF.stringValue = ""
        }
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    @IBOutlet weak var walletTF: NSTextField!
    @IBOutlet weak var idTF: NSTextField!
    
    @IBAction func saveAction(_ sender: Any) {
        if walletTF.stringValue != "" {
            UserDefaults.standard.set(walletTF.stringValue, forKey: "wallet")
        } else {
            showAlert(text: "Musisz podać adres wallet")
        }
        if idTF.stringValue != "" {
            UserDefaults.standard.set(idTF.stringValue, forKey: "id")
        } else {
            showAlert(text: "Musisz podać ID")
        }
        if walletTF.stringValue != "" && idTF.stringValue != "" {
            NotificationCenter.default.post(name: NSNotification.Name.init("refresh"), object: nil)
            self.view.window?.close()
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.view.window?.close()
    }
    
    func showAlert(text: String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Ok")
        DispatchQueue.main.async {
            alert.runModal()
        }
    }
    
}
