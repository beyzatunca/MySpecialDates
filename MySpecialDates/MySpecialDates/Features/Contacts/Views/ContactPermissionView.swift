import SwiftUI

struct ContactPermissionView: View {
    @Binding var isPresented: Bool
    let onPermissionGranted: () -> Void
    let onPermissionDenied: () -> Void
    @State private var animateIcon = false
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Modern blur background
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            // Main content container
            VStack(spacing: 0) {
                // Top spacer
                Spacer()
                
                // Content card
                VStack(spacing: 32) {
                    // Animated icon with gradient background
                    ZStack {
                        // Gradient background circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .scaleEffect(animateIcon ? 1.0 : 0.8)
                            .opacity(animateIcon ? 1.0 : 0.6)
                        
                        // Main icon
                        Image(systemName: "person.2.circle.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animateIcon ? 1.0 : 0.9)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            animateIcon = true
                        }
                    }
                    
                    // Text content
                    VStack(spacing: 16) {
                        // Title
                        Text("Kişi Erişimi")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                        
                        // Description
                        Text("Arkadaşlarınızın doğum günlerini kaçırmamak için kişi bilgilerinize erişim izni verin. Bu sayede otomatik olarak doğum günlerini takip edebiliriz.")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .opacity(animateContent ? 1.0 : 0.0)
                            .offset(y: animateContent ? 0 : 20)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                            animateContent = true
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        // Primary button - Allow
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onPermissionGranted()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("İzin Ver")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .scaleEffect(animateContent ? 1.0 : 0.95)
                        .opacity(animateContent ? 1.0 : 0.0)
                        
                        // Secondary button - Not now
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isPresented = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onPermissionDenied()
                            }
                        }) {
                            Text("Şimdi Değil")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .scaleEffect(animateContent ? 1.0 : 0.95)
                        .opacity(animateContent ? 1.0 : 0.0)
                    }
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.4)) {
                            animateContent = true
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 20)
                
                // Bottom spacer
                Spacer()
            }
        }
        .onAppear {
            // Start animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateIcon = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.9).delay(0.2)) {
                animateContent = true
            }
        }
    }
}

#Preview {
    ContactPermissionView(
        isPresented: .constant(true),
        onPermissionGranted: {},
        onPermissionDenied: {}
    )
}
