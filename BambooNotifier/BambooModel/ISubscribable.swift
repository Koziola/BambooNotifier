//
//  ISubscribable.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 4/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation

@objc protocol ISubscribable {
    var key : String { get }
    var name : String { get }
}
