import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showDeleteConfirmation = false
    @State private var taskToDelete: Task?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("已完成任务")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !viewModel.completedTasks.isEmpty {
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("清空")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            if viewModel.completedTasks.isEmpty {
                Spacer()
                Text("暂无已完成任务")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.completedTasks) { task in
                            CompletedTaskRow(task: task) {
                                taskToDelete = task
                                viewModel.deleteTask(task)
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .frame(height: 300)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
        .padding(.horizontal, 16)
        .padding(.bottom, 60)
        .alert("清空已完成任务", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                viewModel.clearCompletedTasks()
                viewModel.showCompleted = false
            }
        } message: {
            Text("确定要清空所有已完成任务吗？此操作不可恢复。")
        }
    }
}

struct CompletedTaskRow: View {
    let task: Task
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(task.quadrant.borderColor)
                .frame(width: 8, height: 8)
            
            Text(task.title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Spacer()
            
            if let completedAt = task.completedAt {
                Text(formatDate(completedAt))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}
