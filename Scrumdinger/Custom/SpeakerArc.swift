//
//  SpeakerArc.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 06/02/2024.
//

import SwiftUI

struct SpeakerArc: Shape {
    let speakerIndex: Int
    let totalSpeakers: Int
    
    private var degreesPerSpeaker: Double {
        360.0 / Double(totalSpeakers)
    }
    
    private var startAngle: Angle {
        Angle(degrees: Double(speakerIndex) * degreesPerSpeaker + 1.0)
    }
    
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1)
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter: CGFloat = min(rect.size.width, rect.size.height) - 24.0
        let radius: CGFloat = diameter / 2.0
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
    
    
}
