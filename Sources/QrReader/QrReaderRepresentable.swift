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
import AVFoundation
import SwiftUI

struct QrReaderRepresentable<T: Equatable>: UIViewRepresentable {
    @ObservedObject var model: CaptureModel
    @Binding var match: T?
    var matchFunction: (String) -> T?
    var onDismiss: (() -> Void)? = nil

    func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
        context.coordinator.copyRectOfInterest(uiView)

        uiView.updateState()
        
        // Stop
        if match != nil
            || model.dismiss {
            context.coordinator.stop(uiView) 
        }
        
        let model = context.coordinator.parent.model
        
        // Switch camera requested
        if model.canSwitchCamera,
           model.requestedLens != model.selectedLens {
            context.coordinator.switchCamera(uiView)
        }
        
        // Enabled/Disable torch
        context.coordinator.setTorch(uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> VideoPreviewUIView {
        let previewView = VideoPreviewUIView()
        let session = AVCaptureSession()
        previewView.session = session
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        context.coordinator.start(previewView, model: self.model)
        
        return previewView
    }

    static func dismantleUIView(_ uiView: VideoPreviewUIView, coordinator: Coordinator) {
        uiView.rectOfInterest = nil
        uiView.session = nil
    }
    
    func changeState(state new: @escaping (inout CaptureState, CaptureModel) -> Void) {
        DispatchQueue.main.async {
            new(&model.state, model)
        }
    }
}
#endif
