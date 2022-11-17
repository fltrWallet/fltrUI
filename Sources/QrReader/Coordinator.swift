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
import HapticsSound
import SwiftUI

// MARK: Coordinator + metadataOutput
extension QrReaderRepresentable {
    public class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let haptics: Haptics? = .init()
        let parent: QrReaderRepresentable
        let queue = DispatchQueue(label: "sessionQueue")
        var transformCallback: ((AVMetadataObject) -> CGRect?)?
    
        init(_ parent: QrReaderRepresentable) {
            self.parent = parent
        }

        // Note, only accessed by queue
        private var nextCheck: Date?
        func checkScanState() -> Bool {
            dispatchPrecondition(condition: .onQueue(self.queue))
            
            if let nextCheck = self.nextCheck {
                if Date() > nextCheck {
                    return true
                } else {
                    return false
                }
            } else {
                return true
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {

            guard self.checkScanState(),
                  let metadata = metadataObjects.first,
                  let code = ( metadata as? AVMetadataMachineReadableCodeObject )
                    .flatMap({ $0.stringValue })
            else { return }
                  
            DispatchQueue.main.async {
                guard let rect = self.transformCallback?(metadata)
                else { return }

                withAnimation(.linear(duration: 0.1)) {
                    self.parent.model.candidateFoundBox = rect
                }
                self.parent.match = self.parent.matchFunction(code)
                self.nextCheck = Date(timeIntervalSinceNow: 0.6)
                
                if let _ = self.parent.match {
                    self.haptics?.success()
                } else {
                    self.haptics?.failure()
                }
            }
        }
    }
}

// MARK: Coordinator Start
extension QrReaderRepresentable.Coordinator {
    func start(_ view: VideoPreviewUIView, model: CaptureModel) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        view.videoPreviewLayer.opacity = 0
        
        let session = view.session!
        
        configureSession(session: session,
                         on: self.queue) { resultOutput in
            switch resultOutput {
            case .success(let output):
                self.queue.async {
                    output.output.setMetadataObjectsDelegate(self, queue: self.queue)
                    
                    if output.inputs.count == 2, let camera = output.inputs.first {
                        DispatchQueue.main.async {
                            model.state = .running(output)
                            model.canSwitchCamera = true
                            model.hasTorch = camera.torch
                        }
                    } else {
                        DispatchQueue.main.async {
                            model.state = .running(output)
                        }
                    }
                    
                    session.startRunning()

                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.25) {
                            view.videoPreviewLayer.opacity = 1
                        }
                        
                        self.transformCallback = { metadata in
                            view.videoPreviewLayer.transformedMetadataObject(for: metadata)?.bounds
                        }
                        self.copyRectOfInterest(view)
                    }
                }
            case .failure(let error):
                self.parent.changeState { state, _ in
                    state = .error(error)
                }
            }
        }
    }
}

// MARK: Coordinator Transform of rectOfInterest
extension QrReaderRepresentable.Coordinator {
    func copyRectOfInterest(_ uiView: VideoPreviewUIView) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        guard let box = self.parent.model.scanBox,
              let output = self.parent.model.state.output
        else { return }
        
        let callback: VideoPreviewUIView.RectOfInterestCallback = { rect in
            self.queue.async {
                output.rectOfInterest = rect
            }
        }
        
        uiView.rectOfInterest = (box, callback)
    }
}
    
// MARK: Coordinator Stop
extension QrReaderRepresentable.Coordinator {
    func stop(_ view: VideoPreviewUIView) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard !self.parent.model.state.stopped
        else {
            return
        }
        self.parent.model.state = .stopped
        
        self.transformCallback = nil
        let session = view.session
        
        self.queue.async {
            session?.stopRunning()
            
            DispatchQueue.main.async {
                self.parent.model.torchEnabled = false
                self.parent.onDismiss?()
            }
        }
    }
}

// MARK: Coordinator Torch
extension QrReaderRepresentable.Coordinator {
    func setTorch(_ view: VideoPreviewUIView) {
        dispatchPrecondition(condition: .onQueue(.main))

        let torchEnabled = self.parent.model.torchEnabled
        
        guard let session = view.session, //.inputs.first as? AVCaptureDeviceInput,
              self.parent.model.hasTorch
        else {
            return
        }
        
        self.queue.async {
            
            guard let camera = session.inputs.first as? AVCaptureDeviceInput,
                  camera.device.isTorchModeSupported(.on)
            else { return }

            let currentlyEnabled: Bool = {
                switch camera.device.torchMode {
                case .on: return true
                case .off, .auto: return false
                @unknown default: preconditionFailure()
                }
            }()

            guard torchEnabled != currentlyEnabled
            else {
                return
            }
            
            session.beginConfiguration()
            defer {
                session.commitConfiguration()
                camera.device.unlockForConfiguration()
            }

            do {
                try camera.device.lockForConfiguration()
                
                if torchEnabled {
                    camera.device.torchMode = .on
                } else {
                    camera.device.torchMode = .off
                }
            } catch {}
        }
    }
}

// MARK: Coordinator Switch Camera
extension QrReaderRepresentable.Coordinator {
    func switchCamera(_ view: VideoPreviewUIView) {
        dispatchPrecondition(condition: .onQueue(.main))
        
        guard self.parent.model.canSwitchCamera,
              let inputs = self.parent.model.state.inputs,
              let session = view.session
        else { return }
        
        let nextInput = self.parent.model.selectedLens == 0 ? 1 : 0
        let input = inputs[nextInput]
        let selectedLens = self.parent.model.selectedLens
        
        self.queue.async {
            let current = inputs[selectedLens].device
            let currentFromSession = session.inputs.first as? AVCaptureDeviceInput
            guard current == currentFromSession
            else {
                // Switch already in progress
                return
            }

            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.15) {
                    view.videoPreviewLayer.opacity = 0
                }
            }

            session.beginConfiguration()
            session.removeInput(current)
            guard session.canAddInput(input.device)
            else {
                session.commitConfiguration()
                return
                
            }
            
            session.addInput(input.device)
            session.commitConfiguration()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25) {
                    view.videoPreviewLayer.opacity = 1
                }
                self.parent.model.hasTorch = input.torch
                self.parent.model.selectedLens = nextInput
            }
        }
    }
}
#endif
