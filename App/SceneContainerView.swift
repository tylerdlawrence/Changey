//
//  SceneContainerView.swift
//  Changey
//
//  Created by Tyler D Lawrence on 3/6/24.
//

import SwiftUI

struct SceneContainerView: View {
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            ContentView()
                .sidebarToolBar()
                .environmentObject(viewModel)
                .onAppear {
                    viewModel.setup()
                    viewModel.undoManager = undoManager
                }
        }
    }
}

#Preview {
    SceneContainerView()
        .environmentObject(ViewModel.init())
}
