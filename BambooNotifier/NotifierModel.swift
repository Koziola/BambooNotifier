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
    var subscriptions : [ISubscribable]
    
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
            return selectedPlan ?? selectedPlanBranch
        }
    }
    
    override init() {
        bambooInstanceRootURL = nil
        projectList = []
        selectedProject = nil
        subscriptions = []
    }
}
