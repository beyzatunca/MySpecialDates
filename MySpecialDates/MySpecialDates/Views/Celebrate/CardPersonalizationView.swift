import SwiftUI
import PhotosUI

struct CardPersonalizationView: View {
    let template: CardTemplate
    @ObservedObject var viewModel: CelebrateViewModel
    let onContinue: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var recipientName: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @FocusState private var isMessageFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(template.name)
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Personalize your card")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Photo Selection (if supported)
                    if template.supportsUserPhoto {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Photo")
                                .font(.system(size: 18, weight: .semibold))
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                if let photo = viewModel.userPhoto {
                                    Image(uiImage: photo)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 200, height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color(.systemGray5))
                                        .frame(height: 200)
                                        .overlay(
                                            VStack(spacing: 12) {
                                                Image(systemName: "photo.badge.plus")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.secondary)
                                                Text("Tap to add photo")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                        )
                                }
                            }
                            .onChange(of: selectedPhoto) { old, new in
                                Task {
                                    if let data = try? await new?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        viewModel.setUserPhoto(image)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Recipient Name (Optional)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recipient Name (Optional)")
                            .font(.system(size: 18, weight: .semibold))
                        
                        TextField("Enter name", text: $recipientName)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 20)
                    
                    // Message Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Message")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Spacer()
                            
                            // AI Generate Button
                            Button(action: {
                                Task {
                                    await viewModel.generateAIMessage(
                                        for: template,
                                        recipientName: recipientName.isEmpty ? nil : recipientName
                                    )
                                }
                            }) {
                                HStack(spacing: 6) {
                                    if viewModel.isGeneratingMessage {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "sparkles")
                                    }
                                    Text("AI Generate")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .disabled(viewModel.isGeneratingMessage)
                        }
                        
                        TextEditor(text: $viewModel.customMessage)
                            .frame(height: 150)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .focused($isMessageFocused)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isMessageFocused ? Color.blue : Color.clear, lineWidth: 2)
                            )
                        
                        if viewModel.customMessage.isEmpty {
                            Text("Write your message or use AI to generate one")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Continue Button
                    Button(action: {
                        if viewModel.customMessage.isEmpty {
                            viewModel.customMessage = "Happy \(template.category.rawValue.capitalized)!"
                        }
                        onContinue()
                    }) {
                        Text("Continue to Preview")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

