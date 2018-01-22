//
//  RefreshTimer.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class RefreshTimer {
    private var timer = Timer()
    static let REFRESH_TIMER_NOTIFICATION = "RefreshTimer"
    
    init(){
        refreshInterval = 5
        restartTimer()
    }
    
    var refreshInterval : Double {
        didSet{
            restartTimer()
        }
    }
    
    func restartTimer(){
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: refreshInterval, target: self, selector: #selector(doTimerFired(_:)), userInfo: nil, repeats: true)
    }
    
    @objc private func doTimerFired(_ sender : Any?){
        print("Timer fired.")
        NotificationCenter.default.post(name: Notification.Name(RefreshTimer.REFRESH_TIMER_NOTIFICATION), object: self)
    }
}
