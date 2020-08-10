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
import SwiftyHUDView

struct HomeContentView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding private var historyItems: [HistoryViewItem]
    @Binding private var selectedCurrencyOutput: Int
    
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
        
        let currencyOutput = Binding<Int>(
            get: {
                self.viewModel.selectedCurrencyOutput.value
            },
            set: {
                self.selectedCurrencyOutput = $0
                self.viewModel.selectedCurrencyOutput.accept($0)
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
                            Text("\(self.viewModel.txtBalance) EUR")
                        })
                        
                        //User input for currency exchange
                        CurrencyExchangeView(header: {
                            HeaderView(title: Text("Currency Exchange"), detail: nil)
                        }, detail: {
                            CurrencyExchangeInputView(image: Image("imgSell"), title: Text("Sell"), withCurrencies: self.viewModel.currencies, withValue: self.$viewModel.txtSellInput, andCurrencyIndexValue: self.$viewModel.selectedCurrencyInput)
                            CurrencyExchangeInputView(image: Image("imgReceive"), title: Text("Buy"), withCurrencies: self.viewModel.currencies, withValue: self.$viewModel.txtSellOutput, andCurrencyIndexValue: currencyOutput, disableInput: true)
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
                .navigationBarTitle("Currency Converter")
                
                //HUD loader
                SwiftyHUDView(isShowing: $viewModel.isLoading) {
                     EmptyView()
                }
            }
            
        }.onAppear(perform: self.setup)
        
    }
    
    private func setup() {
        viewModel.loadData()
        
        viewModel.didTapSubmit
            .flatMapLatest({ (_) -> Observable<Void> in
    
                return self.viewModel.convertCurrency()
            })
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { (_) in
                
            })
            .disposed(by: disposeBag)
    }
}

extension HomeContentView {
    public init(model: HomeViewModel,historyItems: Binding<[HistoryViewItem]> = .constant([]),currencyOutputIndex: Binding<Int> = .constant(0)) {
        self.viewModel = model
        self._historyItems = historyItems
        self._selectedCurrencyOutput = currencyOutputIndex
    }
}

#if DEBUG
struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView(model: HomeViewModel(withCurrentBalance: Decimal(integerLiteral: 1000)))
    }
}
#endif
