//
//  BambooProject.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/26/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

// This is a class rather than a struct so we can inherit from NSObject
// and be KVO compliant.
class BambooPlanBranch: NSObject, Decodable {
    //unique identifier for branch
    let key : String
    //combination of project, plan, and shortname
    let name : String
//    let description : String?
    //usually equivalent to the source branch
    let shortName : String
    //Direct link to branch
    let link : BambooLink
    
    enum CodingKeys : String, CodingKey{
        case key
        case name
        case shortName
        case link
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BambooPlanBranch.CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.name = try container.decode(String.self, forKey: .name)
        self.shortName = try container.decode(String.self, forKey: .shortName)
        self.link = try container.decode(BambooLink.self, forKey: .link)
    }
}
