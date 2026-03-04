import SwiftUI

struct EditTaskView: View {
    let task: Task
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var title: String
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var notes: String
    @State private var subtasks: [Subtask]
    @State private var newSubtaskTitle = ""
    @State private var showDeleteConfirmation = false
    
    init(task: Task, isPresented: Binding<Bool>) {
        self.task = task
        self._isPresented = isPresented
        self._title = State(initialValue: task.title)
        self._dueDate = State(initialValue: task.dueDate)
        self._hasDueDate = State(initialValue: task.dueDate != nil)
        self._notes = State(initialValue: task.notes ?? "")
        self._subtasks = State(initialValue: task.subtasks ?? [])
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("编辑任务")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextField("任务标题", text: $title)
                            .textFieldStyle(.plain)
                            .font(.system(size: 14))
                            .padding(10)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("截止日期")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Toggle("启用截止日期", isOn: $hasDueDate)
                                .toggleStyle(.checkbox)
                            
                            Spacer()
                            
                            if hasDueDate {
                                DatePicker("", selection: Binding(
                                    get: { dueDate ?? Date() },
                                    set: { dueDate = $0 }
                                ), displayedComponents: .date)
                                .datePickerStyle(.field)
                                .labelsHidden()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("备注")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $notes)
                            .font(.system(size: 14))
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("子任务")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("添加子任务", text: $newSubtaskTitle)
                                .textFieldStyle(.plain)
                                .font(.system(size: 13))
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(6)
                                .onSubmit {
                                    addSubtask()
                                }
                            
                            Button(action: addSubtask) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                            .disabled(newSubtaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        
                        ForEach($subtasks) { $subtask in
                            HStack {
                                Button(action: {
                                    subtask.isCompleted.toggle()
                                }) {
                                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(subtask.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)
                                
                                Text(subtask.title)
                                    .font(.system(size: 13))
                                    .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                                    .strikethrough(subtask.isCompleted)
                                
                                Spacer()
                                
                                Button(action: {
                                    subtasks.removeAll { $0.id == subtask.id }
                                }) {
                                    Image(systemName: "trash")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(20)
            }
            
            Divider()
            
            HStack {
                Button(action: {
                    showDeleteConfirmation = true
                }) {
                    Text("删除")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button("取消") {
                    isPresented = false
                }
                .buttonStyle(.plain)
                
                Button("保存") {
                    saveTask()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(width: 450, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .alert("删除任务", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                viewModel.deleteTask(task)
                isPresented = false
            }
        } message: {
            Text("确定要删除该任务吗？")
        }
    }
    
    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        subtasks.append(Subtask(title: trimmed))
        newSubtaskTitle = ""
    }
    
    private func saveTask() {
        var updatedTask = task
        updatedTask.title = title.trimmingCharacters(in: .whitespaces)
        updatedTask.dueDate = hasDueDate ? dueDate : nil
        updatedTask.notes = notes.isEmpty ? nil : notes
        updatedTask.subtasks = subtasks.isEmpty ? nil : subtasks
        viewModel.updateTask(updatedTask)
        isPresented = false
    }
}
