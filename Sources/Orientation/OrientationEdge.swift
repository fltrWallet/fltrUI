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

public extension Orientation {
    enum Edge {
        case latBefore
        case latAfter
        case latBeforeAfter
        case longBefore
        case longAfter
        case longBeforeAfter
        
        func orient(_ orientation: Orientation, _ leftRight: Orientation.LeftRight) -> SwiftUI.Edge.Set {
            switch (orientation, self) {
            case (.horizontal, .latAfter):
                return leftRight.isRight ? .bottom : .top
            case (.horizontal, .latBefore):
                return leftRight.isRight ? .top : .bottom
            case (.horizontal, .latBeforeAfter):
                return .vertical
            case (.horizontal, .longAfter):
                return leftRight.isRight ? .leading : .trailing
            case (.horizontal, .longBefore):
                return leftRight.isRight ? .trailing : .leading
            case (.horizontal, .longBeforeAfter):
                return .horizontal
            case (.vertical, .latAfter):
                return .trailing
            case (.vertical, .latBefore):
                return .leading
            case (.vertical, .latBeforeAfter):
                return .horizontal
            case (.vertical, .longAfter):
                return .bottom
            case (.vertical, .longBefore):
                return .top
            case (.vertical, .longBeforeAfter):
                return .vertical
            }
        }
    }
}
