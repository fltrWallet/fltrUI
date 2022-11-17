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

public struct OrientationOffsetModifier: ViewModifier {
    let direction: Orientation.Direction
    let amount: CGFloat
    
    @EnvironmentObject var model: Orientation.Model
    
    public init(direction: Orientation.Direction, amount: CGFloat) {
        self.direction = direction
        self.amount = amount
    }
    
    func offset(orientation: Orientation,
                direction: Orientation.Direction,
                leftRight: Orientation.LeftRight) -> (x: CGFloat, y: CGFloat) {
        let x: CGFloat
        let y: CGFloat
        switch (orientation, direction) {
        case (.horizontal, .latitude):
            x = 0
            y = leftRight.isRight ? direction.amount : -direction.amount
        case (.horizontal, .longitude):
            x = leftRight.isLeft ? direction.amount : -direction.amount
            y = 0
        case (.vertical, .latitude):
            x = direction.amount
            y = 0
        case (.vertical, .longitude):
            x = 0
            y = direction.amount
        }
        
        return (x, y)
    }
    
    public func body(content: Content) -> some View {
        let (x, y) = offset(orientation: model.orientation,
                            direction: direction,
                            leftRight: model.leftRight)
        return content.offset(x: x, y: y)
    }
}

public func toOffset(model: Orientation.Model, direction: Orientation.Direction) -> CGSize {
    let x: CGFloat
    let y: CGFloat
    switch (model.orientation, direction) {
    case (.horizontal, .latitude):
        x = 0
        y = model.isRight ? direction.amount : -direction.amount
    case (.horizontal, .longitude):
        x = model.isLeft ? direction.amount : -direction.amount
        y = 0
    case (.vertical, .latitude):
        x = direction.amount
        y = 0
    case (.vertical, .longitude):
        x = 0
        y = direction.amount
    }
    
    return .init(width: x, height: y)
}
