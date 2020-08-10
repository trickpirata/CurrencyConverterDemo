//
//  CurrencyConverterAPITests.swift
//  CurrencyConverterAPITests
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
@testable import CurrencyConverterAPI

class CurrencyConverterAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetCurrencyService() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let disposeBag = DisposeBag()
        let c = GPCurrencyExchangeService()
        
        let currencyCallExpectation = expectation(description: "check api currency call")
        c.getLatestCurrencyExchange()
            .debug("CurrencyConverterAPITests.testGetCurrencyService")
            .catchError { (error) -> Observable<GPExchangeRateResponse> in
                return .empty()
            }.subscribe(onNext: { (response) in
                XCTAssertNotNil(response)
                XCTAssertNotNil(response.date)
                XCTAssertNotNil(response.rates)
                currencyCallExpectation.fulfill()
            }).disposed(by: disposeBag)
        
        wait(for: [currencyCallExpectation], timeout: 5.0)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
