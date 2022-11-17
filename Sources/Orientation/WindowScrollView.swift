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

public struct WindowScrollView<Content: View>: View {
    let direction: Orientation.Direction
    let ignoresSafeArea: Bool
    let content: () -> Content
    
    @EnvironmentObject var model: Orientation.Model

    public init(direction: Orientation.Direction,
                ignoresSafeArea: Bool,
                @ViewBuilder content: @escaping () -> Content) {
        self.direction = direction
        self.ignoresSafeArea = ignoresSafeArea
        self.content = content
    }
    
    public var body: some View {
        Group {
            let width = ignoresSafeArea ? model.size.width : model.safeSize.width
            let height = ignoresSafeArea ? model.size.height : model.safeSize.height
            if model.orientation.isVertical {
                ScrollView(direction.isLongitude ? .vertical : .horizontal,
                                  showsIndicators: false) {
                    content()
                    .frame(idealWidth: width,
                           idealHeight: height,
                           alignment: .center)
                }
                .ignoresSafeArea(.container, edges: ignoresSafeArea ? .all : [])
            } else {
                ScrollView(direction.isLongitude ? .horizontal : .vertical, showsIndicators: false) {
                    content()
                    .frame(idealWidth: width,
                           idealHeight: height,
                           alignment: .center)
                }
                .ignoresSafeArea(.container, edges: ignoresSafeArea ? .all : [])
            }
        }
    }
}
