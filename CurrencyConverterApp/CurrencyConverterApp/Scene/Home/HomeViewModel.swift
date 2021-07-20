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
import RxOptional

struct AccountBalance: Equatable {
    let id = UUID()
    var balance: Decimal
    var currency: String
    
    static func == (lhs: AccountBalance, rhs: AccountBalance) -> Bool {
        if (lhs.id ==  rhs.id) { return true }
        return false
    }
}

class HomeViewModel: ObservableObject  {
    // MARK: - Inputs
    let load: AnyObserver<Void>
    let submit: AnyObserver<Void>
    
    // MARK: - Outputs
    let didLoad: Observable<Void>
    let didTapSubmit: Observable<Void>
    
    // MARK: - Data
    @Published var history = [TransactionHistory]()
    @Published var currencies: [String] =
        ["EUR",
         "USD",
         "JPY"
        ]
    @Published var accountBalances = [AccountBalance]()
    @Published var isLoading = false
    @Published var showConversion = false
    @Published var txtSellInput = ""
    @Published var txtSellOutput = ""
    @Published var selectedBalanceCurrency: BehaviorRelay = .init(value: 0)
    @Published var selectedCurrencyInput: BehaviorRelay = .init(value: 0)
    @Published var selectedCurrencyOutput: BehaviorRelay = .init(value: 0)
    @Published var activeAccountBalance: BehaviorRelay<AccountBalance?> = .init(value: nil)
    @Published var outputMessage = ""
    @Published var txtBalance = ""
    
    // MARK: - Services
    private lazy var service = GPCurrencyExchangeService()
    
    // MARK: - Utils
    private let disposeBag = DisposeBag()
    
    // MARK: - Settings
    private var transactionCount = 0
    
    init() {
        let _load = PublishSubject<Void>()
        self.load = _load.asObserver()
        self.didLoad = _load.asObservable()
        
        let _submit = PublishSubject<Void>()
        self.submit = _submit.asObserver()
        self.didTapSubmit = _submit.asObservable()
        accountBalances = startingBalance
        
        selectedCurrencyOutput.asObservable()
            .flatMapLatest({ [weak self](value) -> Observable<Result<String, TransactionValidationError>> in
                guard let self = self else {
                    return .empty()
                }
                return self.preCompute(forCurrency: value)
            })
            .subscribe(onNext: { [weak self](value) in
                guard let self = self else {
                    return
                }
                switch value {
                case .success(let amount):
                    self.txtSellOutput = amount
                default:
                    self.txtSellOutput = ""
                }
            }).disposed(by: disposeBag)
        
        selectedBalanceCurrency
            .map({ [unowned self] index -> AccountBalance in
                return self.accountBalances[index]
            })
            .bind(to: activeAccountBalance)
            .disposed(by: disposeBag)
        selectedCurrencyInput.bind(to: selectedBalanceCurrency).disposed(by: disposeBag)
        selectedCurrencyInput
            .map({ [unowned self] index -> AccountBalance in
                return self.accountBalances[index]
            })
            .bind(to: activeAccountBalance)
            .disposed(by: disposeBag)
        
        activeAccountBalance
            .asObservable()
            .subscribe(onNext: { [weak self] balance in
                guard let self = self,
                      let balance = balance,
                      let index = self.accountBalances.firstIndex(of: balance)
                      else { return }
                self.accountBalances[index] = balance
                self.txtBalance = NumberFormatter.currency.string(from: balance.balance as NSDecimalNumber) ?? ""
            }).disposed(by: disposeBag)
        
        self.isLoading = false
    }
    
    func convertCurrency() -> Observable<Result<AccountBalance?, TransactionValidationError>> {
        let fromCurrency = currencies[selectedCurrencyInput.value]
        let selectedToCurrency = currencies[selectedCurrencyOutput.value]
        let error = verifyAccount()
        
        if let error = error {
            return .just(.failure(error))
        }
        
        self.transactionCount += 1
        self.isLoading = true
        let input = Decimal(string: txtSellInput)!
        var activeAccountBalance = accountBalances[selectedCurrencyInput.value]
        var toBalance = accountBalances[selectedCurrencyOutput.value]
        
        let rule = DefaultRule(amount: input.doubleValue, amountOfTries: self.transactionCount)
        
        return service
            .getExchangeRate(forAmount: txtSellInput, fromCurrency: fromCurrency, toCurrency: selectedToCurrency)
            .catchError { (error) -> Observable<GPExchangeResponse> in
                return .empty()
            }.observeOn(MainScheduler.instance)
            .flatMapLatest { [weak self]response -> Observable<Result<AccountBalance?, TransactionValidationError>> in
                guard let self = self else {
                    return .empty()
                }
                self.isLoading = false
                
                guard let converted = Decimal(string: response.amount) else {
                    return .just(.failure(.cannotBeZero))
                }
                
                let convertedBalance = converted - Decimal(rule.commissionFee)
                self.showConversion = true
                let formatter = NumberFormatter.currency
                self.txtSellOutput = formatter.string(from: convertedBalance as NSDecimalNumber) ?? ""
                self.outputMessage = "You have converted \(input) \(fromCurrency) to \(self.txtSellOutput) \(response.currency).\(self.transactionCount > 4 ? " Commission Fee - 0.70 \(fromCurrency)." : "")"
                
                self.history.append(TransactionHistory(id: UUID(), currency: response.currency, value: convertedBalance, charge: nil))
                activeAccountBalance.balance -= (input - Decimal(rule.commissionFee))
                if var newBalance = self.accountBalances.first(where: {$0.id == toBalance.id}) {
                    newBalance.balance += convertedBalance
                    self.accountBalances[self.selectedCurrencyOutput.value] = newBalance
                }
    
                self.activeAccountBalance.accept(activeAccountBalance)
                self.txtBalance = NumberFormatter.currency.string(from: activeAccountBalance.balance as NSDecimalNumber) ?? ""

                return .just(.success(activeAccountBalance))
            }
    }
    
    private func preCompute(forCurrency currencyIndex: Int) -> Observable<Result<String, TransactionValidationError>> {
        if currencies.count == 0 || txtSellInput.count == 0 {
            return .just(.success("0"))
        }
        let fromCurrency = currencies[selectedCurrencyInput.value]
        let selectedToCurrency = currencies[currencyIndex]
        self.isLoading = true
        return service
            .getExchangeRate(forAmount: txtSellInput, fromCurrency: fromCurrency, toCurrency: selectedToCurrency)
            .catchError { (error) -> Observable<GPExchangeResponse> in
                return .empty()
            }
            .observeOn(MainScheduler.instance)
            .flatMapLatest { (response) -> Observable<Result<String, TransactionValidationError>> in
                self.isLoading = false
                
                guard let converted = Decimal(string: response.amount) else {
                    return .just(.failure(.cannotConvert))
                }
            
                let formatter = NumberFormatter.currency
                return .just(.success(formatter.string(from: converted as NSDecimalNumber) ?? ""))
            }
    }
    
    private func verifyAccount() -> TransactionValidationError? {
        let selectedFromAccount = accountBalances[selectedCurrencyInput.value]
        let selectedToAccount = accountBalances[selectedCurrencyOutput.value]
        //if there are no inputs, return error
        guard let input = Decimal(string: txtSellInput) else { return .incompleteDetails }
        
        //if the selected account balance is zero, return error
        guard selectedFromAccount.balance.doubleValue > 0 else { return .cannotBeZero }
        
        //if the input is lower than selectedaccount, return error
        guard input.doubleValue < selectedFromAccount.balance.doubleValue else { return .inputLower }
        
        guard selectedFromAccount.id != selectedToAccount.id else { return .invalid }
        
        return nil
    }
    
    private let startingBalance: [AccountBalance] = {
         [  AccountBalance(balance: Decimal(1000), currency: "EUR"),
            AccountBalance(balance: Decimal(0), currency: "USD"),
            AccountBalance(balance: Decimal(0), currency: "JPY")]
    }()
}


