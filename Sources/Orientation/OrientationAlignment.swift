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

extension Orientation {
    internal enum AlignmentResult {
        indirect case inverted(AlignmentResult)
        case horizontal(HorizontalAlignment)
        case vertical(VerticalAlignment)
    }

    public enum Alignment {
        case before
        case after
        case center
        
        func stackAlign(direction: Direction,
                        orientation: Orientation,
                        leftRight: Orientation.LeftRight) -> AlignmentResult {
            switch (direction, orientation, self) {
            case (.longitude, .horizontal, .after):
                return leftRight.isRight ? .inverted(.vertical(.bottom)) : .vertical(.top)
            case (.longitude, .horizontal, .before):
                return leftRight.isRight ? .inverted(.vertical(.top)) : .vertical(.bottom)
            case (.longitude, .horizontal, .center):
                return leftRight.isRight ? .inverted(.vertical(.center)) : .vertical(.center)
            case (.longitude, .vertical, .after):
                return .horizontal(.trailing)
            case (.longitude, .vertical, .before):
                return .horizontal(.leading)
            case (.longitude, .vertical, .center):
                return .horizontal(.center)
                
            case (.latitude, .horizontal, .after):
                return leftRight.isLeft ? .inverted(.horizontal(.leading)) : .horizontal(.trailing)
            case (.latitude, .horizontal, .before):
                return leftRight.isLeft ? .inverted(.horizontal(.trailing)) : .horizontal(.leading)
            case (.latitude, .horizontal, .center):
                return leftRight.isLeft ? .inverted(.horizontal(.center)) : .horizontal(.center)
            case (.latitude, .vertical, .after):
                return .vertical(.bottom)
            case (.latitude, .vertical, .before):
                return .vertical(.top)
            case (.latitude, .vertical, .center):
                return .vertical(.center)
            }
        }
    }
}
