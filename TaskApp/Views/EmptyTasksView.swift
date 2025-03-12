import SwiftUI

struct EmptyTasksView: View {
    let accentColor: Color
    let onCreateTask: () -> Void
    
    var body: some View {
        Spacer()
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 70))
                .foregroundColor(accentColor.opacity(0.7))
            
            Text("No Tasks Found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Add a new task to get started")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onCreateTask) {
                Text("Create Task")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(accentColor)
                    .cornerRadius(25)
            }
            .padding(.top, 10)
        }
        Spacer()
    }
}

struct EmptyTasksView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyTasksView(
            accentColor: Color(red: 0.0, green: 0.6, blue: 0.5),
            onCreateTask: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
}

