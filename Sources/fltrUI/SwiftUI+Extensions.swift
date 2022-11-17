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

public extension ColorScheme {
    var isDark: Bool {
        switch self {
        case .dark:
            return true
        case .light:
            return false
        @unknown default:
            preconditionFailure()
        }
    }
    
    var isLight: Bool {
        !self.isDark
    }
}
