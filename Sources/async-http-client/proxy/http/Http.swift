//
//  Http.swift
//  
//
//  Created by Igor on 22.02.2023.
//

import Foundation

/// Name space  for http async client
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct Http{
   
    /// An array of name-value pairs for a request
    public typealias Query = [(String, String?)]

    /// A dictionary containing all of the HTTP header fields for a request
    public typealias Headers = [String: String]
    
}
