import SwiftUI

struct TaskListView: View {
    @State private var tasks: [Task] = []
    @State private var priorityFilter: String = ""
    @State private var statusFilter: String = ""
    @State private var newTask = Task(id: nil, title: "", dueDate: "", description: "", priority: "low", status: "pending")
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Picker("Priority", selection: $priorityFilter) {
                        Text("All").tag("")
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Picker("Status", selection: $statusFilter) {
                        Text("All").tag("")
                        Text("Pending").tag("pending")
                        Text("Completed").tag("completed")
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Button("Filter") {
                        fetchTasks()
                    }
                }
                .padding()
                
                List {
                    ForEach(tasks, id: \.id) { task in
                        NavigationLink(destination: EditTaskView(task: task, isEditing: .constant(true), updateTask: updateTask)) {
                            VStack(alignment: .leading) {
                                Text(task.title).font(.headline)
                                Text(task.description).font(.subheadline)
                                Text("Due: \(task.dueDate)").font(.caption)
                                Text("Priority: \(task.priority)")
                                Text("Status: \(task.status)")
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
                
                VStack {
                    TextField("Title", text: $newTask.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Description", text: $newTask.description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Due Date", text: $newTask.dueDate)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Priority", selection: $newTask.priority) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Status", selection: $newTask.status) {
                        Text("Pending").tag("pending")
                        Text("Completed").tag("completed")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Create Task") {
                        createTask()
                    }
                }
                .padding()
            }
            .navigationTitle("Task Manager")
            .onAppear {
                fetchTasks()
            }
        }
    }
    
    func fetchTasks() {
        TaskService.shared.fetchTasks(priority: priorityFilter, status: statusFilter) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedTasks):
                    tasks = fetchedTasks
                case .failure(let error):
                    print("Error fetching tasks: \(error)")
                }
            }
        }
    }
    
    func createTask() {
        TaskService.shared.createTask(task: newTask) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let createdTask):
                    tasks.append(createdTask)
                    newTask = Task(id: nil, title: "", dueDate: "", description: "", priority: "low", status: "pending")
                case .failure(let error):
                    print("Error creating task: \(error)")
                }
            }
        }
    }
    
    // ✅ FIX: Add the `deleteTask` function
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            guard let taskId = task.id else { return }
            TaskService.shared.deleteTask(id: taskId) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        tasks.remove(at: index)
                    case .failure(let error):
                        print("Error deleting task: \(error)")
                    }
                }
            }
        }
    }
    
    // ✅ FIX: Add the `updateTask` function
    func updateTask(updatedTask: Task) {
        TaskService.shared.updateTask(task: updatedTask) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updatedTask):
                    if let index = tasks.firstIndex(where: { $0.id == updatedTask.id }) {
                        tasks[index] = updatedTask
                    }
                case .failure(let error):
                    print("Error updating task: \(error)")
                }
            }
        }
    }
}
