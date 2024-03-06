//
//  ViewModel.swift
//  Changey
//
//  Created by Tyler D Lawrence on 3/6/24.
//

import OpenAIKit
import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var isGenerating: Bool = false
    @Published var text: String?
    
    var undoManager: UndoManager?
    
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(
            Configuration(
                organization: "INSERT-ORGANIZATION-ID",
                apiKey: "INSERT-API-KEY"
            )
        )
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(
                prompt: prompt,
                resolution: .medium,
                responseFormat: .base64Json
            )
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}
