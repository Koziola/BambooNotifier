//
//  BambooProject.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

struct BambooProject: Codable {
    //unique key for the project
    let key : String
    //name of the project
    let name : String
    //direct link to the project
    let link : BambooLink
    
    //MARK: Optional Fields
    //unique key for the project
    let projectKey : String?
    //human-readable name for the project
    let projectName : String?
    //list of plans for the project
    let plans : [BambooPlan]?
}
