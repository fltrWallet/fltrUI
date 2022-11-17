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
import SwiftUI

struct RectOfInterestModifier: ViewModifier {
    var model: CaptureModel
    var rect: CGRect
    
    func body(content: Content) -> some View {
        content
        .onAppear {
            model.scanBox = rect
        }
        .onChange(of: rect) { value in
            model.scanBox = value
        }
    }
}

extension View {
    func rectOfInterest(_ model: CaptureModel, _ rect: CGRect) -> some View {
        return self.modifier(RectOfInterestModifier(model: model, rect: rect))
    }
}
#endif
