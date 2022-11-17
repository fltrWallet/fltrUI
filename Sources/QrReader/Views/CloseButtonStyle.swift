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

struct CloseButtonStyle: ButtonStyle {
    @ScaledMetric var lineWidthThin: CGFloat = 0.9
    @ScaledMetric var cornerRadius = 34 as CGFloat
    @ScaledMetric var padding = 20 as CGFloat
    
    @ScaledMetric(relativeTo: .title3) var fontSize = 22 as CGFloat
    
    @Environment(\.isEnabled) var isEnabled
    
    var backgroundColor = Color.gray
    
    func makeBody(configuration: Configuration) -> some View {
        func colorWhenPressed() -> Color {
            configuration.isPressed
                ? backgroundColor.opacity(0.3)
                : Color.clear
        }

        let roundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
        
        return configuration.label
            .foregroundColor(.accentColor)
            .font(.system(size: fontSize, weight: .light, design: .rounded))
            .padding(.horizontal, cornerRadius)
            .padding(padding)
            .background(
                ZStack {
                    roundedRectangle
                        .fill(Color.black.opacity(0.15))
                    roundedRectangle
                        .strokeBorder(Color.white, lineWidth: lineWidthThin)
                }
            )
            .contentShape(
                roundedRectangle
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .background(
                roundedRectangle
                    .fill()
                    .foregroundColor(colorWhenPressed())
            )
    }
}
