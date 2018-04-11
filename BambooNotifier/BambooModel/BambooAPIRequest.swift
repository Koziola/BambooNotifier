//
//  BambooAPIRequest.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 2/2/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

class BambooAPIRequest<Resource : BambooAPIResource>{
    let resource : Resource
    let basePath : URL
    let apiPath : String = "/rest/api/latest"
    let jsonEXT : String = "/.json"
    
    init(basePath: URL, resource: Resource){
        self.resource = resource
        self.basePath = basePath
    }
    
    func load(success: @escaping (Resource.Model?) -> (),
               fail: @escaping (String) -> ()) {
        guard let url = buildURL() else{
            fail ("Error building URL")
            return
        }
        
        let request = URLRequest(url: url)
        let requestTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, err in
            if err != nil {
                fail(err!.localizedDescription)
                return
            }
            if data != nil {
                let model = self.resource.makeModel(data: data!)
                success(model)
                return
            }
        })
        requestTask.resume()
    }
    
    private func buildURL() -> URL? {
        guard var components = URLComponents(url: basePath, resolvingAgainstBaseURL: false) else {
            print("Error initializing URL components object.")
            return nil
        }
        var subPath = apiPath
        subPath += resource.resourcePath
        if resource.detailPath != nil {
            subPath += "/\(resource.detailPath!)"
        }
        subPath += jsonEXT
        components.path = subPath
        
        if resource.expandPath != nil {
            components.queryItems = [URLQueryItem(name: "expand", value: resource.expandPath)]
        }
        
        return components.url
    }
}
