
import OpenAIKit
import SwiftUI

struct ContentView: View {
    
    @Environment(\.undoManager) private var undoManager
    @ObservedObject private var viewModel = ViewModel()
    
    @State var text = ""
    @State var isGenerating = false
    @State var image: UIImage?
    
    var body: some View {
        content.task { viewModel.setup() }
    }
}

// MARK: extension

extension ContentView {
    
    @ViewBuilder var content: some View {
        
        let moveTo = AnyTransition.modifier(active: MoveToModifier(offset: 70, active: true), identity: MoveToModifier(offset: 70, active: false))
        
        ZStack(alignment: .top) {
            Color(uiColor: UIColor.secondarySystemGroupedBackground).opacity(0.1).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                Section { } header: {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(3)
                            .frame(width: 250, height: 250, alignment: .center)
                        saveToPhotosButton
                    } else {
                        if isGenerating {
                            ProgressView()
                                .frame(width: 250, height: 250, alignment: .center)
                        } else {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .foregroundColor(.gray)
                                .opacity(0.2)
                                .frame(width: 250, height: 250, alignment: .center)
                                .overlay {
                                    Text("Image will appear here")
                                        .font(.footnote).bold()
                                        .foregroundColor(.secondary)
                                }
                        }
                    }
                }
                Section {
                    TextField("Enter prompt", text: $text.animation())
                        .textFieldStyle(.roundedBorder).italic()
                } header: {
                    HStack(alignment: .center) {
                        Text("Describe the image you want to create")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer(minLength: 0)
                        generateButton
                    }
                    .animation(.default.speed(0.5), value: isGenerating)
                }
                .frame(width: UIScreen.main.bounds.width - 20)
            }
        }
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
                .id(isGenerating)
                .transition(.scale(scale: 1.25).combined(with: .opacity))
        }
        .padding(.all, 7)
        .buttonStyle(.bordered)
        .disabled(text.isEmpty)
    }
    
    @ViewBuilder var saveToPhotosButton: some View {
        Button("Save") {
            guard let inputImage = image else { return }

            let imageSaver = ImageSaver()
            imageSaver.writeToPhotoAlbum(image: inputImage)
        }
        .padding(.all, 7)
        .buttonStyle(.bordered)
    }
}

struct ContentView_Previews: PreviewProvider {
    @StateObject static var viewModel = ViewModel()
    
    static var previews: some View {
        NavigationView {
            ContentView()
                .sidebarToolBar()
                .environmentObject(viewModel)
                .task {
                    viewModel.setup()
                }
        }
    }
}
