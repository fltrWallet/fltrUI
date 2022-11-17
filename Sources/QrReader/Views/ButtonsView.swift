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

struct ButtonsView: View {
    @ObservedObject var model: CaptureModel
    @EnvironmentObject var orientation: Orientation.Model
    
    @ScaledMetric var spacing: CGFloat = 40
    
    var body: some View {
        VStack(alignment: .center) {
            Text("Scan QR code to start a payment")
                .fontWeight(.thin)
                .foregroundColor(.white)
                .padding()
                .padding(.top, 30)
            
            Spacer(minLength: spacing)
            
            HStack {
                Button { // MARK: Torch
                    self.model.torchEnabled.toggle()
                }
                label: {
                    Image(systemName: model.torchEnabled
                            ? "flashlight.on.fill"
                            : "flashlight.off.fill")
                }
                .accentColor(Color(red: 1, green: 255/255, blue: 137/255).opacity(0.8))
                .buttonStyle(FlashLensButtonStyle(enabled: $model.torchEnabled))
                .opacity(self.model.hasTorch ? 1 : 0)
                .padding(.horizontal, 10)
                
                if model.enableSwitchCamera
                    || orientation.isHorizontal {
                    Button { // MARK: Switch Lens
                        self.model.switchLens()
                    }
                    label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                        .font(.system(size: 30, weight: .ultraLight, design: .default))
                    }
                    .accentColor(.white)
                    .buttonStyle(FlashLensButtonStyle(enabled: .constant(true)))
                    .padding(.horizontal, 10)
                }
            }
            
            Spacer()
            Spacer()

            Button("Close") { // MARK: Close
                model.dismiss = true
            }
            .buttonStyle(CloseButtonStyle())
            .accentColor(.white)
            .scaleEffect(1.3)
            .padding(.bottom, 30)

            Spacer()
        }
        .padding(.horizontal, 30)
    }
}
#endif
