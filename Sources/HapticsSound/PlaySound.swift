//===----------------------------------------------------------------------===//
//
// This source file is part of the fltrUI open source project
//
// Copyright (c) 2022 fltrWallet AG and the fltrUI project authors
// Licensed under Apache License v2.0
//
// See LICENSE.md for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import AVFoundation

public struct PlaySound {
    let player: AVAudioPlayer
    
    public init?(name: String, extension: AVFileType) {
        guard let ext = `extension`.urlExtension,
              let url = Bundle.main.url(forResource: name, withExtension: ext),
              let player = try? AVAudioPlayer(contentsOf: url, fileTypeHint: `extension`.rawValue)
        else {
            return nil
        }
        
        self.player = player
    }
    
    public func play() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            self.player.play()
        } catch {}
    }
}

public extension AVFileType {
    var urlExtension: String? {
        switch self {
        case .mp3:
            return "mp3"
        case .wav:
            return "wav"
        default:
            return nil
        }
    }
}
