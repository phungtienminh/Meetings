//
//  ScrumTimer.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 03/02/2024.
//

import Foundation

@MainActor
final class ScrumTimer: ObservableObject {
    // A struct to keep track of meeting attendees during a meeting.
    struct Speaker: Identifiable {
        let id: UUID = UUID()
        let name: String
        
        // if the attendee has completed their turn to speak.
        var isCompleted: Bool
    }
    
    // The name of the meeting attendee who is speaking.
    @Published var activeSpeaker: String = ""
    
    @Published var secondsElapsed: Int = 0
    @Published var secondsRemaining: Int = 0
    
    // All meeting attendees, listed in order of their speeches.
    private(set) var speakers: [Speaker] = []
    
    // Meeting length.
    private(set) var lengthInMinutes: Int
    
    // A closure that is executed when a new attendee begins speaking.
    var speakerChangedAction: (() -> Void)?
    
    private weak var timer: Timer?
    private var timerStopped: Bool = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int { lengthInSeconds / speakers.count }
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1): \(speakers[speakerIndex].name)"
    }
    private var startDate: Date?
    
    init(lengthInMinutes: Int = 0, attendees: [DailyScrum.Attendee] = []) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    
    // Start the timer.
    func startScrum() {
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            self?.update()
        }
        
        timer?.tolerance = 0.1
        changeToSpeaker(at: 0)
    }
    
    // Stop the timer.
    func stopScrum() {
        timer?.invalidate()
        timerStopped = true
    }
    
    // Advance the timer to the next speaker.
    nonisolated func skipSpeaker() {
        Task { @MainActor in
            changeToSpeaker(at: speakerIndex + 1)
            if let speakerChangedAction = speakerChangedAction {
                speakerChangedAction()
            }
        }
    }
    
    private func changeToSpeaker(at index: Int) {
        if index > 0 {
            let previousSpeakerIndex = index - 1
            speakers[previousSpeakerIndex].isCompleted = true
        }
        
        secondsElapsedForSpeaker = 0
        guard index < speakers.count else { return }
        
        speakerIndex = index
        activeSpeaker = speakerText
        
        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
    }
    
    nonisolated private func update() {
        Task { @MainActor in
            guard let startDate, !timerStopped else { return }
            
            let secondsElapsed = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
            secondsElapsedForSpeaker = secondsElapsed
            self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
            
            guard secondsElapsed <= secondsPerSpeaker else { return }
            
            secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)
            if secondsRemaining <= 0 {
                stopScrum()
                return
            }
            
            if secondsElapsedForSpeaker >= secondsPerSpeaker {
                changeToSpeaker(at: speakerIndex + 1)
                speakerChangedAction?()
            }
        }
    }
    
    // Reset the timer with a new meeting length and new attendees.
    func reset(lengthInMinutes: Int, attendees: [DailyScrum.Attendee]) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.speakers
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
}

extension Array<DailyScrum.Attendee> {
    var speakers: [ScrumTimer.Speaker] {
        if isEmpty {
            return [ScrumTimer.Speaker(name: "Speaker 1", isCompleted: false)]
        } else {
            return map { ScrumTimer.Speaker(name: $0.name, isCompleted: false) }
        }
    }
}
