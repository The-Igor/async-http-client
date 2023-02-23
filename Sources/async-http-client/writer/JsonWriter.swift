//
//  JsonWriter.swift
//  
//
//  Created by Igor on 22.02.2023.
//

import Foundation


/// An object that encodes instances of a data type as JSON objects
public struct JsonWriter: IWriter{
    
    
    // MARK: - Life circle
    
    public init() { }
    
    // MARK: - API Methods
    
    /// Encode data to send
    /// - Parameter items: Input data
    /// - Returns: Returns a JSON-encoded representation of the value you supply.
    public func write<T: Encodable>(_ items: T) throws -> Data {
        try JSONEncoder().encode(items)
    }
}
