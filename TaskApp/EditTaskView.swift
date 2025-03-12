//
//  EditTaskView.swift
//  TaskApp
//
//  Created by Muhammad Choudhary on 2025-03-07.
//

import SwiftUI

struct EditTaskView: View {
    @State var task: Task
    @Binding var isEditing: Bool
    var updateTask: (Task) -> Void

    var body: some View {
        NavigationView {
//            ScrollView {
                Form {
                    TextField("Title", text: $task.title)
                    TextField("Description", text: $task.description)
                    TextField("Due Date", text: $task.dueDate)
                    
                    Picker("Priority", selection: $task.priority) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Status", selection: $task.status) {
                        Text("Pending").tag("pending")
                        Text("Completed").tag("completed")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
//            }
//            .scrollDismissesKeyboard(.interactively)
//            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updateTask(task)
                        isEditing = false
                    }
                }
            }
        }
    }
}

