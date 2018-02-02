//
//  BambooAPI.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/24/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class BambooAPI {
    let instanceBaseAddress: URL
    let apiResourcePath : String = "/rest/api/latest"
    init(instanceBaseAddress : URL){
        self.instanceBaseAddress = instanceBaseAddress
    }
    
    func getListOfProjects(success: @escaping ([BambooProject]) -> (), fail: @escaping (String) -> ()){
        guard var components = URLComponents(url: instanceBaseAddress, resolvingAgainstBaseURL: false) else{
            fail("Can't construct url components")
            return
        }
        var subPath = apiResourcePath
        subPath += "/project"
        subPath += "/.json"
        components.path = subPath
        let queryItem = URLQueryItem(name: "expand", value: "projects.plans.plan.branches")
        components.queryItems = [queryItem]
        
        guard let fullURL = components.url else{
            fail("Invalid URL.")
            return
        }
        var request = URLRequest(url: fullURL)
        
        let requestTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, err in
            if err != nil {
                fail(err!.localizedDescription)
                return
            }
            if data != nil {
                do {
                    let decoder = JSONDecoder()
                    let projectService = try decoder.decode(BambooProjectService.self, from: data!)
                    success(projectService.container.projectList)
                    return
                } catch {
                    print("Error parsing JSON from http response")
                }
            }
        })
        requestTask.resume()
    }
}
