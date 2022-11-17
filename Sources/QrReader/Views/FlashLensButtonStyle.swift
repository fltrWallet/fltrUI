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

struct FlashLensButtonStyle: ButtonStyle {
    @Binding var enabled: Bool

    var bgOpacity: Double = 0.25
    @ScaledMetric var fontSize: CGFloat = 30
    @ScaledMetric var lineWidth: CGFloat = 0.9
    @ScaledMetric var frame: CGFloat = 40
    @ScaledMetric var padding: CGFloat = 20

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(size: fontSize, weight: enabled
                            ? .semibold
                            : .ultraLight,
                          design: .default))
            .foregroundColor(enabled ? .accentColor : .gray)
            .frame(width: frame, height: frame)
            .padding(padding)
            .background(
                Circle()
                    .fill(Color.black.opacity(bgOpacity))
            )
            .background(
                Circle()
                    .strokeBorder(Color.white, lineWidth: lineWidth)
                
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
