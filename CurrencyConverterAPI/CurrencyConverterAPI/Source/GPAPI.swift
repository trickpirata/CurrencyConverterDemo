//
//  GPAPI.swift
//
//
//  Created by Trick Gorospe on 12/11/19.
//  Copyright © 2019 Trick Gorospe. All rights reserved.
//

import Foundation
import Moya

struct CONFIG {
    static let API = "https://api.exchangeratesapi.io"
    static let API_KEY = "5b237b7e"
}

enum GPAPI {
    case latestExchangeRate(base: String?)
}

extension GPAPI: TargetType {
    var baseURL: URL {
        return URL(string: CONFIG.API)!
    }
    
    var path: String {
        switch self {
        case .latestExchangeRate:
            return "/latest"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .latestExchangeRate:
            return .get
        }
        
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .latestExchangeRate(base: let base):
            if let b = base {
                return .requestParameters(parameters: ["base": b], encoding: URLEncoding.default)
            }
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var validationType: ValidationType {
        return .none
    }
}


public func url(route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}

let endpointClosure = { (target: GPAPI) -> Endpoint in
    let defaultEndpoint = MoyaProvider<GPAPI>.defaultEndpointMapping(for: target)
    switch target {
    case .latestExchangeRate:
        return defaultEndpoint
    }
}

let requestClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider.RequestResultClosure) in
    var request = try! endpoint.urlRequest() as URLRequest
    done(.success(request))
}
 
private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
