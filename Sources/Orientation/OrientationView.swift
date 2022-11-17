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
import Combine
import SwiftUI

let DefaultOrientation: Orientation = .vertical
let DefaultLeftRight = Orientation.LeftRight.right

#if !os(macOS)
public struct OrientationView<Content: View>: View {
    @StateObject var model: Orientation.Model = .init()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    var content: () -> Content
    
    public init(_ content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        content()
            .onAppear {
                if let horizontal = horizontalSizeClass {
                    model.horizontal = horizontal
                }
                if let vertical = verticalSizeClass {
                    model.vertical = vertical
                }
            }
            .onChange(of: horizontalSizeClass) {
                if let horizontal = $0 {
                    model.horizontal = horizontal
                }
            }
            .onChange(of: verticalSizeClass) {
                if let vertical = $0 {
                    model.vertical = vertical
                }
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            model.safeSize = (width: geo.size.width, height: geo.size.height)
                        }
                        .onChange(of: geo.size) { _ in
                            model.safeSize = (width: geo.size.width, height: geo.size.height)
                        }
                }
            )
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            model.size = (width: geo.size.width, height: geo.size.height)
                        }
                        .onChange(of: geo.size) { _ in
                            model.size = (width: geo.size.width, height: geo.size.height)
                        }
                }
                .ignoresSafeArea(.all)
            )
            .environmentObject(model)
    }
}

public extension Orientation {
    struct OrientationLeftRight: Hashable {
        let orientation: Orientation
        let leftRight: LeftRight
        
        init(_ orientation: Orientation, _ leftRight: LeftRight) {
            self.orientation = orientation
            self.leftRight = leftRight
        }
    }
    
    struct UISize: Equatable {
        var width: UserInterfaceSizeClass
        var height: UserInterfaceSizeClass
    }
}

extension Orientation.Model {
    public var longSize: CGFloat {
        self.orientation.isVertical ? self.size.height : self.size.width
    }
    
    public var latSize: CGFloat {
        self.orientation.isVertical ? self.size.width : self.size.height
    }
    
    public var isVertical: Bool {
        self.orientation.isVertical
    }
    
    public var isHorizontal: Bool {
        !self.orientation.isVertical
    }
    
    var orientation: Orientation {
        self._assignOrientationLeftRight.orientation
    }
    
    public var isLeft: Bool {
        self.leftRight.isLeft
    }
    
    public var isRight: Bool {
        self.leftRight.isRight
    }
    
    var leftRight: Orientation.LeftRight {
        self._assignOrientationLeftRight.leftRight
    }
    
    public var compactHorizontal: Bool {
        self.orientation.isHorizontal
        && self.vertical == .compact
    }
    
    var notificationPublisher: AnyPublisher<UIDeviceOrientation, Never> {
        NotificationCenter
            .default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { notification in
                notification
                    .object
                    .flatMap {
                        $0 as? UIDevice
                    }
            }
            .map(\.orientation)
            .compactMap { orientation in
                switch orientation {
                case .portrait, .portraitUpsideDown,
                        .landscapeLeft, .landscapeRight:
                    return orientation
                case .faceUp, .faceDown, .unknown:
                    return nil
                @unknown default:
                    preconditionFailure()
                }
            }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func orientationPublisher()
    -> AnyPublisher<Orientation.OrientationLeftRight, Never> {
        let prependValue: UIDeviceOrientation = {
            switch UIDevice.current.orientation {
            case .faceUp,
                    .faceDown,
                    .unknown:
                if DefaultOrientation == .horizontal {
                    if DefaultLeftRight == .left {
                        return .landscapeLeft
                    } else {
                        return .landscapeRight
                    }
                } else {
                    return .portrait
                }
            case .landscapeLeft, .landscapeRight,
                    .portrait, .portraitUpsideDown:
                return UIDevice.current.orientation
            @unknown default:
                preconditionFailure()
            }
        }()
        
        let notificationPublisher = self.notificationPublisher
            .prepend(prependValue)
        
        return $horizontal
            .combineLatest($vertical)
            .combineLatest(notificationPublisher)
            .map { (size, deviceOrientation) in
                let priorLeftRight = self._assignOrientationLeftRight.leftRight
                switch (size.0, size.1, deviceOrientation) {
                case (_, _, .faceUp),
                    (_, _, .faceDown),
                    (_, _, .unknown):
                    preconditionFailure()
                case (.compact, .compact, .portrait),
                    (.compact, .compact, .portraitUpsideDown),
                    (.regular, .regular, .portrait),
                    (.regular, .regular, .portraitUpsideDown),
                    (.compact, .regular, _):
                    return Orientation.OrientationLeftRight(.vertical, priorLeftRight)
                case (.compact, .compact, .landscapeLeft),
                    (.regular, .regular, .landscapeLeft),
                    (.regular, .compact, .landscapeLeft):
                    return Orientation.OrientationLeftRight(.horizontal, .left)
                case (.compact, .compact, .landscapeRight),
                    (.regular, .regular, .landscapeRight),
                    (.regular, .compact, .landscapeRight):
                    return Orientation.OrientationLeftRight(.horizontal, .right)
                case (.regular, .compact, _):
                    return Orientation.OrientationLeftRight(.horizontal, priorLeftRight)
                @unknown default:
                    preconditionFailure()
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
#endif

