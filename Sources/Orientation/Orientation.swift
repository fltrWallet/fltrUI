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

public enum Orientation: String, Hashable, Identifiable {
    case horizontal
    case vertical
    
    public var id: String { self.rawValue }

    var isHorizontal: Bool {
        switch self {
        case .horizontal: return true
        case .vertical: return false
        }
    }
    
    var isVertical: Bool {
        !self.isHorizontal
    }
}

extension Orientation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .horizontal: return ".horizontal"
        case .vertical: return ".vertical"
        }
    }
}


