//
//  APIResource.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 2/2/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

protocol BambooAPIResource {
    associatedtype Model
    var resourcePath : String { get }
    func makeModel(data: Data) -> Model?
}
