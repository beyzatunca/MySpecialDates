import SwiftUI

struct VerifyEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var verificationCode = Array(repeating: "", count: 6)
    @State private var showingResetPassword = false
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
                        showingResetPassword = true
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
                            // TODO: Implement resend code functionality
                            print("Resend code tapped")
                        }) {
                            Text("Resend Code")
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
                
                Spacer()
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            focusedField = 0
        }
        .fullScreenCover(isPresented: $showingResetPassword) {
            ResetPasswordView()
        }
    }
}

#Preview {
    VerifyEmailView()
}
