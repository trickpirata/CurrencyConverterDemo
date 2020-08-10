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
    
    public func getLatestCurrencyExchange(forBaseCurrency baseCurrency: String?) -> Observable<GPExchangeRateResponse> {
        return self.provider.rx.request(GPAPI.latestExchangeRate(base: baseCurrency))
        .map(GPExchangeRateResponse.self)
        .asObservable()
    }
}
