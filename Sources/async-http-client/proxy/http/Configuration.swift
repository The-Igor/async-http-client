//
//  Configuration.swift
//  
//
//  Created by Igor on 22.02.2023.
//

import Foundation

public extension Http{
    
    /// Configuration http client
    struct Configuration<R: IReader, W: IWriter>: IConfiguration{
                
        /// Base url
        public var baseURL: URL
               
        /// Get session
        public var getSession: URLSession {
            session
        }
        
        let defaultContentType : String = "application/json"
        
        /// Reader
        public let reader: R
                
        /// Writer
        public let writer: W
                
        /// An object that coordinates a group of related, network data transfer task
        private let session : URLSession
        
        /// - Parameters:
        ///   - reader: Reader
        ///   - writer: Writer
        ///   - baseURL: Base URL
        ///   - sessionConfiguration: A configuration object that defines behavior and policies for a URL session
        ///   - sessionDelegate: A protocol that defines methods that URL session instances call on their delegates to handle session-level events, like session life cycle changes
        ///   - queue: A queue that regulates the execution of operations
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public init(
            reader: R,
            writer: W,
            baseURL: URL,
            
            sessionConfiguration: URLSessionConfiguration,
            delegate: URLSessionDelegate? = nil,
            delegateQueue queue: OperationQueue? = nil
        ) {
            self.reader = reader
            self.writer = writer
            self.baseURL = baseURL
            self.session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: queue)
        }
        
        /// - Parameters:
        ///   - reader: Reader
        ///   - writer: Writer
        ///   - baseURL: Base URL
        ///   - sesssion: An object that coordinates a group of related, network data transfer tasks
        public init(
            reader: R,
            writer: W,
            baseURL: URL,
            session : URLSession
        ) {
            self.reader = reader
            self.writer = writer
            self.baseURL = baseURL
            self.session = session
        }
    }
}

public extension Http.Configuration where R == JsonReader, W == JsonWriter {
    
    /// Create configuration by base url
    /// - Parameter baseURL: Base url
    init(baseURL: URL) {
        self.reader = JsonReader()
        self.writer = JsonWriter()
        self.baseURL = baseURL
        self.session = URLSession.shared
    }
}
