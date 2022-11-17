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

public struct OrientationPaddingModifier: ViewModifier {

    let edge: Orientation.Edge
    let amount: CGFloat?
    
    @EnvironmentObject var model: Orientation.Model
    
    public init(_ edge: Orientation.Edge, _ amount: CGFloat?) {
        self.edge = edge
        self.amount = amount
    }
    
    public func body(content: Content) -> some View {
        if let amount = amount {
            return content.padding(
                edge.orient(model.orientation, model.leftRight),
                amount
            )
        } else {
            return content.padding(edge.orient(model.orientation, model.leftRight))
        }
    }
}

