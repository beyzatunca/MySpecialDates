import Foundation

// MARK: - OpenAI Service Protocol
protocol OpenAIServiceProtocol {
    func generateMessage(prompt: String) async throws -> String
}

// MARK: - OpenAI Service Implementation
class OpenAIService: OpenAIServiceProtocol {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String? = nil) {
        // In production, get from environment or secure storage
        // For now, use placeholder - user should set their own API key
        self.apiKey = apiKey ?? ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    
    func generateMessage(prompt: String) async throws -> String {
        // If no API key, return a mock message for development
        guard !apiKey.isEmpty else {
            return generateMockMessage(for: prompt)
        }
        
        guard let url = URL(string: baseURL) else {
            throw OpenAIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                [
                    "role": "system",
                    "content": "You are a creative greeting card message writer. Write heartfelt, personal messages that are warm and genuine."
                ],
                [
                    "role": "user",
                    "content": prompt
                ]
            ],
            "max_tokens": 150,
            "temperature": 0.8
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIError.apiError("Invalid response from OpenAI API")
        }
        
        let decoder = JSONDecoder()
        let result = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let message = result.choices.first?.message.content else {
            throw OpenAIError.noMessage
        }
        
        return message.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Mock Message Generation (for development)
    private func generateMockMessage(for prompt: String) -> String {
        let mockMessages = [
            "Wishing you a day filled with joy, laughter, and all the happiness you deserve! 🎉",
            "May your special day be as wonderful and amazing as you are! Happy celebrations! ✨",
            "Sending you warm wishes and heartfelt congratulations on this beautiful occasion! 💕",
            "Here's to celebrating you and all the wonderful moments ahead! Cheers! 🥂",
            "May this day bring you endless joy and create beautiful memories to cherish forever! 🌟"
        ]
        return mockMessages.randomElement() ?? mockMessages[0]
    }
}

// MARK: - OpenAI Response Models
private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}

// MARK: - OpenAI Errors
enum OpenAIError: LocalizedError {
    case invalidURL
    case apiError(String)
    case noMessage
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noMessage:
            return "No message received from API"
        }
    }
}

