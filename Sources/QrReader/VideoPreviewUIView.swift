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
import UIKit

class VideoPreviewUIView: UIView {
    typealias RectOfInterestCallback = (CGRect) -> Void
    var rectOfInterest: (CGRect, RectOfInterestCallback)?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
        }
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func updateState() {
        setOrientation(on: self)
        if let (rectOfInterest, callback) = self.rectOfInterest {
            let transformed = self.videoPreviewLayer
                .metadataOutputRectConverted(fromLayerRect: rectOfInterest)
            callback(transformed)
        }
    }
}
#endif
