import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background with calendar theme (same as LoginView)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.35),
                    Color(red: 0.25, green: 0.35, blue: 0.45)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Calendar Background Pattern
            CalendarBackgroundView()
                .opacity(0.1)
            
            // Content Card
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Start tracking your special moments.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Sign Up Form Card
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            // Name Fields
                            HStack(spacing: 12) {
                                TextField("First Name", text: $viewModel.firstName)
                                    .textFieldStyle(ModernTextFieldStyle())
                                
                                TextField("Last Name", text: $viewModel.lastName)
                                    .textFieldStyle(ModernTextFieldStyle())
                            }
                            
                            // Email Field
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(ModernTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            // Phone Field
                            TextField("Phone", text: $viewModel.phoneNumber)
                                .textFieldStyle(ModernTextFieldStyle())
                                .keyboardType(.phonePad)
                            
                            // Password Field
                            SecureField("Password", text: $viewModel.password)
                                .textFieldStyle(ModernTextFieldStyle())
                            
                            // Birth Date Picker
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white.opacity(0.8))
                                    .frame(width: 20)
                                
                                DatePicker("Birth Date", selection: $viewModel.birthDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .accentColor(.white)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.white.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Sign Up Button
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
                                    Text("Sign Up")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .disabled(viewModel.isLoading || viewModel.firstName.isEmpty || viewModel.lastName.isEmpty || viewModel.email.isEmpty || viewModel.phoneNumber.isEmpty || viewModel.password.isEmpty)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                Spacer()
            }
        }
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
    }
}

#Preview {
    SignUpView()
}
