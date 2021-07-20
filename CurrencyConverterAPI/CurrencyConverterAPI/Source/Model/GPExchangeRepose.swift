//
//  GPExchangeRepose.swift
//  CurrencyConverterAPI
//
//  Created by Trick Gorospe on 7/19/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

public class GPExchangeResponse: Codable {
    public let amount: String
    public let currency: String
    
    private enum Keys: String, CodingKey {
        case amount
        case currency
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        amount = try container.decode(String.self, forKey: .amount)
        currency = try container.decode(String.self, forKey: .currency)
    }
}
