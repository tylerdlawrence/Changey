
import OpenAIKit
import SwiftUI

@MainActor
final class ViewModel: ObservableObject {
    @Published var isGenerating: Bool = false
    @Published var text: String?
    
    var undoManager: UndoManager?
    
    private var openai: OpenAI?
    
    func setup() {
        openai = OpenAI(Configuration(organization: "Personal", apiKey: ""))
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

struct ContentView: View {
    
    @Environment(\.undoManager) private var undoManager
    @ObservedObject private var viewModel = ViewModel()
    
    @State var text = ""
    @State var isGenerating = false
    @State var image: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(uiColor: UIColor.secondarySystemGroupedBackground).opacity(0.1).ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                content
            }
        }
        .task {
            viewModel.setup()
        }
    }
}

// MARK: extension

extension ContentView {
    
    @ViewBuilder var content: some View {
        Section {
            
        } header: {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(10)
                    .frame(width: 250, height: 250, alignment: .center)
            } else {
                if isGenerating {
                    ProgressView()
                }
            }
        }
        Section {
            TextField("Enter prompt", text: $text.animation())
                .textFieldStyle(.roundedBorder)
        } header: {
            HStack(alignment: .center) {
                Text("The more descriptive you can be the better.")
                    .font(.footnote.italic())
                    .foregroundColor(.secondary)
                Spacer(minLength: 0)
                generateButton
            }
        }
        .frame(width: UIScreen.main.bounds.width - 20)
    }
    
    @ViewBuilder var generateButton: some View {
        Button {
            Task {
                if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    isGenerating = true
                    let result = await viewModel.generateImage(prompt: text)
                    if result == nil {
                        print("Failed to get image")
                        isGenerating = false
                    }
                    isGenerating = false
                    self.image = result
                }
            }
        } label: {
            Text(!isGenerating ? "Generate" : "Generating")
        }
        .padding(.all, 7)
        .buttonStyle(.bordered)
        .disabled(text.isEmpty)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SceneContainerView()
            .environmentObject(ViewModel.init())
    }
}

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

struct SidebarToolbarModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Changey")
                            .font(.headline.bold())
                        Text("...what's in your head?")
                            .font(.subheadline.italic())
                            .foregroundColor(.secondary)
                        
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
