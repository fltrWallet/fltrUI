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
import CoreHaptics

public final class Haptics: ObservableObject {
    let engine: CHHapticEngine
    let successPlayer: CHHapticPatternPlayer
    let failurePlayer: CHHapticPatternPlayer

    static let _success: [CHHapticEventParameter] = [ .init(parameterID: .hapticIntensity, value: 1),
                                                      .init(parameterID: .hapticSharpness, value: 1) ]
    static let _failure: [CHHapticEventParameter] = [ .init(parameterID: .hapticIntensity, value: 0.4),
                                                      .init(parameterID: .hapticSharpness, value: 0.1) ]
    
    static func makePlayer(for params: [CHHapticEventParameter],
                           duration: TimeInterval? = nil,
                           engine: CHHapticEngine) -> CHHapticPatternPlayer? {
        let event: CHHapticEvent = {
            if let duration = duration {
                return CHHapticEvent(eventType: .hapticContinuous, parameters: params, relativeTime: 0, duration: duration)
            } else {
                return CHHapticEvent(eventType: .hapticTransient, parameters: params, relativeTime: 0)
            }
        }()
        let pattern = try? CHHapticPattern(events: [event], parameters: [])
        return pattern
        .flatMap { pattern in
            try? engine.makePlayer(with: pattern)
        }
    }
    
    public init?() {
        if let engine = try? CHHapticEngine(),
           CHHapticEngine.capabilitiesForHardware().supportsHaptics,
           let _ = try? engine.start(),
           let successPlayer = Self.makePlayer(for: Self._success, engine: engine),
           let failurePlayer = Self.makePlayer(for: Self._failure, duration: 0.4, engine: engine) {
            self.engine = engine
            self.successPlayer = successPlayer
            self.failurePlayer = failurePlayer
        } else {
            return nil
        }
    }
    
    public func success() {
        try? self.successPlayer.start(atTime: 0)
    }
    
    public func failure() {
        try? self.failurePlayer.start(atTime: 0)
    }
}

