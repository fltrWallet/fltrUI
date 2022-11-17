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

enum CaptureError: String, Swift.Error, Identifiable {
    case notAuthorized
    case configurationFailed
    
    var id: String {
        String(describing: self)
    }
}

typealias VideoInput = (device: AVCaptureDeviceInput, torch: Bool)

func cameraInput() -> Result<[VideoInput], CaptureError> {
    dispatchPrecondition(condition: .notOnQueue(.main))

    func findCamera(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInUltraWideCamera,
                                                        .builtInWideAngleCamera,
                                                        .builtInDualWideCamera,
                                                        .builtInTripleCamera,
                                                        .builtInDualCamera,
                                                        .builtInTrueDepthCamera,
                                                        .builtInTelephotoCamera, ],
                                         mediaType: .video,
                                         position: position)
            .devices
            .first
    }

    func evaluateFound(_ cameras: [AVCaptureDevice]) -> Result<[VideoInput], CaptureError> {
        let videoInputs: [VideoInput] = cameras.compactMap {
            guard let inputDevice = try? AVCaptureDeviceInput(device: $0)
            else { return nil }
            
            return (inputDevice, $0.hasTorch)
        }
        
        guard !videoInputs.isEmpty
        else {
            if let finalTry = findCamera(position: .unspecified),
               let input = try? AVCaptureDeviceInput(device: finalTry) {
                return .success([ VideoInput(input, finalTry.hasTorch) ])
            } else {
                return .failure(.configurationFailed)
            }
        }
        
        return .success(videoInputs)
    }
    
    let cameras = [ findCamera(position: .back), findCamera(position: .front) ].compactMap { $0 }
    return evaluateFound(cameras)
}


func add(camera from: [VideoInput], to session: AVCaptureSession) -> Result<Void, CaptureError> {
    dispatchPrecondition(condition: .notOnQueue(.main))

    guard let camera = from.first?.device,
          session.canAddInput(camera)
    else {
        return .failure(.configurationFailed)
    }
    
    return .success(session.addInput(camera))
}

func addOutput(to session: AVCaptureSession, configuration: (AVCaptureMetadataOutput) -> Void) -> Result<AVCaptureMetadataOutput, CaptureError> {
    dispatchPrecondition(condition: .notOnQueue(.main))

    let output = AVCaptureMetadataOutput()
    guard session.canAddOutput(output)
    else {
        return .failure(.configurationFailed)
    }
    session.addOutput(output)

    configuration(output)
    
    return .success(output)
}

func checkAuthorized(sessionQueue: DispatchQueue,
                     callback: @escaping (Result<Void, CaptureError>) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
        callback(
            .success(())
        )
    case .notDetermined:
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { granted in
            defer {
                sessionQueue.resume()
            }
        
            callback(
                granted
                    ? .success(())
                    : .failure(.notAuthorized)
            )
        }
    case .denied, .restricted:
        callback(.failure(.notAuthorized))
    @unknown default:
        preconditionFailure()
    }
}

func setOrientation(on previewView: VideoPreviewUIView,
                    default: AVCaptureVideoOrientation = .portrait) {
    dispatchPrecondition(condition: .onQueue(.main))
    
    guard let connection = previewView.videoPreviewLayer.connection,
          connection.isVideoOrientationSupported,
          let orientation = UIApplication
            .shared
            .windows
            .first(where: { $0.isKeyWindow })?
            .windowScene?
            .interfaceOrientation
    else {
        return
    }

    switch orientation {
    case .landscapeLeft:
        connection.videoOrientation = .landscapeLeft
    case .landscapeRight:
        connection.videoOrientation = .landscapeRight
    case .portrait:
        connection.videoOrientation = .portrait
    case .portraitUpsideDown:
        connection.videoOrientation = .portraitUpsideDown
    case .unknown:
        connection.videoOrientation = `default`
    @unknown default:
        preconditionFailure()
    }
}

struct SessionConfiguration {
    let inputs: [VideoInput]
    let output: AVCaptureMetadataOutput
}

func configureSession(session: AVCaptureSession,
                      on queue: DispatchQueue,
                      callback: @escaping (Result<SessionConfiguration, CaptureError>) -> Void) {
    checkAuthorized(sessionQueue: queue) { authResult in
        switch authResult {
        case .success:
            queue.async {
                session.beginConfiguration()
                defer { session.commitConfiguration() }

                session.sessionPreset = .photo

                callback(
                    cameraInput()
                    .flatMap { inputs in
                        add(camera: inputs, to: session)
                        .flatMap {
                            addOutput(to: session) { output in
                                output.metadataObjectTypes = [ .qr ]
                            }
                        }
                        .map {
                            SessionConfiguration(inputs: inputs,
                                                 output: $0)
                        }
                    }
                )
            }
        case .failure(let error):
            callback(.failure(error))
        }
    }
}
#endif
