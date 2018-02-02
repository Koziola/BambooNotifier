//
//  BambooProject.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

struct BambooPlanBranch: Codable {
    //unique identifier for branch
    let key : String
    //combination of project, plan, and shortname
    let name : String
    let description : String?
    //usually equivalent to the source branch
    let shortName : String
    //Direct link to branch
    let link : String
}
