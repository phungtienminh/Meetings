//
//  CustomProgressViewStyle.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 03/02/2024.
//

import SwiftUI

struct CustomProgressViewStyle: ProgressViewStyle {
    let theme: Theme
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.accentColor)
                .frame(height: 20)
            
            if #available(iOS 15.0, *) {
                ProgressView(configuration)
                    .tint(theme.mainColor)
                    .frame(height: 12)
                    .padding(.horizontal)
            } else {
                ProgressView(configuration)
                    .frame(height: 12)
                    .padding(.horizontal)
            }
        }
    }
}
