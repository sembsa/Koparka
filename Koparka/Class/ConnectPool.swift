//
//  ConnectPool.swift
//  Koparka
//
//  Created by Sebastian Trześniewski on 14.04.2018.
//  Copyright © 2018 Sebastian Trześniewski. All rights reserved.
//

import Foundation

class connectToPool: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration,
                          delegate: self, delegateQueue: nil)
    }()
    
    var responseData: Data?
    
    init(pool: PoolList) {
        print(pool)
    }
    
    func startRead(adress: String) {
        let url = URL(string: adress)
        let task = session.dataTask(with: url!)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData = data
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print(error.debugDescription)
        }
    }
    
    func getData() -> Data {
        while responseData == nil {
            if responseData != nil {
                return responseData!
            }
        }
        return responseData!
    }
    
}
