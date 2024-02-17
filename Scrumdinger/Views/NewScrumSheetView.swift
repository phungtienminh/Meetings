//
//  NewScrumSheetView.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 04/02/2024.
//

import SwiftUI

struct NewScrumSheetView: View {
    @State private var newScrum: DailyScrum = DailyScrum.emptyScrum
    @Binding var scrums: [DailyScrum]
    @Binding var isPresentingNewScrumView: Bool
    
    var body: some View {
        NavigationStack {
            DetailEditView(scrum: $newScrum)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Dismiss") {
                            isPresentingNewScrumView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            scrums.append(newScrum)
                            isPresentingNewScrumView = false
                        }
                    }
                }
        }
    }
}

#Preview {
    NewScrumSheetView(scrums: .constant(DailyScrum.sampleData), isPresentingNewScrumView: .constant(true))
}
