//
//  HomeContentView.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI
import RxSwift
import CurrencyConverterUI
import ActivityIndicatorView

struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding private var historyItems: [HistoryViewItem]
    @Binding private var selectedCurrencyInput: Int
    @Binding private var selectedCurrencyOutput: Int
    @Binding private var selectedBalanceCurrency: Int
    @State private var showErrorAlert: (Bool, String?) = (false, nil)
    private let disposeBag = DisposeBag()
    var body: some View {
        let history = Binding<[HistoryViewItem]>(
            get: {
                self.viewModel.history.map { (history) -> HistoryViewItem in
                    let formatter = NumberFormatter.currency
                    let value = formatter.string(from: history.value as NSDecimalNumber) ?? ""
                    return HistoryViewItem(text:"\(value)\n\(history.currency)")
                }
            },
            set: {
                self.historyItems = $0
            }
        )
        
        //Workaround for RxSwift + SwiftUI binding
        let currencyInput = Binding<Int>(
            get: {
                self.viewModel.selectedCurrencyInput.value
            },
            set: {
                self.selectedCurrencyInput = $0
                self.viewModel.selectedCurrencyInput.accept($0)
            }
        )
        
        let currencyOutput = Binding<Int>(
            get: {
                self.viewModel.selectedCurrencyOutput.value
            },
            set: {
                self.selectedCurrencyOutput = $0
                self.viewModel.selectedCurrencyOutput.accept($0)
            }
        )
        
        let selectedBalance = Binding<Int>(
            get: {
                self.viewModel.selectedBalanceCurrency.value
            },
            set: {
                self.selectedBalanceCurrency = $0
                self.viewModel.selectedBalanceCurrency.accept($0)
            }
        )
        
        
        return NavigationView {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        //User Balance
                        MyBalanceView(header: {
                            HeaderView(title: Text("My Balance"), detail: Text("Current remaining balance."))
                        }, balance: {
                            Text("\(self.viewModel.txtBalance)")
                        }, withCurrencies: self.viewModel.currencies,
                        andCurrencyIndexValue: selectedBalance)
                        
                        //User input for currency exchange
                        CurrencyExchangeView(header: {
                            HeaderView(title: Text("Currency Exchange"), detail: nil)
                        }, detail: {
                            CurrencyExchangeInputView(image: Image("imgSell"), title: Text("Sell"), withCurrencies: self.viewModel.currencies, withValue: self.$viewModel.txtSellInput, andCurrencyIndexValue: currencyInput)
                            CurrencyExchangeInputView(image: Image("imgReceive"), title: Text("Buy"), withCurrencies: self.viewModel.currencies, withValue: self.$viewModel.txtSellOutput, andCurrencyIndexValue: currencyOutput, disableInput: true)
                        }).alert(isPresented: self.$showErrorAlert.0, content: {
                            return Alert(title: Text("Ooops"), message: Text(self.showErrorAlert.1 ?? "An unexpected error occurred."), dismissButton: .default(Text("OK")))
                        })
                        
                        
                        //History View
                        HistoryView(header: {
                            HeaderView(title: Text("History"), detail: Text("Your balances."))
                        }, withItems: history)
                        
                        //Submit button
                        Button(action: {
                            self.viewModel.submit.onNext(())
                        }) {
                            Text("Submit")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(40)
                        .padding()
                        .alert(isPresented: self.$viewModel.showConversion) { () -> Alert in
                            return Alert(title: Text("Currency converted"), message: Text(viewModel.outputMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        
                    }.padding()
                }
                            
                //HUD loader
                ActivityIndicatorView(isVisible: $viewModel.isLoading, type: .default)
                    .frame(width: 50.0, height: 50.0)
            
                
            }.navigationBarTitle("Currency Converter")

        }.onAppear(perform: self.setup)
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    private func setup() {
        viewModel.didTapSubmit
            .flatMapLatest({ (_) -> Observable<Result<AccountBalance?, TransactionValidationError>> in
                return self.viewModel.convertCurrency()
            })
            .asDriver(onErrorJustReturn: .failure(.unknown))
            .drive(onNext: { result in
                switch result {
                case .failure(.unknown):
                    self.showErrorAlert = (true, "Unknown error occurred")
                case .failure(.cannotBeZero):
                    self.showErrorAlert = (true, "Current balance cannot be zero")
                case .failure(.inputLower):
                    self.showErrorAlert = (true, "Sell order is high than your current balance.")
                case .failure(.incompleteDetails):
                    self.showErrorAlert = (true, "Please fill all required details")
                default:
                    break
                }
            }).disposed(by: disposeBag)

    }
}

extension HomeContentView {
    public init(model: HomeViewModel,historyItems: Binding<[HistoryViewItem]> = .constant([]),currencyOutputIndex: Binding<Int> = .constant(0)) {
        self.viewModel = model
        self._historyItems = historyItems
        self._selectedCurrencyOutput = currencyOutputIndex
        self._selectedBalanceCurrency = .constant(0)
        self._selectedCurrencyInput = .constant(0)
    }
}

#if DEBUG
struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView(model: HomeViewModel())
    }
}
#endif
