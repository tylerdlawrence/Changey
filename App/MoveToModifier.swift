//
//  MoveToModifier.swift
//  Changey
//
//  Created by Tyler D Lawrence on 3/6/24.
//

import SwiftUI

extension CGPoint {
    static func *(lhs: Self, rhs: CGFloat) -> Self {
        .init(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

// Idea: https://www.framer.com/showcase/project/lo2Qka8jtPXrjzZaPZdB/

struct MoveToModifier: ViewModifier & Animatable {
    init(offset: CGFloat, active: Bool) {
        self.offset = offset
        self.progress = active ? 1 : 0
    }
    
    var offset: CGFloat = .zero
    var maxYOffset: CGFloat = 40
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func body(content: Content) -> some View {
        let amount = sin(.pi * progress) * maxYOffset
        content.offset(x: offset * progress, y: amount)
    }
}
