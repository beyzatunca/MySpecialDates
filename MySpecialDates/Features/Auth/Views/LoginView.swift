import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var showPassword = false
    
    var body: some View {
        ZStack {
            // Background with calendar theme
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
                        Text("Special Days")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Remember every important moment.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    
                    // Login Form Card
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            // Email Field
                            TextField("Email", text: $viewModel.email)
                                .textFieldStyle(ModernTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                            
                            // Password Field with Visibility Toggle
                            HStack {
                                if showPassword {
                                    TextField("Password", text: $viewModel.password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                } else {
                                    SecureField("Password", text: $viewModel.password)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .foregroundColor(.white)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(25)
                        }
                        
                        // Log In Button
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
                                    Text("Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Remember Me & Forgot Password
                        HStack {
                            Button(action: {
                                viewModel.rememberMe.toggle()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: viewModel.rememberMe ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Remember me")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                showingForgotPassword = true
                            }) {
                                Text("Forgot password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .fill(Color.white.opacity(0.4))
                                .frame(height: 1)
                        }
                        
                        // Social Login Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                Task {
                                    await viewModel.signInWithFacebook()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "f.square.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    
                                    Text("Continue with Facebook")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(red: 66/255, green: 103/255, blue: 178/255))
                                .cornerRadius(25)
                            }
                            
                            Button(action: {
                                Task {
                                    await viewModel.signInWithApple()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                    
                                    Text("Continue with Apple")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.black)
                                .cornerRadius(25)
                            }
                        }
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Button(action: {
                                showingSignUp = true
                            }) {
                                Text("Sign up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
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
        .sheet(isPresented: $showingSignUp) {
            SignUpView()
        }
        .fullScreenCover(isPresented: $showingForgotPassword) {
            DummyForgotPasswordFlow()
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

// MARK: - Custom Components
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.15))
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .medium))
            .accentColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

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

// MARK: - Calendar Background
struct CalendarBackgroundView: View {
    var body: some View {
        ZStack {
            // Large Calendar Icons scattered in background
            VStack(spacing: 40) {
                HStack(spacing: 60) {
                    Image(systemName: "calendar")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(-15))
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.pink)
                        .rotationEffect(.degrees(20))
                }
                .offset(x: -50, y: -100)
                
                HStack(spacing: 80) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(10))
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(-25))
                }
                .offset(x: 40, y: 50)
                
                HStack(spacing: 100) {
                    Image(systemName: "balloon.fill")
                        .font(.system(size: 65))
                        .foregroundColor(.green)
                        .rotationEffect(.degrees(15))
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 55))
                        .foregroundColor(.purple)
                        .rotationEffect(.degrees(-10))
                }
                .offset(x: -30, y: 150)
            }
        }
    }
}

// MARK: - Dummy Forgot Password Flow
struct DummyForgotPasswordFlow: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 1
    @State private var email = ""
    @State private var verificationCode = Array(repeating: "", count: 6)
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @FocusState private var focusedField: Int?
    
    var body: some View {
        ZStack {
            // Background with calendar theme
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.35),
                    Color(red: 0.25, green: 0.35, blue: 0.45)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Calendar Background Icons
            ZStack {
                Image(systemName: "calendar")
                    .font(.system(size: 120))
                    .foregroundColor(.white.opacity(0.1))
                    .rotationEffect(.degrees(-15))
                    .offset(x: -100, y: -200)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.pink.opacity(0.15))
                    .rotationEffect(.degrees(20))
                    .offset(x: 120, y: -150)
                
                Image(systemName: "gift.fill")
                    .font(.system(size: 90))
                    .foregroundColor(.blue.opacity(0.12))
                    .rotationEffect(.degrees(10))
                    .offset(x: -80, y: 100)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow.opacity(0.15))
                    .rotationEffect(.degrees(-25))
                    .offset(x: 100, y: 150)
                
                Image(systemName: "balloon.fill")
                    .font(.system(size: 85))
                    .foregroundColor(.green.opacity(0.12))
                    .rotationEffect(.degrees(15))
                    .offset(x: -120, y: 0)
                
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 95))
                    .foregroundColor(.purple.opacity(0.1))
                    .rotationEffect(.degrees(-10))
                    .offset(x: 80, y: 50)
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main Card
                VStack(spacing: 32) {
                    if currentStep == 1 {
                        // Step 1: Forgot Password
                        forgotPasswordStep
                    } else if currentStep == 2 {
                        // Step 2: Verify Email
                        verifyEmailStep
                    } else {
                        // Step 3: Reset Password
                        resetPasswordStep
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Step Views
    private var forgotPasswordStep: some View {
        VStack(spacing: 32) {
            // Icon
            Image(systemName: "touchid")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
            
            // Title
            Text("Forgot Your Password\nand Continue")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Email Input
            HStack {
                Image(systemName: "envelope")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 20)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            .padding(16)
            .background(Color.white.opacity(0.15))
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(25)
            
            // Submit Button
            Button(action: {
                // Dummy: Sadece bir sonraki adıma geç
                withAnimation {
                    currentStep = 2
                }
            }) {
                Text("Submit Now")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            
            // Back to Login
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14))
                    Text("back to login")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.8))
            }
        }
    }
    
    private var verifyEmailStep: some View {
        VStack(spacing: 32) {
            // Icon
            Image(systemName: "envelope")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
            
            // Title
            Text("Verify Your Email to Begin\nDoor Deliveries")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Subtitle
            Text("Enter the 6-digit verification code")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            // Verification Code Input
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    TextField("", text: $verificationCode[index])
                        .frame(width: 45, height: 50)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                        .background(Color.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(12)
                        .keyboardType(.numberPad)
                        .focused($focusedField, equals: index)
                        .onChange(of: verificationCode[index]) { newValue in
                            // Move to next field when digit is entered
                            if newValue.count == 1 && index < 5 {
                                focusedField = index + 1
                            }
                            // Limit to 1 character
                            if newValue.count > 1 {
                                verificationCode[index] = String(newValue.suffix(1))
                            }
                        }
                }
            }
            
            // Continue Button
            Button(action: {
                // Dummy: Bir sonraki adıma geç
                withAnimation {
                    currentStep = 3
                }
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            
            // Resend Code
            HStack(spacing: 4) {
                Text("Didn't you receive any code?")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Button(action: {
                    // Dummy: Sadece mesaj göster
                    print("Resend code - Dummy action")
                }) {
                    Text("Resend Code")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    private var resetPasswordStep: some View {
        VStack(spacing: 32) {
            // Icon
            Image(systemName: "gearshape")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
            
            // Title
            Text("Reset Password to Access\nDoorstep Deliveries")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            VStack(spacing: 16) {
                // New Password Input
                HStack {
                    Image(systemName: "lock")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    
                    if showNewPassword {
                        TextField("Enter your new password", text: $newPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    } else {
                        SecureField("Enter your new password", text: $newPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showNewPassword.toggle()
                    }) {
                        Image(systemName: showNewPassword ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(25)
                
                // Confirm Password Input
                HStack {
                    Image(systemName: "lock")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    
                    if showConfirmPassword {
                        TextField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    } else {
                        SecureField("Confirm your password", text: $confirmPassword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        showConfirmPassword.toggle()
                    }) {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(16)
                .background(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(25)
            }
            
            // Continue Button
            Button(action: {
                // Dummy: Login ekranına dön
                dismiss()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            
            // Cancel Button
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
