//
//  CurrencyConverterAPITests.swift
//  CurrencyConverterAPITests
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import CurrencyConverterAPI

class CurrencyConverterAPITests: XCTestCase {
    var cancellable: AnyCancellable?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetCurrencyService() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let service = GPCurrencyExchangeService()

        let currencyCallExpectation = expectation(description: "Should display exchange rate")
        cancellable = service.getExchangeRate(forAmount: "340.51", fromCurrency: "EUR", toCurrency: "USD")
            .print()
            .sink { _ in
            } receiveValue: { response in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response.amount)
                XCTAssertNotNil(response.currency)
                currencyCallExpectation.fulfill()
                self.cancellable = nil
            }

        waitForExpectations(timeout: 5.0, handler: nil)
    }
}
