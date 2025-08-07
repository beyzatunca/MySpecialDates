import Foundation
import Combine

protocol UserRepositoryProtocol {
    func saveUser(_ user: User) async throws
    func getUser(by email: String) async throws -> User?
    func getUser(by id: String) async throws -> User?
    func updateUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
}

class UserRepository: UserRepositoryProtocol {
    private let userDefaults = UserDefaults.standard
    private let userKey = "saved_users"
    
    // MARK: - Save User
    func saveUser(_ user: User) async throws {
        var users = getAllUsers()
        users[user.id] = user
        saveAllUsers(users)
    }
    
    // MARK: - Get User by Email
    func getUser(by email: String) async throws -> User? {
        let users = getAllUsers()
        return users.values.first { $0.email.lowercased() == email.lowercased() }
    }
    
    // MARK: - Get User by ID
    func getUser(by id: String) async throws -> User? {
        let users = getAllUsers()
        return users[id]
    }
    
    // MARK: - Update User
    func updateUser(_ user: User) async throws {
        var users = getAllUsers()
        users[user.id] = user
        saveAllUsers(users)
    }
    
    // MARK: - Delete User
    func deleteUser(_ user: User) async throws {
        var users = getAllUsers()
        users.removeValue(forKey: user.id)
        saveAllUsers(users)
    }
    
    // MARK: - Private Helper Methods
    private func getAllUsers() -> [String: User] {
        guard let data = userDefaults.data(forKey: userKey),
              let users = try? JSONDecoder().decode([String: User].self, from: data) else {
            return [:]
        }
        return users
    }
    
    private func saveAllUsers(_ users: [String: User]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        userDefaults.set(data, forKey: userKey)
    }
}
