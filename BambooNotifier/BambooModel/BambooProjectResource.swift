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
    func makeModel(data: Data) -> Model? {
        let decoder = JSONDecoder()
        do {
            let projectService = try decoder.decode(BambooProjectService.self, from: data)
            return projectService.container.projectList
        } catch {
            print("Error decoding Bamboo projects.")
        }
        return nil
    }
}
