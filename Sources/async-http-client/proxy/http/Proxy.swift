//
//  Proxy.swift
//
//  Created by Igor Shelopaev on 29.04.2021.
//

import Foundation
import retry_policy_service

public extension Http{
    
    /// Http client for creating requests to the server
    /// Proxy does not keep any state It's just a transport layer to get and pass data
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    struct Proxy<R: IReader, W: IWriter>: IProxy, @unchecked Sendable{
        
        /// An array of name-value pairs for a request
        public typealias Query = [(String, String?)]
        
        /// A dictionary containing all of the HTTP header fields for a request
        public typealias Headers = [String: String]
        
        /// Configuration
        public let config : Configuration<R,W>
        
        /// Http client for creating requests to the server
        /// - Parameter config: Configuration
        public init(config: Configuration<R,W>){
            self.config = config
        }
        
        /// GET request
        /// - Parameters:
        ///   - path: Path
        ///   - query: An array of name-value pairs
        ///   - headers: A dictionary containing all of the HTTP header fields for a request
        ///   - retry: Amount of attempts Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an  example Default value to validate statusCode == 200 You can set diff combinations check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func get<T>(
            path: String,
            query : Query? = nil,
            headers : Headers? = nil,
            retry : UInt = 5,
            validate : [Http.Validate] = [.status(200)],
            taskDelegate: ITaskDelegate? = nil
        ) async throws
        -> Http.Response<T> where T: Decodable
        {
            
            let request = try buildURLRequest(
                config.baseURL,
                for: path, query: query, headers: headers)
            
            return try await send(with: request, retry: strategy(retry), validate, taskDelegate)
        }
        
        /// POST request
        /// - Parameters:
        ///   - path: Path
        ///   - query: An array of name-value pairs
        ///   - headers: A dictionary containing all of the HTTP header fields for a request
        ///   - retry: Amount of attempts Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an example Default value to validate statusCode == 200 Check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func post<T>(
            path: String,
            query : Query? = nil,
            headers : Headers? = nil,
            retry : UInt = 5,
            validate : [Http.Validate] = [.status(200)],
            taskDelegate: ITaskDelegate? = nil
        ) async throws
        -> Http.Response<T> where T: Decodable
        {
            let request = try buildURLRequest(
                config.baseURL,
                for: path, method: .post, query: query, headers: headers)
            
            return try await send(with: request, retry: strategy(retry), validate, taskDelegate)
        }
        
        /// POST request
        /// - Parameters:
        ///   - path: Path
        ///   - body: The data sent as the message body of a request, such as for an HTTP POST or PUT requests
        ///   - query: An array of name-value pairs
        ///   - headers: A dictionary containing all of the HTTP header fields for a request
        ///   - retry: Amount of attempts Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an example Default value to validate statusCode == 200 Check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func post<T, V : Encodable>(
            path: String,
            body : V,
            query : Query? = nil,
            headers : Headers? = nil,
            retry : UInt = 5,
            validate : [Http.Validate] = [.status(200)],
            taskDelegate: ITaskDelegate? = nil
        ) async throws
        -> Http.Response<T> where T: Decodable
        {
            let body = try config.writer.write(body)
            let request = try buildURLRequest(
                config.baseURL,
                for: path, method: .post, query: query, body: body, headers: headers)
            
            return try await send(with: request, retry: strategy(retry), validate, taskDelegate)
        }
        
        /// PUT request
        /// - Parameters:
        ///   - path: Path
        ///   - body: The data sent as the message body of a request, such as for an HTTP POST or PUT requests
        ///   - query: An array of name-value pairs
        ///   - headers: A dictionary containing all of the HTTP header fields for a request
        ///   - retry: Amount of attempts Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an  example Default value to validate statusCode == 200 You can set diff combinations check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func put<T, V : Encodable>(
            path: String,
            body : V,
            query : Query? = nil,
            headers : Headers? = nil,
            retry : UInt = 5,
            validate : [Http.Validate] = [.status(200)],
            taskDelegate: ITaskDelegate? = nil
        ) async throws
        -> Http.Response<T> where T: Decodable
        {
            let body = try config.writer.write(body)
            var request = try buildURLRequest(
                config.baseURL,
                for: path, method: .put, query: query, body: body, headers: headers)
            
            if hasNotContentType(config.getSession, request){
                let content = config.defaultContentType
                request.setValue(content, forHTTPHeaderField: "Content-Type") // for PUT
            }
            
            return try await send(with: request, retry: strategy(retry), validate, taskDelegate)
        }
        
        /// DELETE request
        /// - Parameters:
        ///   - path: Path
        ///   - query: An array of name-value pairs
        ///   - headers: A dictionary containing all of the HTTP header fields for a request
        ///   - retry: Amount of attempts Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an  example Default value to validate statusCode == 200 You can set diff combinations check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func delete<T>(
            path: String,
            query : Query? = nil,
            headers : Headers? = nil,
            retry : UInt = 5,
            validate : [Http.Validate] = [.status(200)],
            taskDelegate: ITaskDelegate? = nil
        ) async throws
        -> Http.Response<T> where T: Decodable
        {
            let request = try buildURLRequest(
                config.baseURL,
                for: path, method: .delete, query: query, headers: headers)

            return try await send(with: request, retry: strategy(retry), validate, taskDelegate)
        }
        
        /// Send custom request based on the specific request instance
        /// - Parameters:
        ///   - request: A URL load request that is independent of protocol or URL scheme
        ///   - retry: ``RetryService.Strategy`` strategy Default value .exponential with 5 retry and duration 2.0
        ///   - validate: Set of custom validate fun ``Http.Validate`` For status code like an  example Default value to validate statusCode == 200 You can set up diff combinations check out ``Http.Validate.Status``
        ///   - taskDelegate: A protocol that defines methods that URL session instances call on their delegates to handle task-level events
        public func send<T>(
            with request : URLRequest,
            retry strategy : RetryService.Strategy = .exponential(),
            _ validate : [Http.Validate] = [.status(200)],
            _ taskDelegate: ITaskDelegate? = nil
        ) async throws -> Http.Response<T> where T : Decodable
        {
            
            let reader = config.reader
            
            let (data,response) = try await sendRetry(
                with: request,
                retry: strategy,
                taskDelegate,
                config.getSession
            )
            
            try validateStatus(response, by : validate.pickStatusRules(), with: data)
            
            let value: T = try reader.read(data: data)
            
            return .init(value: value, data: data, response, request)
        }
    }
}

// MARK: - File private

/// Check presents of the content type header
/// - Parameters:
///   - session: URLSession
///   - request: URLRequest
/// - Returns: true - content-type header is not empty
fileprivate func hasNotContentType(_ session : URLSession,_ request : URLRequest) -> Bool{
    request.value(forHTTPHeaderField: "Content-Type") == nil &&
    session.configuration.httpAdditionalHeaders?["Content-Type"] == nil
}

/// Get default strategy for retries
fileprivate let strategy : (UInt) -> RetryService.Strategy = { retry in
   .exponential(retry: retry)
}
