//
//  TaskEditViewModel.swift
//  TaskApp
//
//  Created by Muhammad Choudhary on 2025-03-12.
//

import SwiftUI
import Combine

// TaskEditViewModel for task editing
class TaskEditViewModel: ObservableObject {
    private let service = TaskService.shared
    
    @Published var task: Task
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var isSaved: Bool = false
    
    // Date formatter for converting between Date and String
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    @Published var selectedDate: Date
    
    init(task: Task = Task(title: "", dueDate: "", description: "", priority: "medium", status: "pending")) {
        self.task = task
        
        // Initialize date picker with existing date or current date
        if !task.dueDate.isEmpty, let date = dateFormatter.date(from: task.dueDate) {
            self.selectedDate = date
        } else {
            self.selectedDate = Date()
            // Set default due date
            self.task.dueDate = dateFormatter.string(from: Date())
        }
    }
    
    func updateDueDate() {
        task.dueDate = dateFormatter.string(from: selectedDate)
    }
    
    func saveTask(completion: @escaping (Task) -> Void) {
        isLoading = true
        error = nil
        
        // Update due date from selected date
        updateDueDate()
        
        let saveOperation = task.id == nil ? service.createTask : service.updateTask
        
        saveOperation(task) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let savedTask):
                    self?.task = savedTask
                    self?.isSaved = true
                    completion(savedTask)
                case .failure(let serviceError):
                    self?.error = serviceError.localizedDescription
                }
            }
        }
    }
    
    // Validation helpers
    var isValid: Bool {
        return !task.title.isEmpty && !task.dueDate.isEmpty
    }
}

// TaskEditView for adding/editing tasks
struct TaskEditView: View {
    @ObservedObject var viewModel: TaskEditViewModel
    @Binding var isPresented: Bool
    var onSave: (Task) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $viewModel.task.title)
                    
                    TextField("Description", text: $viewModel.task.description)
                        .frame(height: 100, alignment: .top)
                        .multilineTextAlignment(.leading)
                    
                    DatePicker("Due Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .onChange(of: viewModel.selectedDate) { _ in
                            viewModel.updateDueDate()
                        }
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $viewModel.task.priority) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $viewModel.task.status) {
                        Text("Pending").tag("pending")
                        Text("Completed").tag("completed")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                
                if let error = viewModel.error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(viewModel.task.id == nil ? "Add Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveTask { savedTask in
                            onSave(savedTask)
                            isPresented = false
                        }
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}
