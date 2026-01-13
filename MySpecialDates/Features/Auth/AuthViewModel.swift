import Foundation
import Combine
import SwiftUI
import AuthenticationServices

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Form fields
    @Published var email = ""
    @Published var password = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phoneNumber = ""
    @Published var birthDate = Date()
    
    // UI State
    @Published var showingSignUp = false
    @Published var showingError = false
    @Published var rememberMe = false
    @Published var isLoggedIn = false
    @Published var signUpSuccessful = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Monitor authentication state
        $currentUser
            .map { $0 != nil }
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Sign In (Dummy Mode for Testing)
    func signIn() async {
        isLoading = true
        errorMessage = nil
        
        // Dummy delay to simulate network request
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Dummy: Always successful login
        if !email.isEmpty && !password.isEmpty {
            // Create dummy user
            let dummyUser = User(
                id: "dummy-user-id",
                firstName: "Tim",
                lastName: "User",
                email: email,
                phoneNumber: "555-0123",
                birthDate: Date(),
                authType: .email,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            currentUser = dummyUser
            isLoggedIn = true
            clearForm()
        } else {
            errorMessage = "Please enter email and password"
            showingError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    func signUp() async {
        isLoading = true
        errorMessage = nil
        signUpSuccessful = false
        
        do {
            // Email'i kaydet (Login ekranına aktarmak için)
            let savedEmail = email
            
            let user = try await authService.signUp(
                email: email,
                password: password,
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber,
                birthDate: birthDate
            )
            currentUser = user
            
            // Formu temizle ama email'i koru (Login ekranında gösterilmek için)
            password = ""
            firstName = ""
            lastName = ""
            phoneNumber = ""
            birthDate = Date()
            email = savedEmail // Email'i geri yükle
            
            signUpSuccessful = true
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            signUpSuccessful = false
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Out
    func signOut() async {
        do {
            try await authService.signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
    
    // MARK: - Social Login
    func signInWithFacebook() async {
        // TODO: Implement Facebook login
        print("Facebook login not implemented yet")
    }
    
    func signInWithApple() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create Apple Sign-In service
            let appleSignInService = AppleSignInService(firebaseService: FirebaseEventService())
            let firestoreUser = try await appleSignInService.signInWithApple()
            
            // Convert FirestoreUser to our User model
            let user = User(
                id: firestoreUser.id ?? UUID().uuidString,
                firstName: firestoreUser.displayName.components(separatedBy: " ").first ?? "",
                lastName: firestoreUser.displayName.components(separatedBy: " ").dropFirst().joined(separator: " "),
                email: firestoreUser.email,
                phoneNumber: nil,
                birthDate: Date(), // Default value
                authType: .apple
            )
            
            currentUser = user
            clearForm()
            print("✅ Apple Sign-In başarılı: \(user.firstName) \(user.lastName)")
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
            print("❌ Apple Sign-In hatası: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    private func clearForm() {
        email = ""
        password = ""
        firstName = ""
        lastName = ""
        phoneNumber = ""
        birthDate = Date()
    }
    
    func dismissError() {
        errorMessage = nil
        showingError = false
    }
}
