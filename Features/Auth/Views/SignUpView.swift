import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Hesap Oluştur")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Özel günlerinizi takip etmeye başlayın")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign Up Form
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            CustomTextField(
                                text: $viewModel.firstName,
                                placeholder: "Ad",
                                icon: "person"
                            )
                            
                            CustomTextField(
                                text: $viewModel.lastName,
                                placeholder: "Soyad",
                                icon: "person"
                            )
                        }
                        
                        CustomTextField(
                            text: $viewModel.email,
                            placeholder: "Email",
                            icon: "envelope"
                        )
                        
                        CustomTextField(
                            text: $viewModel.phoneNumber,
                            placeholder: "Telefon (İsteğe bağlı)",
                            icon: "phone"
                        )
                        
                        CustomSecureField(
                            text: $viewModel.password,
                            placeholder: "Şifre",
                            icon: "lock"
                        )
                        
                        // Birth Date Picker
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                    .frame(width: 20)
                                
                                Text("Doğum Tarihi")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        Button(action: {
                            Task {
                                await viewModel.signUp()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("Kayıt Ol")
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
                    
                    // Social Sign Up
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
            .navigationTitle("Kayıt Ol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
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

#Preview {
    SignUpView()
}
