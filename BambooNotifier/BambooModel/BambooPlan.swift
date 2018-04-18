//
//  BambooPlan.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

fileprivate struct BambooPlanContainer: Decodable {
    let projectKey : String
    let projectName : String
    let buildName : String
    let key : String

    let branches : BambooPlanBranchList?
    
    struct BambooPlanBranchList: Decodable{
        let size: Int
        let branchList: [BambooPlanBranch]?
        
        enum CodingKeys: String, CodingKey{
            case branchList = "branch"
            case size
        }
    }
}

// This is a class rather than a struct so we can inherit from NSObject
// and be KVO compliant.
class BambooPlan: NSObject, Decodable, ISubscribable {
    //key of the project the plan belongs to
    let projectKey : String
    //name of the project the plan belongs to
    let projectName : String
    //Name of the plan
    let buildName : String
    //unique identifier for the plan
    let key : String

//    //list of plan branches
    let branches : [BambooPlanBranch]?

//    //direct link to the plan
//    let link : [BambooLink]
    required init(from decoded: Decoder) throws {
        let rawResponse = try BambooPlanContainer(from: decoded)
        self.projectKey = rawResponse.projectKey
        self.projectName = rawResponse.projectName
        self.buildName = rawResponse.buildName
        self.key = rawResponse.key
        self.branches = rawResponse.branches?.branchList
    }
}
