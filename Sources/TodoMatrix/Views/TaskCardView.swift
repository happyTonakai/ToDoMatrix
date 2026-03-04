import SwiftUI

struct TaskCardView: View {
    let task: Task
    @Binding var isEditing: Bool
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var opacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    viewModel.completeTask(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    if let dueDate = task.dueDate {
                        HStack(spacing: 2) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(formatDate(dueDate))
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if task.hasSubtasks {
                        HStack(spacing: 2) {
                            Image(systemName: "checklist")
                                .font(.system(size: 10))
                            Text("\(task.completedSubtaskCount)/\(task.totalSubtaskCount)")
                                .font(.system(size: 11))
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .opacity(opacity)
        .simultaneousGesture(
            TapGesture(count: 2).onEnded {
                isEditing = true
            }
        )
        .contextMenu {
            Button("编辑") {
                isEditing = true
            }
        }
        .draggable(task.id.uuidString)
        .sheet(isPresented: $isEditing) {
            EditTaskView(task: task, isPresented: $isEditing)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}
