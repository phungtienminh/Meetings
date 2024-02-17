//
//  DetailView.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 31/01/2024.
//

import SwiftUI
import UserNotifications


struct DetailView: View {
    @Binding var scrum: DailyScrum
    
    @State private var editingScrum: DailyScrum = DailyScrum.emptyScrum
    @State private var isPresentingEditView: Bool = false
    
    @State private var isPresentingSchedulingView: Bool = false
    @State private var selectedDate: Date = Date()
    
    func requestNotificationAuthorization(completionHandler: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
            } else if granted {
                print("Access granted!")
                completionHandler()
            } else {
                print("Access denied!")
            }
        }
    }
    
    func scheduleNotification() {
        // Remove all current active notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        // Step 1: Create Notification payload
        // Structure: Title, body, sound
        let payload: UNMutableNotificationContent = UNMutableNotificationContent()
        payload.title = "Meeting Reminder"
        payload.body = "The meeting will start in 1 hour."
        payload.sound = UNNotificationSound.default
        
        // Step 2: Create Trigger object
        // Structure: Date component, repeats(Bool)
        let triggerDate: Date = Calendar.current.date(byAdding: .hour, value: -1, to: selectedDate)!
        let triggerDateComponents: DateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let triggerObject: UNNotificationTrigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        // Step 3: Create notification Request
        // Structure: ID, Content, Trigger
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: payload, trigger: triggerObject)
        
        // Step 4: Send Request object to Notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Some error occurred: \(error.localizedDescription)")
            } else {
                print("Scheduled successfully!")
            }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("Meeting Info")) {
                NavigationLink(destination: MeetingView(scrum: $scrum)) {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text("\(scrum.lengthInMinutes) minutes")
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text("\(scrum.theme.name)")
                        .padding(4)
                        .cornerRadius(4)
                        .foregroundColor(scrum.theme.accentColor)
                        .background(scrum.theme.mainColor)
                }
                .accessibilityElement(children: .combine)
            }
            Section(header: Text("Attendees")) {
                ForEach(scrum.attendees) { (attendee: DailyScrum.Attendee) in
                    Label(attendee.name, systemImage: "person")
                }
            }
            Section(header: Text("History")) {
                if scrum.history.isEmpty {
                    Label("No meetings yet", systemImage: "calendar.badge.exclamationmark")
                }
            
                ForEach(scrum.history) { history in
                    NavigationLink(destination: HistoryView(history: history)) {
                        HStack {
                            Image(systemName: "calendar")
                            Text(history.date, style: .date)
                        }
                    }
                }
            }
            Section(header: Text("Schedule")) {
                if let scheduledDate = scrum.scheduledDate {
                    HStack {
                        Image(systemName: "calendar")
                        Text(scheduledDate, style: .timer)
                        Spacer()
                        Button(action: {
                            scrum.scheduledDate = nil
                            
                            // Remove all current active scheduled notifications when tapping the cross
                            // to remove this scheduled notification.
                            // At most 1 active scheduled notification for a scrum meeting.
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            
                            UNUserNotificationCenter.current().getPendingNotificationRequests() { requests in
                                print(requests.count)
                            }
                        }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.red)
                        }
                    }
                } else {
                    Label("No schedule", systemImage: "calendar.badge.exclamationmark")
                    HStack {
                        Spacer()
                        Button("Schedule Scrum") {
                            isPresentingSchedulingView.toggle()
                        }
                        .buttonStyle(.borderedProminent)
                        .sheet(isPresented: $isPresentingSchedulingView) {
                            NavigationView {
                                ScheduleDatePickerView(selectedDate: $selectedDate)
                                    .toolbar {
                                        ToolbarItem(placement: .cancellationAction) {
                                            Button("Dismiss") {
                                                isPresentingSchedulingView.toggle()
                                            }
                                        }
                                        ToolbarItem(placement: .confirmationAction) {
                                            Button("Done") {
                                                requestNotificationAuthorization(completionHandler: scheduleNotification)
                                                // scheduleNotification()
                                                scrum.scheduledDate = selectedDate
                                                isPresentingSchedulingView.toggle()
                                            }
                                        }
                                    }
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(scrum.title)
        .toolbar {
            Button(action: {
                isPresentingEditView = true
                editingScrum = scrum
            }) {
                Text("Edit")
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                DetailEditView(scrum: $editingScrum)
                    .navigationTitle(scrum.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: {
                                isPresentingEditView = false
                            }) {
                                Text("Cancel")
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                isPresentingEditView = false
                                scrum = editingScrum
                            }) {
                                Text("Done")
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(scrum: .constant(DailyScrum.sampleData[1]))
    }
}
