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
#if canImport(AVFoundation) && canImport(UIKit)
import AVFoundation
import Combine
import Foundation
import SwiftUI

class CaptureModel: ObservableObject {
    @Published var scanBox: CGRect?
    @Published var state: CaptureState = .initialized
    @Published var hasTorch: Bool = false
    @Published var torchEnabled: Bool = false
    @Published var selectedLens: Int = 0
    @Published private(set) var requestedLens: Int = 0
    @Published var canSwitchCamera: Bool = false
    @Published var dismiss: Bool = false
    @Published var candidateFoundBox: CGRect?
    
    @ScaledMetric var maskPadding: CGFloat = 30
    
    var cancellables: Set<AnyCancellable> = .init()
    
    let enableSwitchCamera: Bool = {
        UIDevice.current.userInterfaceIdiom == .pad
    }()
    
    var newRectDelay: AnyPublisher<Void, Never> {
        self.$candidateFoundBox
        .compactMap { _ in () }
        .delay(for: 0.1, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    
    func switchLens() {
        if selectedLens == 0 {
            requestedLens = 1
        } else {
            requestedLens = 0
        }
    }
    
    var error: CaptureError? {
        get {
            self.state.error
        }
        set {
            self.state = .initialized
        }
    }
    
    init() {}
}

// MARK: CaptureState
enum CaptureState {
    case initialized
    case running(SessionConfiguration)
    case error(CaptureError)
    case stopped
    
    var error: CaptureError? {
        switch self {
        case .error(let error): return error
        case .initialized, .running, .stopped: return nil
        }
    }
    
    var inputs: [VideoInput]? {
        switch self {
        case .running(let config): return config.inputs
        case .initialized, .error, .stopped: return nil
        }
    }
    
    var output: AVCaptureMetadataOutput? {
        switch self {
        case .running(let config): return config.output
        case .initialized, .error, .stopped: return nil
        }
    }
    
    var stopped: Bool {
        switch self {
        case .stopped: return true
        case .initialized, .error, .running: return false
        }
    }
}
#endif
