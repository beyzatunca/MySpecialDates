import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("My Special Dates")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Özel günlerinizi asla unutmayın")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Login Form
                VStack(spacing: 20) {
                    CustomTextField(
                        text: $viewModel.email,
                        placeholder: "Email",
                        icon: "envelope"
                    )
                    
                    CustomSecureField(
                        text: $viewModel.password,
                        placeholder: "Şifre",
                        icon: "lock"
                    )
                    
                    Button(action: {
                        Task {
                            await viewModel.signIn()
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading)
                }
                
                // Social Login Buttons
                VStack(spacing: 12) {
                    Text("veya")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        SocialLoginButton(
                            title: "Facebook",
                            icon: "facebook",
                            color: Color(red: 66/255, green: 103/255, blue: 178/255)
                        ) {
                            Task {
                                await viewModel.signInWithFacebook()
                            }
                        }
                        
                        SocialLoginButton(
                            title: "Apple",
                            icon: "apple.logo",
                            color: .black
                        ) {
                            Task {
                                await viewModel.signInWithApple()
                            }
                        }
                    }
                }
                
                // Sign Up Link
                HStack {
                    Text("Hesabınız yok mu?")
                        .foregroundColor(.secondary)
                    
                    Button("Kayıt Ol") {
                        showingSignUp = true
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
            .alert("Hata", isPresented: $viewModel.showingError) {
                Button("Tamam") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "Bilinmeyen hata")
            }
        }
    }
}

// MARK: - Custom Components
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SocialLoginButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

#Preview {
    LoginView()
}
