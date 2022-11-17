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
import Combine
import SwiftUI

#if !os(macOS)
public extension Orientation {
    final class Model: ObservableObject {
        @Published private(set) var _assignOrientationLeftRight: OrientationLeftRight
            = OrientationLeftRight(DefaultOrientation, DefaultLeftRight)
        
        @Published var horizontal: UserInterfaceSizeClass = .regular
        @Published var vertical: UserInterfaceSizeClass = .regular
        @Published public internal(set) var size: (width: CGFloat, height: CGFloat) = (.zero, .zero)
        @Published public internal(set) var safeSize: (width: CGFloat, height: CGFloat) = (.zero, .zero)

        var orientationCancellable: AnyCancellable?
        
        init() {
            orientationCancellable = orientationPublisher()
            .assign(to: \._assignOrientationLeftRight, on: self)
        }
    }
}

#else
public extension Orientation {
    final class Model: ObservableObject {
        public internal(set) var orientation: Orientation = .horizontal
        public internal(set) var leftRight: Orientation.LeftRight = .left
        
        @Published public internal(set) var size: (lat: CGFloat, long: CGFloat) = (.zero, .zero)
        @Published public internal(set) var safeSize: (lat: CGFloat, long: CGFloat) = (.zero, .zero)
    }
}

public struct OrientationView<Content: View>: View {
    var content: () -> Content
    
    public var body: some View {
        content()
        .environmentObject(Orientation.Model())
    }
}
#endif
