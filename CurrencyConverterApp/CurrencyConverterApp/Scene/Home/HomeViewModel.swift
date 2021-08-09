//
//  HomeViewModel.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import CurrencyConverterAPI
import Combine


class HomeViewModel: ObservableObject  {
    typealias ConversionResult = Result<AccountBalance?, TransactionValidationError>
    
    // MARK: - Inputs
    @Published var txtSellInput = ""
    @Published var txtSellOutput = ""
    @Published var selectedBalanceCurrency = 0
    @Published var selectedCurrencyInput = 0
    @Published var selectedCurrencyOutput = 0
    @Published var activeAccountBalance: AccountBalance?
    @Published var outputMessage = ""
    @Published var txtBalance = ""
    @Published var isLoading = false
    @Published var showConversion = false
    
    // MARK: - Data
    @Published var history = [TransactionHistory]()
    @Published var currencies: [String] =
        ["EUR",
         "USD",
         "JPY"
        ]
    @Published var accountBalances = [AccountBalance]()

    // MARK: - Services
    private lazy var service = GPCurrencyExchangeService()
    
    // MARK: - Utils
    var cancelBag = Set<AnyCancellable>()
    
    // MARK: - Settings
    private var transactionCount = 0
    
    init() {
        accountBalances = startingBalance
        
        //Precompute
        Publishers
            .CombineLatest($selectedCurrencyOutput, $txtSellInput)
            .flatMap { self.preCompute(forCurrency: $0.0, $0.1) }
            .sink { _ in
                
            } receiveValue: { precomputedValue in
                self.txtSellOutput = precomputedValue
            }.store(in: &cancelBag)

        $selectedBalanceCurrency
            .map { self.accountBalances[$0] }
            .assign(to: &$activeAccountBalance)

        $selectedCurrencyInput
            .assign(to: &$selectedBalanceCurrency)
        
        $selectedCurrencyInput
            .map { self.accountBalances[$0] }
            .assign(to: &$activeAccountBalance)
        
        $activeAccountBalance
            .sink { balance in
                guard let balance = balance,
                      let index = self.accountBalances.firstIndex(of: balance) else { return }
                self.accountBalances[index] = balance
                self.txtBalance = NumberFormatter.currency.string(from: balance.balance as NSDecimalNumber) ?? ""
            }.store(in: &cancelBag)
        
       

        self.isLoading = false
    }
    
    
    /// Resets the data to its default value
    func reset() {
        accountBalances = startingBalance
        activeAccountBalance = startingBalance.first
        history.removeAll()
    }
    
    func convertCurrency() -> AnyPublisher<ConversionResult, TransactionValidationError> {
        let fromCurrency = currencies[selectedCurrencyInput]
        let selectedToCurrency = currencies[selectedCurrencyOutput]
        let error = verifyAccount()

        if let error = error {
            return Just(ConversionResult.failure(error))
                .setFailureType(to: TransactionValidationError.self)
                .eraseToAnyPublisher()
            
        }

        self.transactionCount += 1
        self.isLoading = true
        let input = Decimal(string: txtSellInput)!
        var activeAccountBalance = accountBalances[selectedCurrencyInput]
        let toBalance = accountBalances[selectedCurrencyOutput]

        let rule = DefaultRule(amount: input.doubleValue, amountOfTries: self.transactionCount)
        
        return service
            .getExchangeRate(forAmount: txtSellInput,
                                       fromCurrency: fromCurrency,
                                       toCurrency: selectedToCurrency)
            .mapError({ error in
                return .networkingError(error)
            })
            .map({ response in
                self.isLoading = false
         
                guard let converted = Decimal(string: response.amount) else {
                    return .failure(.cannotConvert)
                }
                let convertedBalance = converted - Decimal(rule.commissionFee)
                self.showConversion = true
                let formatter = NumberFormatter.currency
                self.txtSellOutput = formatter.string(from: convertedBalance as NSDecimalNumber) ?? ""
                self.outputMessage = "You have converted \(input) \(fromCurrency) to \(self.txtSellOutput) \(response.currency).\(self.transactionCount > 4 ? " Commission Fee - \(rule.commissionFee.roundToTwoDecimal()) \(fromCurrency)." : "")"

                self.history.append(TransactionHistory(id: UUID(), currency: response.currency, value: convertedBalance, charge: nil))
                activeAccountBalance.balance -= (input - Decimal(rule.commissionFee))
                if var newBalance = self.accountBalances.first(where: {$0.id == toBalance.id}) {
                    newBalance.balance += convertedBalance
                    self.accountBalances[self.selectedCurrencyOutput] = newBalance
                }

                self.activeAccountBalance = activeAccountBalance
                self.txtBalance = formatter.string(from: activeAccountBalance.balance as NSDecimalNumber) ?? ""
                return .success(activeAccountBalance)
            })
            .eraseToAnyPublisher()
    }
    

    private func preCompute(forCurrency currencyIndex: Int,_ input: String) -> AnyPublisher<String, TransactionValidationError> {
        if currencies.count == 0 || input.count == 0 {
            return Just("")
                .setFailureType(to: TransactionValidationError.self)
                .eraseToAnyPublisher()
        }
        let fromCurrency = currencies[selectedCurrencyInput]
        let selectedToCurrency = currencies[currencyIndex]
        self.isLoading = true
        return service
            .getExchangeRate(forAmount: input,
                                       fromCurrency: fromCurrency,
                                       toCurrency: selectedToCurrency)
            .mapError({ error in
                return .networkingError(error)
            })
            .map({ response in
                self.isLoading = false
                let formatter = NumberFormatter.currency

                guard let converted = Decimal(string: response.amount) else {
                    return ""
                }

                return formatter.string(from: converted as NSDecimalNumber) ?? ""
            })
            .eraseToAnyPublisher()
    }
    
    private func verifyAccount() -> TransactionValidationError? {
        let selectedFromAccount = accountBalances[selectedCurrencyInput]
        let selectedToAccount = accountBalances[selectedCurrencyOutput]
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


