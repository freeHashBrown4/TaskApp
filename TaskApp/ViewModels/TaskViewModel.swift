// MARK: - TaskViewModel.swift
import Foundation
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    private let service = TaskService.shared
    
    // MARK: - Published Properties (UI State)
    @Published var tasks: [Task] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var filteredTasks: [Task] = []
    
    // MARK: - Filter Properties
    @Published var priorityFilter: String? = nil
    @Published var statusFilter: String? = nil
    @Published var sortOption: SortOption = .dueDate
    
    enum SortOption {
        case dueDate, priority, title
    }
    
    // MARK: - Task Operations
    
    func loadTasks() {
        isLoading = true
        error = nil
        
        service.fetchTasks(priority: priorityFilter, status: statusFilter) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let fetchedTasks):
                    self?.tasks = fetchedTasks
                    self?.applyFiltersAndSort()
                case .failure(let serviceError):
                    self?.error = serviceError.localizedDescription
                }
            }
        }
    }
    
    func addTask(_ task: Task) {
        isLoading = true
        error = nil
        
        service.createTask(task: task) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let createdTask):
                    self?.tasks.append(createdTask)
                    self?.applyFiltersAndSort()
                case .failure(let serviceError):
                    self?.error = serviceError.localizedDescription
                }
            }
        }
    }
    
    func updateTask(_ task: Task) {
        isLoading = true
        error = nil
        
        service.updateTask(task: task) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let updatedTask):
                    // Update in local array
                    if let index = self?.tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                        self?.tasks[index] = updatedTask
                        self?.applyFiltersAndSort()
                    }
                case .failure(let serviceError):
                    self?.error = serviceError.localizedDescription
                }
            }
        }
    }
    
    func deleteTask(id: String) {
        isLoading = true
        error = nil
        
        service.deleteTask(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    // Remove from local array
                    self?.tasks.removeAll(where: { $0.id == id })
                    self?.applyFiltersAndSort()
                case .failure(let serviceError):
                    self?.error = serviceError.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Filtering and Sorting
    
    func applyFiltersAndSort() {
        // First apply any filters
        var result = tasks
        
        // Sort the results
        switch sortOption {
        case .dueDate:
            result.sort { $0.dueDate < $1.dueDate }
        case .priority:
            let priorityOrder = ["high": 0, "medium": 1, "low": 2]
            result.sort { priorityOrder[$0.priority, default: 3] < priorityOrder[$1.priority, default: 3] }
        case .title:
            result.sort { $0.title < $1.title }
        }
        
        filteredTasks = result
    }
    
    func setFilters(priority: String?, status: String?) {
        self.priorityFilter = priority
        self.statusFilter = status
        loadTasks() // Reloading from API with new filters
    }
    
    func setSortOption(_ option: SortOption) {
        self.sortOption = option
        applyFiltersAndSort()
    }
    
    // MARK: - UI Helpers
    
    func priorityColor(for priority: String) -> Color {
        switch priority.lowercased() {
        case "high":
            return .red
        case "medium":
            return .orange
        case "low":
            return .green
        default:
            return .gray
        }
    }
    
    func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "completed":
            return .blue
        case "pending":
            return .gray
        default:
            return .gray
        }
    }
}
