import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskViewModel()
    @State private var showAddTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var selectedTask: Task?
    @State private var showDeleteConfirmation = false
    @State private var taskToDelete: String?
    
    // Modern color scheme
    let accentColor = Color(red: 0.0, green: 0.6, blue: 0.5)  // Teal
    let secondaryAccentColor = Color(red: 0.0, green: 0.7, blue: 0.4)  // Green
    let backgroundColor1 = Color(red: 0.97, green: 0.97, blue: 0.97)  // Light gray
    let backgroundColor2 = Color(red: 0.9, green: 0.95, blue: 0.93)  // Light minty gray
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor1, backgroundColor2]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Custom navigation header
                HStack {
                    Text("My Tasks")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    // Filter button
                    Menu {
                        Section(header: Text("Priority")) {
                            Button("All", action: {
                                viewModel.setFilters(priority: nil, status: viewModel.statusFilter)
                            })
                            Button("High", action: {
                                viewModel.setFilters(priority: "high", status: viewModel.statusFilter)
                            })
                            Button("Medium", action: {
                                viewModel.setFilters(priority: "medium", status: viewModel.statusFilter)
                            })
                            Button("Low", action: {
                                viewModel.setFilters(priority: "low", status: viewModel.statusFilter)
                            })
                        }
                        
                        Section(header: Text("Status")) {
                            Button("All", action: {
                                viewModel.setFilters(priority: viewModel.priorityFilter, status: nil)
                            })
                            Button("Pending", action: {
                                viewModel.setFilters(priority: viewModel.priorityFilter, status: "pending")
                            })
                            Button("Completed", action: {
                                viewModel.setFilters(priority: viewModel.priorityFilter, status: "completed")
                            })
                        }
                        
                        Section(header: Text("Reset")) {
                            Button("Show All Tasks", action: {
                                viewModel.setFilters(priority: nil, status: nil)
                            })
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(accentColor)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(accentColor.opacity(0.1))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                // Active filters display
                HStack(spacing: 12) {
                    if let priorityFilter = viewModel.priorityFilter {
                        FilterChip(text: "Priority: \(priorityFilter.capitalized)", color: accentColor) {
                            viewModel.setFilters(priority: nil, status: viewModel.statusFilter)
                        }
                    }
                    
                    if let statusFilter = viewModel.statusFilter {
                        FilterChip(text: "Status: \(statusFilter.capitalized)", color: secondaryAccentColor) {
                            viewModel.setFilters(priority: viewModel.priorityFilter, status: nil)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, viewModel.priorityFilter != nil || viewModel.statusFilter != nil ? 15 : 0)
                .opacity(viewModel.priorityFilter != nil || viewModel.statusFilter != nil ? 1 : 0)
                .frame(height: viewModel.priorityFilter != nil || viewModel.statusFilter != nil ? nil : 0)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: accentColor))
                        .padding()
                    Spacer()
                } else if viewModel.filteredTasks.isEmpty {
                    EmptyTasksView(
                        accentColor: accentColor,
                        onCreateTask: { showAddTaskSheet = true }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskCard(
                                    task: task,
                                    accentColor: accentColor,
                                    secondaryAccentColor: secondaryAccentColor
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                    showEditTaskSheet = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        selectedTask = task
                                        showEditTaskSheet = true
                                    }) {
                                        Label("Edit Task", systemImage: "pencil")
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        taskToDelete = task.id
                                        showDeleteConfirmation = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                }
                
                if let error = viewModel.error {
                    Text(error)
                        .font(.subheadline)
                        .padding(10)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                        .padding()
                }
            }
            
            // Add task button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showAddTaskSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [accentColor, secondaryAccentColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.trailing, 25)
                    .padding(.bottom, 25)
                }
            }
        }
        .sheet(isPresented: $showAddTaskSheet) {
            TaskEditSheetView(
                viewModel: TaskEditViewModel(),
                isPresented: $showAddTaskSheet,
                accentColor: accentColor,
                secondaryAccentColor: secondaryAccentColor,
                onSave: { task in
                    viewModel.addTask(task)
                }
            )
        }
        .sheet(isPresented: $showEditTaskSheet) {
            if let task = selectedTask {
                TaskEditSheetView(
                    viewModel: TaskEditViewModel(task: task),
                    isPresented: $showEditTaskSheet,
                    accentColor: accentColor,
                    secondaryAccentColor: secondaryAccentColor,
                    onSave: { updatedTask in
                        viewModel.updateTask(updatedTask)
                    }
                )
            }
        }
        .alert("Delete Task", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let id = taskToDelete {
                    viewModel.deleteTask(id: id)
                    taskToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this task? This action cannot be undone.")
        }
        .onAppear {
            viewModel.loadTasks()
        }
        .refreshable {
            viewModel.loadTasks()
        }
    }
}

// Filter Chip Component
struct FilterChip: View {
    let text: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.footnote)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .padding(4)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .cornerRadius(16)
    }
}

// Preview provider for SwiftUI canvas
struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView()
    }
}
