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
#if canImport(AVFoundation) && canImport(UIKit)
import Orientation
import SwiftUI

struct MaskView: View {
    @ObservedObject var model: CaptureModel
    @EnvironmentObject var orientation: Orientation.Model
    
    var body: some View {
        ZStack {
            Color.white
                
            Color.black
                .opacity(0.2)

            LongStack(spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white)
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(Color.black.opacity(0.28), lineWidth: 0.9)
                }
                .background(GeometryReader { proxy in
                    Color.clear
                        .rectOfInterest(model, proxy.frame(in: .global))

                })
                .modifier(OrientationPaddingModifier(.longBefore, 20))
                .padding(5)
            }
            c2: {
                Spacer(minLength: 0)
            }
        }
        .compositingGroup()
        .luminanceToAlpha()
    }
}
#endif
