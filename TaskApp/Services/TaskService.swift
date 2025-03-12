// MARK: - TaskService.swift
import Foundation

class TaskService {
    static let shared = TaskService()
    
//    private let apiURL: String
//    private let apiKey: String
//    
//    private init() {
//        self.apiURL = APIConfig.baseURL + "/tasks"
//        self.apiKey = APIConfig.apiKey
//    }
//    
//    // For testing
//    init(apiURL: String, apiKey: String) {
//        self.apiURL = apiURL
//        self.apiKey = apiKey
//    }
    
    //API URL
    let apiURL = "http://localhost:3000/tasks"
    
    //API Key
    let apiKey = "tasksecretkey123"
    
    // MARK: - API Methods
    
    //GET /tasks
    func fetchTasks(priority: String? = nil, status: String? = nil, completion: @escaping (Result<[Task], TaskServiceError>) -> Void) {
        var urlComponents = URLComponents(string: apiURL)!
        var queryItems: [URLQueryItem] = []
        
        if let priority = priority { queryItems.append(URLQueryItem(name: "priority", value: priority)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        performRequest(request: request, completion: completion)
    }
    
    //POST /tasks
    func createTask(task: Task, completion: @escaping (Result<Task, TaskServiceError>) -> Void) {
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // Convert to dictionary with server-compatible keys
        let taskData: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "dueDate": task.dueDate,
            "priority": task.priority,
            "status": task.status
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: taskData)
            performRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    //PUT /tasks/:id
    func updateTask(task: Task, completion: @escaping (Result<Task, TaskServiceError>) -> Void) {
        guard let id = task.id else {
            completion(.failure(.invalidData("Task ID is missing")))
            return
        }
        
        var request = URLRequest(url: URL(string: "\(apiURL)/\(id)")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let taskData: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "dueDate": task.dueDate,
            "priority": task.priority,
            "status": task.status
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: taskData)
            performRequest(request: request, completion: completion)
        } catch {
            completion(.failure(.encodingError(error)))
        }
    }
    
    //DELETE /tasks/:id
    func deleteTask(id: String, completion: @escaping (Result<Void, TaskServiceError>) -> Void) {
        var request = URLRequest(url: URL(string: "\(apiURL)/\(id)")!)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 401:
                completion(.failure(.unauthorized))
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
        }.resume()
    }
    
    // MARK: - Helper Methods
    
    private func performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, TaskServiceError>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedObject = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case 401:
                completion(.failure(.unauthorized))
            case 404:
                completion(.failure(.notFound))
            default:
                completion(.failure(.serverError(httpResponse.statusCode)))
            }
        }.resume()
    }
}

// MARK: - Error Types

enum TaskServiceError: Error {
    case networkError(Error)
    case invalidData(String)
    case decodingError(Error)
    case encodingError(Error)
    case unauthorized
    case notFound
    case serverError(Int)
    case noData
    case invalidResponse
    
    var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access. Check your API key."
        case .notFound:
            return "Resource not found."
        case .serverError(let code):
            return "Server error with status code: \(code)"
        case .noData:
            return "No data received from server."
        case .invalidResponse:
            return "Invalid response from server."
        }
    }
}
