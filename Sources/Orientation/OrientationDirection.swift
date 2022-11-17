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
    enum Direction: CustomStringConvertible {
        case latitude(CGFloat?)
        case longitude(CGFloat?)
        
        public var amount: CGFloat {
            switch self {
            case .latitude(let amount),
                 .longitude(let amount):
                return amount ?? 0
            }
        }
        
        public var description: String {
            switch self {
            case .latitude: return ".latitude(\(self.amount))"
            case .longitude: return ".longitude(\(self.amount))"
            }
        }
        
        public var id: String {
            "\(self)"
        }
        
        public var isLongitude: Bool {
            switch self {
            case .latitude: return false
            case .longitude: return true
            }
        }
        
        public var isLatitude: Bool {
            !self.isLongitude
        }
        
        
        public static var latitude: Self { .latitude(nil) }
        public static var longitude: Self { .longitude(nil) }
    }
    
    enum LeftRight {
        case left
        case right
        
        var isRight: Bool {
            switch self {
            case .left: return false
            case .right: return true
            }
        }
        
        var isLeft: Bool {
            !self.isRight
        }
    }
}
