//
//  SidebarToolbarModifier.swift
//  Changey
//
//  Created by Tyler D Lawrence on 3/6/24.
//

import SwiftUI

struct SidebarToolbarModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Changey")
                            .font(.headline.bold())
                    }
                }
            }
    }
}

extension View {
    func sidebarToolBar() -> some View {
        modifier(SidebarToolbarModifier())
    }
}
