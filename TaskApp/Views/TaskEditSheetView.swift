import SwiftUI

// Modern Task Edit View
struct TaskEditSheetView: View {
    @ObservedObject var viewModel: TaskEditViewModel
    @Binding var isPresented: Bool
    let accentColor: Color
    let secondaryAccentColor: Color
    var onSave: (Task) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.97, green: 0.97, blue: 0.97), Color(red: 0.95, green: 0.98, blue: 0.97)]),
                    startPoint: .top,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Title field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Task Title")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextField("Enter task title", text: $viewModel.task.title)
                                .font(.body)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                        
                        // Description field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            TextEditor(text: $viewModel.task.description)
                                .frame(minHeight: 100)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                        }
                        
                        // Due date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Due Date")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .frame(maxHeight: 400)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                                .onChange(of: viewModel.selectedDate) { _ in
                                    viewModel.updateDueDate()
                                }
                        }
                        
                        // Priority selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Priority")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                PriorityButton(
                                    title: "Low",
                                    color: secondaryAccentColor,
                                    isSelected: viewModel.task.priority == "low",
                                    action: { viewModel.task.priority = "low" }
                                )
                                
                                PriorityButton(
                                    title: "Medium",
                                    color: .orange,
                                    isSelected: viewModel.task.priority == "medium",
                                    action: { viewModel.task.priority = "medium" }
                                )
                                
                                PriorityButton(
                                    title: "High",
                                    color: .red,
                                    isSelected: viewModel.task.priority == "high",
                                    action: { viewModel.task.priority = "high" }
                                )
                            }
                        }
                        
                        // Status selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Status")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 15) {
                                StatusButton(
                                    title: "Pending",
                                    color: accentColor,
                                    isSelected: viewModel.task.status == "pending",
                                    action: { viewModel.task.status = "pending" }
                                )
                                
                                StatusButton(
                                    title: "Completed",
                                    color: secondaryAccentColor,
                                    isSelected: viewModel.task.status == "completed",
                                    action: { viewModel.task.status = "completed" }
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(viewModel.task.id == nil ? "Create Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        viewModel.saveTask { savedTask in
                            onSave(savedTask)
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewModel.isValid ? accentColor : .gray)
                    }
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
}

// Custom Priority Button
struct PriorityButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Circle()
                    .fill(color.opacity(isSelected ? 1.0 : 0.2))
                    .frame(width: 16, height: 16)
                
                Text(title)
                    .font(.footnote)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isSelected ? color.opacity(0.1) : Color.white,
                        isSelected ? color.opacity(0.05) : Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Custom Status Button
struct StatusButton: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? color : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            isSelected ? color.opacity(0.1) : Color.white,
                            isSelected ? color.opacity(0.05) : Color.white
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? color : Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskEditSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TaskEditSheetView(
            viewModel: TaskEditViewModel(),
            isPresented: .constant(true),
            accentColor: Color(red: 0.0, green: 0.6, blue: 0.5),
            secondaryAccentColor: Color(red: 0.0, green: 0.7, blue: 0.4),
            onSave: { _ in }
        )
    }
}
