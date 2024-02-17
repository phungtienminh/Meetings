//
//  ThemeView.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 01/02/2024.
//

import SwiftUI

struct ThemeView: View {
    let theme: Theme
    
    var body: some View {
        Text(theme.name)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(4)
            .background(theme.mainColor)
            .foregroundColor(theme.accentColor)
    }
}

#Preview {
    ThemeView(theme: .buttercup)
}
