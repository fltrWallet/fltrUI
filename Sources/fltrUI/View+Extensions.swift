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
import struct Orientation.OrientationOffsetModifier
import struct Orientation.OrientationPaddingModifier
import SwiftUI

public extension View {
    func offset(_ direction: Orientation.Direction) -> some View {
        return self.modifier(OrientationOffsetModifier(direction: direction, amount: direction.amount))
    }
}

public extension View {
    func padding(_ edge: Orientation.Edge, _ amount: CGFloat? = nil) -> some View {
        self.modifier(OrientationPaddingModifier(edge, amount))
    }
}
