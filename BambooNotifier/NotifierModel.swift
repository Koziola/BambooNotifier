//
//  NotifierModel.swift
//  BambooNotifier
//
//  Contains information about the current Bamboo instance the app is connected to.
//
//  Created by Adam Koziol on 1/22/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class NotifierModel{
    let bambooInstanceRootURL : URL
    
    init(bambooRootURL : URL){
        self.bambooInstanceRootURL = bambooRootURL
    }
}
