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

class NotifierModel : NSObject {
    var bambooInstanceRootURL : URL? {
        willSet(value){
            print("Setting bamboo instance url: \(value)")
        }
        didSet{
            projectList.removeAll()
            selectedProject = nil
        }
    }
    
    var projectList : [BambooProject]
    @objc dynamic var subscriptions : [ISubscribable]
    
    /*
    * Use a proxy for additions/removals because 'resizing' an array causes
    * initialization of a new, larger array and a copy of all the existing values
    * into the new array.  This means that the wrong kind of KVO notifications are
    * sent (new collection vs simple addition or removal).
    */
    func addSubscription(subscribable : ISubscribable){
        let proxy = mutableArrayValue(forKeyPath: #keyPath(subscriptions))
        proxy.add(subscribable)
    }
    
    func removeSubscription(subscribable : ISubscribable){
        let proxy = mutableArrayValue(forKeyPath: #keyPath(subscriptions))
        proxy.remove(subscribable)
    }
    
    var selectedProject : BambooProject? {
        didSet{
            selectedPlan = nil
        }
    }
    @objc dynamic var selectedPlan : BambooPlan? {
        didSet {
            selectedPlanBranch = nil
        }
    }
    
    @objc dynamic var selectedPlanBranch : BambooPlanBranch?
    
    var currentlySelectedSubscribable : ISubscribable?{
        get{
            return selectedPlanBranch ?? selectedPlan
        }
    }
    
    override init() {
        bambooInstanceRootURL = nil
        projectList = []
        selectedProject = nil
        subscriptions = []
    }
}
