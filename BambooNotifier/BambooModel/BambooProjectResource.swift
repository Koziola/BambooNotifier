//
//  BambooProjectResource.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 2/2/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class BambooProjectResource : BambooAPIResource {
    typealias Model = [BambooProject]
    
    let resourcePath = "/project"
    let detailPath: String?
    let expandPath: String?
    
    init(projectKey : String?, expandPath : String?) {
        detailPath = projectKey
        self.expandPath = expandPath
    }
    func makeModel(data: Data) -> Model? {
        let decoder = JSONDecoder()
        do {
            if (detailPath == nil){
                let projectService = try decoder.decode(BambooProjectService.self, from: data)
                return projectService.container.projectList
            } else{
                let project = try decoder.decode(BambooProject.self, from: data)
                return [project]
            }
        } catch {
            print("Error decoding Bamboo projects.")
        }
        return nil
    }
}
