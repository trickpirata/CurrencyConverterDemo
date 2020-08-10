//
//  ContentView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

public struct ContentView<Content: View>: View {
    
    private let content: Content
    
    private var stackedContent: some View {
        VStack { content }
    }
    
    @ViewBuilder public var body: some View {
        stackedContent
            .modifier(ContentModifier())
    }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

private struct ContentModifier: ViewModifier {
    
    private var contentShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .clipShape(contentShape)
            .background(
                contentShape
                    .foregroundColor(Color(UIColor.secondarySystemGroupedBackground))
                    .shadow(color: Color(hue: 0, saturation: 0, brightness: 0, opacity: Double(0.15)),
                            radius: 8,
                            x: 0,
                            y: 2)
            )
            
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView {
            Group {
                Text("I")
                Text("Am")
                Text("Vertical")
            }.padding()
            
        }
    }
}
#endif
