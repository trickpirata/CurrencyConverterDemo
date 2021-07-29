//
//  GPCurrencyExchangeService.swift
//  CurrencyConverterAPI
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
import Moya
import CombineMoya
import Combine

public class GPCurrencyExchangeService: GPAPIService {
    
    public override init(){
        super.init()
    }

    public func getExchangeRate(forAmount amount: String, fromCurrency currentCurrency: String, toCurrency newCurrency: String) -> AnyPublisher<GPExchangeResponse, MoyaError> {
        return self.provider
            .requestPublisher(GPAPI.exchangeRate(fromAmount: amount, fromCurrency: currentCurrency, toCurrency: newCurrency))
            .map(GPExchangeResponse.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    

}
