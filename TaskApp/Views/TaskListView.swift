import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAddTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            VStack {
                // Sorting controls
                Picker("Sort by", selection: $viewModel.sortOption) {
                    Text("Due Date").tag(TaskViewModel.SortOption.dueDate)
                    Text("Priority").tag(TaskViewModel.SortOption.priority)
                    Text("Title").tag(TaskViewModel.SortOption.title)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.horizontal, .top])
                .onChange(of: viewModel.sortOption) { _ in
                    viewModel.applyFiltersAndSort()
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.filteredTasks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No tasks found")
                            .font(.headline)
                        Text("Add a new task to get started")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredTasks) { task in
                            TaskRow(task: task, viewModel: viewModel)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                    showEditTaskSheet = true
                                }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let taskToDelete = viewModel.filteredTasks[index]
                                if let id = taskToDelete.id {
                                    viewModel.deleteTask(id: id)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddTaskSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All Tasks") {
                            viewModel.setFilters(priority: nil, status: nil)
                        }
                        
                        Menu("Priority") {
                            Button("High Priority") {
                                viewModel.setFilters(priority: "high", status: viewModel.statusFilter)
                            }
                            Button("Medium Priority") {
                                viewModel.setFilters(priority: "medium", status: viewModel.statusFilter)
                            }
                            Button("Low Priority") {
                                viewModel.setFilters(priority: "low", status: viewModel.statusFilter)
                            }
                        }
                        
                        Menu("Status") {
                            Button("Pending") {
                                viewModel.setFilters(priority: viewModel.priorityFilter, status: "pending")
                            }
                            Button("Completed") {
                                viewModel.setFilters(priority: viewModel.priorityFilter, status: "completed")
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddTaskSheet) {
                TaskEditView(
                    viewModel: TaskEditViewModel(),
                    isPresented: $showAddTaskSheet,
                    onSave: { task in
                        viewModel.addTask(task)
                    }
                )
            }
            .sheet(isPresented: $showEditTaskSheet) {
                if let task = selectedTask {
                    TaskEditView(
                        viewModel: TaskEditViewModel(task: task),
                        isPresented: $showEditTaskSheet,
                        onSave: { updatedTask in
                            viewModel.updateTask(updatedTask)
                        }
                    )
                }
            }
            .onAppear {
                viewModel.loadTasks()
            }
            .refreshable {
                viewModel.loadTasks()
            }
        }
    }
}

// Task row for displaying an individual task
struct TaskRow: View {
    let task: Task
    let viewModel: TaskViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.headline)
                .lineLimit(1)
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label(task.dueDate, systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Priority tag
                Text(task.priority.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.priorityColor(for: task.priority))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                // Status tag
                Text(task.status.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(viewModel.statusColor(for: task.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// Preview provider for SwiftUI canvas
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}
