import SwiftUI

struct CreateAIMessageView: View {
    let event: UserEvent
    @Environment(\.dismiss) private var dismiss
    @State private var message: String = ""
    @State private var isGenerating: Bool = false
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    private let openAIService = OpenAIService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.25, blue: 0.35),
                        Color(red: 0.25, green: 0.35, blue: 0.45)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Create Message with AI")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("For: \(event.displayName)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("Let AI help you write a personalized celebration message")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)
                        
                        // Message Preview
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Your Message")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if !message.isEmpty {
                                    Button(action: {
                                        message = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            
                            ZStack(alignment: .topLeading) {
                                if message.isEmpty {
                                    Text("AI will generate a personalized message for you. Tap 'Generate Message' to get started, or write your own message here.")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 20)
                                }
                                
                                TextEditor(text: $message)
                                    .frame(minHeight: 200)
                                    .padding(8)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.9))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .onAppear {
                                UITextView.appearance().textColor = .black
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Generate Button
                        Button(action: {
                            generateMessage()
                        }) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Generate Message")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(16)
                        }
                        .disabled(isGenerating)
                        .padding(.horizontal, 24)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // Copy to clipboard
                                UIPasteboard.general.string = message
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                    Text("Copy")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                            }
                            .disabled(message.isEmpty)
                            
                            Button(action: {
                                // Share
                                let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                   let rootViewController = windowScene.windows.first?.rootViewController {
                                    rootViewController.present(activityVC, animated: true)
                                }
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(16)
                            }
                            .disabled(message.isEmpty)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func generateMessage() {
        isGenerating = true
        message = ""
        showingError = false
        
        Task {
            do {
                let eventType = event.eventType.lowercased()
                let name = event.displayName
                let prompt = "Write a heartfelt and personal \(eventType) message for \(name). Make it warm, genuine, and celebratory. Keep it short, maximum 3 sentences."
                
                let generatedMessage = try await openAIService.generateMessage(prompt: prompt)
                
                await MainActor.run {
                    message = generatedMessage
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                    isGenerating = false
                }
            }
        }
    }
}

