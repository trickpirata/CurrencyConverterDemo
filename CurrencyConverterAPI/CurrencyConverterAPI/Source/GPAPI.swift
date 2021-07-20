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
    static let API = "http://api.evp.lt/currency/commercial"
}

enum GPAPI {
    case exchangeRate(fromAmount: String, fromCurrency: String, toCurrency: String)
}

extension GPAPI: TargetType {
    var baseURL: URL {
        return URL(string: CONFIG.API)!
    }
    
    var path: String {
        switch self {
        case .exchangeRate(fromAmount: let fromAmount, fromCurrency: let fromCurrency, toCurrency: let toCurrency):
            return "/exchange/\(fromAmount)-\(fromCurrency)/\(toCurrency)/latest"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .exchangeRate:
            return .get
        }
        
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .exchangeRate:
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
    case .exchangeRate:
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
