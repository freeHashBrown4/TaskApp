import SwiftUI

// Modern Task Card
struct TaskCard: View {
    let task: Task
    let accentColor: Color
    let secondaryAccentColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(priorityText)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(priorityColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(priorityColor.opacity(0.15))
                    .cornerRadius(8)
            }
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(Color(.darkGray))
                    .lineLimit(2)
                    .padding(.bottom, 4)
            }
            
            HStack {
                // Due date
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(task.dueDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status tag
                Text(task.status.capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.white.opacity(0.95)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var priorityColor: Color {
        switch task.priority.lowercased() {
        case "high":
            return Color.red
        case "medium":
            return Color.orange
        case "low":
            return secondaryAccentColor
        default:
            return .gray
        }
    }
    
    private var statusColor: Color {
        switch task.status.lowercased() {
        case "completed":
            return secondaryAccentColor
        case "pending":
            return accentColor
        default:
            return .gray
        }
    }
    
    private var priorityText: String {
        switch task.priority.lowercased() {
        case "high":
            return "High"
        case "medium":
            return "Medium"
        case "low":
            return "Low"
        default:
            return "-"
        }
    }
}

struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTask = Task(
            id: "1",
            title: "Sample Task",
            dueDate: "Mar 15, 2025",
            description: "This is a sample task description for preview purposes.",
            priority: "high",
            status: "pending"
        )
        
        TaskCard(
            task: sampleTask,
            accentColor: Color(red: 0.0, green: 0.6, blue: 0.5),
            secondaryAccentColor: Color(red: 0.0, green: 0.7, blue: 0.4)
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
