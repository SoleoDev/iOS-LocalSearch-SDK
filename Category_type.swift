//
//  Category_type.swift
//  Soleo Local API Demo
//
//  Created by Dan Sweetman on 6/8/16.
//  Copyright © 2016 Victor Jimenez Delgado. All rights reserved.
//

import Foundation

public struct Category {
    public var id : String?
    public var name : String?
    public var children : [Category]?
    
    public init() {
        
    }
}