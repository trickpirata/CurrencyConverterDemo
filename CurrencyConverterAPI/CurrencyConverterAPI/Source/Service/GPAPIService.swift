//
//  GPAPIService.swift
// 
//
//  Created by Trick Gorospe on 12/11/19.
//  Copyright © 2019 Trick Gorospe. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData = try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? String()
    } catch {
        return String()
    }
}

public class GPAPIService: NSObject {
    var provider: MoyaProvider<GPAPI>!

    override init(){
        super.init()
        
        self.provider = MoyaProvider<GPAPI>(endpointClosure: endpointClosure,
                                            requestClosure: requestClosure,
                                            stubClosure: MoyaProvider.neverStub,
                                            plugins:  [NetworkLoggerPlugin(configuration: .init(formatter: .init(responseData: JSONResponseDataFormatter),
                                            logOptions: .verbose))])
    }
}

private extension GPAPIService {
    private func request<T: Decodable>(target: GPAPI, completion: @escaping(Result<T, Error>) -> ()) {
        
    }
}
