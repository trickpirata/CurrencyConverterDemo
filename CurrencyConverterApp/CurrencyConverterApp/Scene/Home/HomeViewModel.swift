//
//  HomeViewModel.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import CurrencyConverterAPI
import RxSwift
import RxCocoa

class HomeViewModel: ObservableObject  {
    // MARK: - Inputs
    let load: AnyObserver<Void>
    let submit: AnyObserver<Void>
    
    // MARK: - Outputs
    let didLoad: Observable<Void>
    let didTapSubmit: Observable<Void>
    
    // MARK: - Data
    var data = BehaviorRelay<[GPExchangeRateModel]>(value: [GPExchangeRateModel]())
    @Published var history = [TransactionHistory]()
    @Published var currencies = [String]()
    @Published var isLoading = false
    @Published var showConversion = false
    @Published var txtSellInput = ""
    @Published var txtSellOutput = ""
    @Published var selectedCurrencyInput = 0
    @Published var selectedCurrencyOutput = BehaviorRelay<Int>(value: 0)
    @Published var outputMessage = ""
    @Published var txtBalance = ""
    
    // MARK: - Services
    private lazy var service = GPCurrencyExchangeService()
    
    // MARK: - Utils
    private let disposeBag = DisposeBag()
    
    // MARK: - Settings
    private var transactionCount = 0
    @Published var currentBalance = Decimal(floatLiteral: 0)
    
    init(withCurrentBalance balance: Decimal) {
        let _load = PublishSubject<Void>()
        self.load = _load.asObserver()
        self.didLoad = _load.asObservable()
        
        let _submit = PublishSubject<Void>()
        self.submit = _submit.asObserver()
        self.didTapSubmit = _submit.asObservable()
        currentBalance = balance
        txtBalance = NumberFormatter.currency.string(from: currentBalance as NSDecimalNumber) ?? ""
        
        selectedCurrencyOutput.asObservable()
            .flatMapLatest({ [weak self](value) -> Observable<String> in
                guard let self = self else {
                    return .empty()
                }
                return self.preCompute(forCurrency: value)
            })
            .subscribe(onNext: { [weak self](value) in
                guard let self = self else {
                    return
                }
                self.txtSellOutput = value
            }).disposed(by: disposeBag)
    }
    
    func loadData() {
        isLoading = true
        service.getLatestCurrencyExchange(forBaseCurrency: nil)
            .catchError { (error) -> Observable<GPExchangeRateResponse> in
                return .empty()
            }
            .subscribe(onNext: { (response) in
                self.data.accept(response.rates)
                self.currencies = response.rates.map({ (rates) -> String in
                    return rates.currency
                })
                self.currencies.append("EUR")
                self.currencies = self.currencies.sorted{ $0.lowercased() < $1.lowercased() }
                self.isLoading = false
            })
            .disposed(by: disposeBag)
    }
    
    func convertCurrency() -> Observable<Void> {
        let fromCurrency = currencies[selectedCurrencyInput]
        let selectedToCurrency = currencies[selectedCurrencyOutput.value]
        let input = txtSellInput

        if data.value.count == 0 || Decimal(string: input)!.doubleValue > currentBalance.doubleValue {
            return .just(Void())
        }
        self.transactionCount += 1
        self.isLoading = true
        let rule = DefaultRule(amount: Double(input) ?? 0.0, amountOfTries: self.transactionCount)
        return service
            .getLatestCurrencyExchange(forBaseCurrency: fromCurrency)
            .catchError { (error) -> Observable<GPExchangeRateResponse> in
                return .empty()
            }
            .flatMapLatest { (response) -> Observable<Void> in
                self.isLoading = false
                let to = response.rates.first { $0.currency == selectedToCurrency }
                guard let toCurrency = to else {
                    return .just(Void())
                }
                
                //Do computation
                var converted =  (Decimal(string: input)! * toCurrency.rate)
                converted -= Decimal(rule.commissionFee)
                
                self.showConversion = true
                let formatter = NumberFormatter.currency
                self.txtSellOutput = formatter.string(from: converted as NSDecimalNumber) ?? ""
                self.outputMessage = "You have converted \(input) \(fromCurrency) to \(self.txtSellOutput) \(toCurrency.currency).\(self.transactionCount > 4 ? " Commission Fee - 0.70 \(fromCurrency)." : "")"
                
                self.history.append(TransactionHistory(id: UUID(), currency: toCurrency.currency, value: converted, charge: nil))
                self.currentBalance -= (Decimal(string: input)! - Decimal(rule.commissionFee))
                self.txtBalance = NumberFormatter.currency.string(from: self.currentBalance as NSDecimalNumber) ?? ""
                
                return .just(Void())
            }
    }
    
    private func preCompute(forCurrency currencyIndex: Int) -> Observable<String> {
        if currencies.count == 0 {
            return .just("0")
        }
        let fromCurrency = currencies[selectedCurrencyInput]
        let selectedToCurrency = currencies[currencyIndex]
        let input = txtSellInput
        return service
            .getLatestCurrencyExchange(forBaseCurrency: fromCurrency)
            .catchError { (error) -> Observable<GPExchangeRateResponse> in
                return .empty()
            }
            .flatMapLatest { (response) -> Observable<String> in
                self.isLoading = false
                let to = response.rates.first { $0.currency == selectedToCurrency }
                guard let toCurrency = to else {
                    return .just("")
                }
                
                //Do computation
                let converted = (Decimal(string: input)! * toCurrency.rate)

                let formatter = NumberFormatter.currency
                return .just(formatter.string(from: converted as NSDecimalNumber) ?? "")
            }
    }
}


