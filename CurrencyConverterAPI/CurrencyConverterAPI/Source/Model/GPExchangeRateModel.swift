//
//  GPExchangeRateModel.swift
//  CurrencyConverterAPI
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
import RealmSwift

public class GPExchangeRateResponse: Codable {
    public var rates = [GPExchangeRateModel]()
    public var date: Date?
    public var base = ""
    
    private enum Keys: String, CodingKey {
        case rates
        case base
        case date
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        do {
            if let data: Dictionary<String, Decimal> = try container.decodeIfPresent(Dictionary<String, Decimal>.self, forKey: .rates) ?? nil {
                rates = data.map({ (key, value) -> GPExchangeRateModel in
                    return GPExchangeRateModel(currency: key, rate: value)
                })
            }
            
            base = try container.decodeIfPresent(String.self, forKey: .base) ?? ""
            if let stringDate = try container.decodeIfPresent(String.self, forKey: .date) ?? nil {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                date = formatter.date(from: stringDate)
            }
            
        } catch let error {
            print(error)
        }
    }
}

public class GPExchangeRateModel: Codable {
    public var currency = ""
    public var rate = Decimal(integerLiteral: 0)
    
//    override static func primaryKey() -> String? {
//        return "currency"
//    }
//
    public init(currency: String, rate: Decimal) {
        self.currency = currency
        self.rate = rate
    }
    
//    required init() {
//
//    }
}
