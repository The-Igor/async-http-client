//
//  Errors.swift
//  
//
//  Created by Igor on 13.03.2023.
//

import Foundation

public extension Http{
    
    enum Errors : Error{
        case status(Int?, URLResponse, Data?)
    }
}
