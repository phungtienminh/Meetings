//
//  AVPlayerDing.swift
//  Scrumdinger
//
//  Created by Swiftaholic on 04/02/2024.
//

import Foundation
import AVFoundation

extension AVPlayer {
    static let sharedDingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else { fatalError("Sound file not found.") }
        return AVPlayer(url: url)
    }()
}




