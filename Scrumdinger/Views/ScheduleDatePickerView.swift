//
//  ScheduleDatePickerView.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 13/02/2024.
//

import SwiftUI

struct ScheduleDatePickerView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        DatePicker(selection: $selectedDate, in: Date()...) {
            Text("Select date and time")
        }
    }
}

#Preview {
    ScheduleDatePickerView(selectedDate: .constant(Date()))
}
