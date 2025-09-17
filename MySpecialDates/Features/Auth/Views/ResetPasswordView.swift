import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    
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
                // Calendar icons scattered in background
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
                        // TODO: Implement password reset functionality
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
                    .disabled(newPassword.isEmpty || confirmPassword.isEmpty)
                    
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
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
}

#Preview {
    ResetPasswordView()
}
