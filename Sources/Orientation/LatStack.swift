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

public struct _LatStack<C1: View, C2: View, C3: View, C4: View, C5: View>: OrientationStack {
    var direction: Orientation.Direction = .latitude
    let alignment: Orientation.Alignment
    let spacing: CGFloat?
    @Namespace var namespace: Namespace.ID
    
    let c1: () -> C1
    let c2: (() -> C2)?
    let c3: (() -> C3)?
    let c4: (() -> C4)?
    let c5: (() -> C5)?
    
    @EnvironmentObject var model: Orientation.Model

    public var body: some View {
        self.stack(from: model)
    }
}

public func LatStack<C1: View>(alignment: Orientation.Alignment = .center,
                               spacing: CGFloat? = nil,
                               @ViewBuilder _ c1: @escaping () -> C1)
-> _LatStack<C1, Optional<EmptyView>, Optional<EmptyView>, Optional<EmptyView>, Optional<EmptyView>> {
    
    _LatStack(alignment: alignment,
              spacing: spacing,
              c1: c1,
              c2: nil,
              c3: nil,
              c4: nil,
              c5: nil)
}

public func LatStack<C1: View, C2: View>(alignment: Orientation.Alignment = .center,
                                         spacing: CGFloat? = nil,
                                         @ViewBuilder c1: @escaping () -> C1,
                                         @ViewBuilder c2: @escaping () -> C2)
-> _LatStack<C1, C2, Optional<EmptyView>, Optional<EmptyView>, Optional<EmptyView>> {
    _LatStack(alignment: alignment,
               spacing: spacing,
               c1: c1,
               c2: c2,
               c3: nil,
               c4: nil,
               c5: nil)
}

public func LatStack<C1: View, C2: View, C3: View>(alignment: Orientation.Alignment = .center,
                                                   spacing: CGFloat? = nil,
                                                   @ViewBuilder c1: @escaping () -> C1,
                                                   @ViewBuilder c2: @escaping () -> C2,
                                                   @ViewBuilder c3: @escaping () -> C3)
-> _LatStack<C1, C2, C3, Optional<EmptyView>, Optional<EmptyView>> {
    _LatStack(alignment: alignment,
               spacing: spacing,
               c1: c1,
               c2: c2,
               c3: c3,
               c4: nil,
               c5: nil)
}

public func LatStack<C1: View, C2: View, C3: View, C4: View>(alignment: Orientation.Alignment = .center,
                                                             spacing: CGFloat? = nil,
                                                             @ViewBuilder c1: @escaping () -> C1,
                                                             @ViewBuilder c2: @escaping () -> C2,
                                                             @ViewBuilder c3: @escaping () -> C3,
                                                             @ViewBuilder c4: @escaping () -> C4)
-> _LatStack<C1, C2, C3, C4, Optional<EmptyView>> {
    _LatStack(alignment: alignment,
               spacing: spacing,
               c1: c1,
               c2: c2,
               c3: c3,
               c4: c4,
               c5: nil)
}

public func LatStack<C1: View, C2: View, C3: View, C4: View, C5: View>(alignment: Orientation.Alignment = .center,
                                                                        spacing: CGFloat? = nil,
                                                                        c1: @escaping () -> C1,
                                                                        c2: @escaping () -> C2,
                                                                        c3: @escaping () -> C3,
                                                                        c4: @escaping () -> C4,
                                                                        c5: @escaping () -> C5)
-> _LatStack<C1, C2, C3, C4, C5> {
    _LatStack(alignment: alignment,
               spacing: spacing,
               c1: c1,
               c2: c2,
               c3: c3,
               c4: c4,
               c5: c5)
}
