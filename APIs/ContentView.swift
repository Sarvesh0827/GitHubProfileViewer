import SwiftUI

struct ContentView: View {
    
    @State private var users: GithubUsers?
    
    var body: some View {
        ZStack {
            // Background Gradient
            RadialGradient(colors: [
                Color(#colorLiteral(red: 0.678, green: 0.847, blue: 0.902, alpha: 1)), // Light Blue
                Color(#colorLiteral(red: 0.529, green: 0.808, blue: 0.922, alpha: 1)), // Medium Light Blue
                Color(#colorLiteral(red: 0.529, green: 0.807, blue: 0.98, alpha: 1))  // Sky Blue
            ],
            center: .center,
            startRadius: 5,
            endRadius: 500)
            .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack {
                if let avatarUrl = users?.avatarUrl, let url = URL(string: avatarUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        case .failure(_):
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 150, height: 150)
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 150, height: 150)
                }
                
                Text(users?.login ?? "Login Placeholder")
                    .bold()
                    .font(.title3)
                
                Text(users?.bio ?? "No bio available")
                    .padding()
            }
            .padding()
        }
        .task {
            do {
                users = try await getUser()
            } catch GithubError.invalidResponse {
                print("Invalid Response")
            } catch GithubError.invalidData {
                print("Invalid Data")
            } catch GithubError.invalidUrl {
                print("Invalid URL")
            } catch {
                print("Unexpected Error")
            }
        }
    }
    
    func getUser() async throws -> GithubUsers {
        let endpoint = "https://api.github.com/users/Sarvesh0827"
        
        guard let url = URL(string: endpoint) else {
            throw GithubError.invalidUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GithubError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(GithubUsers.self, from: data)
    }
}

struct GithubUsers: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}

enum GithubError: Error {
    case invalidUrl
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
