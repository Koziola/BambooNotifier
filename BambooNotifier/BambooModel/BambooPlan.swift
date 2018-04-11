//
//  BambooPlan.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

struct BambooPlan: Decodable {
    //key of the project the plan belongs to
    let projectKey : String
    //name of the project the plan belongs to
    let projectName : String
    //Name of the plan
    let buildName : String
    //unique identifier for the plan
    let key : String
//
////    //list of plan branches
////    let branches : [BambooPlanBranch]?
//
//    //direct link to the plan
//    let link : [BambooLink]
}
