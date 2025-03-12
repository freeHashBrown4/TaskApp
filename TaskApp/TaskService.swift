import Foundation

class TaskService {
    static let shared = TaskService()
    private let apiURL = "http://localhost:3000/tasks"
    private let apiKey = "tasksecretkey123"
    
    func fetchTasks(priority: String? = nil, status: String? = nil, completion: @escaping (Result<[Task], Error>) -> Void) {
        var urlComponents = URLComponents(string: apiURL)!
        var queryItems: [URLQueryItem] = []
        if let priority = priority { queryItems.append(URLQueryItem(name: "priority", value: priority)) }
        if let status = status { queryItems.append(URLQueryItem(name: "status", value: status)) }
        urlComponents.queryItems = queryItems
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                completion(.success(tasks))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createTask(task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let taskData: [String: Any] = [
            "title": task.title,
            "description": task.description,
            "dueDate": task.dueDate,
            "priority": task.priority,
            "status": task.status
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: taskData, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            do {
                let newTask = try JSONDecoder().decode(Task.self, from: data)
                completion(.success(newTask))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func updateTask(task: Task, completion: @escaping (Result<Task, Error>) -> Void) {
        guard let id = task.id else {
            completion(.failure(NSError(domain: "Invalid ID", code: -1, userInfo: nil)))
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

        request.httpBody = try? JSONSerialization.data(withJSONObject: taskData, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: -1, userInfo: nil)))
                return
            }
            do {
                let updatedTask = try JSONDecoder().decode(Task.self, from: data)
                completion(.success(updatedTask))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func deleteTask(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(apiURL)/\(id)")!)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }
}

