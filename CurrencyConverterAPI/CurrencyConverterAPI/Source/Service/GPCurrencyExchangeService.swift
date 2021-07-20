//
//  GPCurrencyExchangeService.swift
//  CurrencyConverterAPI
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
import RxSwift
import RxMoya

public class GPCurrencyExchangeService: GPAPIService {
    
    public override init(){
        super.init()
    }
    
    public func getExchangeRate(forAmount amount: String, fromCurrency currentCurrency: String, toCurrency newCurrency: String) -> Observable<GPExchangeResponse> {
        return self.provider.rx.request(GPAPI.exchangeRate(fromAmount: amount, fromCurrency: currentCurrency, toCurrency: newCurrency))
            .map(GPExchangeResponse.self)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .background))
            .asObservable()
    }
}
