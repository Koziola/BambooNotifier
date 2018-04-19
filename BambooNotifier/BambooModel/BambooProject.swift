//
//  BambooProject.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

fileprivate struct BambooProjectContainer: Decodable {
    let key : String
    let name : String
    let link : BambooLink
    let projectKey : String?
    let projectName : String?
    let plans : BambooProjectPlanList?
    
    struct BambooProjectPlanList: Decodable{
        let size: Int
        let planList: [BambooPlan]?

        enum CodingKeys: String, CodingKey{
            case planList = "plan"
            case size
        }
    }
}

struct BambooProject: Decodable {
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
    
    init(from decoded: Decoder) throws {
        let rawResponse = try BambooProjectContainer(from: decoded)
        self.key = rawResponse.key
        self.name = rawResponse.name
        self.link = rawResponse.link
        self.projectKey = rawResponse.projectKey
        self.projectName = rawResponse.projectName
        self.plans = rawResponse.plans?.planList
    }
}
