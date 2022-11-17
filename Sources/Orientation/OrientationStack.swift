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
import SwiftUI

internal protocol OrientationStack: View {
    associatedtype C1: View
    associatedtype C2: View
    associatedtype C3: View
    associatedtype C4: View
    associatedtype C5: View
    
    var direction: Orientation.Direction { get }
    var alignment: Orientation.Alignment { get }
    var spacing: CGFloat? { get }
    
    var namespace: Namespace.ID { get }
    
    var c1: () -> C1 { get }
    var c2: (() -> C2)? { get }
    var c3: (() -> C3)? { get }
    var c4: (() -> C4)? { get }
    var c5: (() -> C5)? { get }
    
    func stack(from: Orientation.Model) -> AnyView
}

extension OrientationStack {
    func stack(from model: Orientation.Model) -> AnyView {
        let stackAlign = alignment.stackAlign(direction: direction,
                                              orientation: model.orientation,
                                              leftRight: model.leftRight)
        switch stackAlign {
        case .horizontal(let hA):
            return AnyView(erasing:
                            VStack(alignment: hA, spacing: spacing) {
                                c1()
                                c2?()
                                c3?()
                                c4?()
                                c5?()
                            }
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "\(self)", in: namespace)
                            .animation(.default)
            )
        case .inverted(.vertical(let vA)):
            return AnyView(erasing:
                            HStack(alignment: vA, spacing: spacing) {
                                c5?()
                                c4?()
                                c3?()
                                c2?()
                                c1()
                            }
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "\(self)", in: namespace)
                            .animation(.default)
            )
        case .inverted(.horizontal(let hA)):
            return AnyView(erasing:
                            VStack(alignment: hA, spacing: spacing) {
                                c5?()
                                c4?()
                                c3?()
                                c2?()
                                c1()
                            }
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "\(self)", in: namespace)
                            .animation(.default)
            )
            
        case .inverted(.inverted):
            preconditionFailure()
            
            
        case .vertical(let vA):
            return AnyView(erasing:
                            HStack(alignment: vA, spacing: spacing) {
                                c1()
                                c2?()
                                c3?()
                                c4?()
                                c5?()
                            }
                            .transition(.opacity)
                            .matchedGeometryEffect(id: "\(self)", in: namespace)
                            .animation(.default)
            )
        }
    }
}
