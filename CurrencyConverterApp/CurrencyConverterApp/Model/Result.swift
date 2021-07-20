//
//  Error.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 7/20/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

enum Result<Success, Failure> where Failure: Error {
    case success(Success)
    case failure(Failure)
}
