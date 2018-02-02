//
//  BambooProjectList.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 2/2/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

struct BambooProjectService: Codable {
    //list of projects
    let container : BambooProjectContainerService
    
    struct BambooProjectContainerService : Codable {
        var size : Int
        var projectList : [BambooProject]
        
        enum CodingKeys: String, CodingKey{
            case projectList = "project"
            case size = "size"
        }
    }
    
    enum CodingKeys: String, CodingKey{
        case container = "projects"
    }
}
