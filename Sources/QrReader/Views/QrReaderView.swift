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

public typealias QrStringReaderView = QrReaderView<String>
public extension QrStringReaderView {
    init(match: Binding<String?>, onDismiss: (() -> Void)? = nil) {
        self.init(match: match,
                  matchFunction: { .some($0) },
                  onDismiss: onDismiss)
    }
}

public struct QrReaderView<T: Equatable>: View {
    @StateObject var model = CaptureModel()
    @State private var lastRect: Path = Rectangle().path(in: .zero)
    @Binding var match: T?

    var matchFunction: (String) -> T?
    var onDismiss: (() -> Void)?

    @Environment(\.openURL) var openURL

    @EnvironmentObject var orientation: Orientation.Model
    
    @ScaledMetric var spacing: CGFloat = 40

    
    public init(match: Binding<T?>,
                matchFunction: @escaping (String) -> T?,
                onDismiss: (() -> Void)? = nil) {
        self._match = match
        self.matchFunction = matchFunction
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.black
            
            QrReaderRepresentable<T>(model: model,
                                     match: $match,
                                     matchFunction: matchFunction,
                                     onDismiss: onDismiss)

            Color.black
                .mask(
                    ZStack {
                        Color.black
                        Color.white
                            .opacity(0.2)
                        RoundedRectangle(cornerRadius: 30).path(in: model.scanBox ?? .zero)
                            .fill(Color.black)
                        RoundedRectangle(cornerRadius: 30).path(in: model.scanBox ?? .zero)
                            .strokedPath(.init(lineWidth: 0.9))
                            .foregroundColor(Color.white.opacity(0.3))
                    }
                    .compositingGroup()
                    .luminanceToAlpha()
                )
            

            LongStack(spacing: 0) {
                Rectangle()
                    .foregroundColor(.clear)
                .background(GeometryReader { proxy in
                    Color.clear
                        .rectOfInterest(model, proxy.frame(in: .global))

                })
                .padding(20)
            }
            c2: {
                Spacer(minLength: 0)
            }
            c3: {
                ButtonsView(model: model)
            }
            c4: {
                Spacer(minLength: 0)
            }
            .modifier(OrientationPaddingModifier(.longBefore, 25))
            .modifier(OrientationPaddingModifier(.longAfter, 40))

            
            lastRect
            .stroke(match == nil
                        ? Color.red.opacity(0.6)
                        : Color.white.opacity(0.8),
                    lineWidth: 10)
            .background(match == nil
                            ? nil
                            : lastRect.fill(Color.white.opacity(0.3)))
            .opacity(model.candidateFoundBox == nil ? 0 : 1)
        }
        .alert(item: $model.error) { error in
            if error == .configurationFailed {
                return Alert(title: Text("Configuration Error"),
                             message: Text("An unexpected error occurred when starting the camera.\n"
                                           + "Scanning of QR codes cannot proceed."),
                             dismissButton: .cancel() {
                                model.dismiss = true
                             })

            } else if error == .notAuthorized {
                return Alert(title: Text("Not Authorized"),
                             message: Text("Camera has been disabled in Settings.\n"
                                           + "To perform QR scanning, please enable the camera."),
                             primaryButton: .cancel() {
                                model.dismiss = true
                             },
                             secondaryButton: .default(Text("Settings")) {
                                guard let url = URL(string: UIApplication.openSettingsURLString)
                                else { return }
                                
                                model.dismiss = true
                                openURL(url)
                             })
            } else {
                preconditionFailure()
            }
        }

        .onAppear {
            match = nil
        }
        .onReceive(model.$candidateFoundBox.compactMap({$0})) { value in
            lastRect = Rectangle().path(in: value)
        }
        .onReceive(model.newRectDelay) { value in
            withAnimation(.easeInOut(duration: 0.2)) {
                if let _ = model.candidateFoundBox {
                    model.candidateFoundBox = nil
                }
            }
        }
//        .onChange(of: match) {
//            guard let _ = $0
//            else { return }
//
//            // TODO: Change to model finished, expect new fullCoverSheet
//            model.matchComplete = true
//        }
        .ignoresSafeArea()
    }
}
#endif
