//
//  ModelPersistence.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 4/19/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class ModelPersistence{
    private static let BAMBOO_URL = "BambooURL"
    private static let BAMBOO_PLAN_SUBSCRIPTIONS = "BambooSubscrriptions"
    
    static func loadModel(model: NotifierModel){
        debugPrint("Loading data...")
        if let url = UserDefaults.standard.url(forKey: BAMBOO_URL){
            model.bambooInstanceRootURL = url
        }
        if let subscriptions = UserDefaults.standard.object(forKey: BAMBOO_PLAN_SUBSCRIPTIONS) as? [ISubscribable]{
            model.subscriptions = subscriptions
        }
    }
    
    static func saveModel(model: NotifierModel){
        debugPrint("Saving data...")
        UserDefaults.standard.set(model.bambooInstanceRootURL, forKey: BAMBOO_URL)
        UserDefaults.standard.set(model.subscriptions, forKey: BAMBOO_PLAN_SUBSCRIPTIONS)
    }
}
