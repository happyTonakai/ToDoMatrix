import SwiftUI

struct QuadrantView: View {
    let quadrant: Quadrant
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isAddingTask = false
    @State private var newTaskTitle = ""
    @State private var isTargeted = false
    @FocusState private var isTextFieldFocused: Bool
    
    private var tasks: [Task] {
        viewModel.tasks(for: quadrant)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            
            if isAddingTask {
                addTaskField
            }
            
            taskListView
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(borderOverlay)
        .contentShape(Rectangle())
        .onTapGesture {
            if isAddingTask {
                confirmTask()
            } else {
                startAddingTask()
            }
        }
        .dropDestination(for: String.self) { items, location in
            handleQuadrantDrop(items)
        } isTargeted: { targeted in
            isTargeted = targeted
        }
        .overlay(targetedOverlay)
    }
    
    private var headerView: some View {
        HStack {
            Text(quadrant.displayName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("(\(quadrant.englishName))")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private var addTaskField: some View {
        HStack {
            TextField("输入任务标题", text: $newTaskTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .focused($isTextFieldFocused)
                .onSubmit {
                    confirmTask()
                }
                .onExitCommand {
                    cancelAddTask()
                }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    @ViewBuilder
    private var taskListView: some View {
        if tasks.isEmpty && !isAddingTask {
            Text("点击添加任务")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 3) {
                    ForEach(tasks) { task in
                        TaskRowView(task: task, quadrant: quadrant)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private var backgroundColor: Color {
        Color(nsColor: .controlBackgroundColor)
    }
    
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(quadrantBorderColor, lineWidth: 4)
    }
    
    private var targetedOverlay: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(quadrant.borderColor.opacity(isTargeted ? 0.5 : 0), lineWidth: 2)
    }
    
    private var quadrantBorderColor: Color {
        switch quadrant.borderPosition {
        case .leading: return quadrant.borderColor
        case .top: return quadrant.borderColor
        case .bottom: return quadrant.borderColor
        case .trailing: return Color.clear
        }
    }
    
    private func startAddingTask() {
        isAddingTask = true
        newTaskTitle = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isTextFieldFocused = true
        }
    }
    
    private func handleQuadrantDrop(_ items: [String]) -> Bool {
        guard let item = items.first,
              item.hasPrefix("task:") else { return false }
        
        let taskIdString = String(item.dropFirst(5))
        guard let taskId = UUID(uuidString: taskIdString),
              let draggedTask = viewModel.tasks.first(where: { $0.id == taskId }) else { return false }
        
        if draggedTask.quadrant != quadrant {
            viewModel.moveTask(draggedTask, to: quadrant)
        }
        return true
    }
    
    private func confirmTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            viewModel.createTask(title: trimmed, in: quadrant)
        }
        newTaskTitle = ""
        isAddingTask = false
        isTextFieldFocused = false
    }
    
    private func cancelAddTask() {
        newTaskTitle = ""
        isAddingTask = false
        isTextFieldFocused = false
    }
}

struct TaskRowView: View {
    let task: Task
    let quadrant: Quadrant
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isEditing = false
    @State private var newSubtaskTitle = ""
    @State private var isAddingSubtask = false
    @State private var isShowingCompleted = false
    @State private var isDragging = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Button(action: {
                    viewModel.completeTask(task)
                }) {
                    Image(systemName: "circle")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                
                Text(task.title)
                    .font(.system(size: 13))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDragging ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .shadow(color: isDragging ? Color.primary.opacity(0.15) : Color.clear, radius: 4, x: 0, y: 2)
            .onDrag {
                isDragging = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isDragging = false
                }
                return NSItemProvider(object: "task:\(task.id.uuidString)" as NSString)
            }
            .contextMenu {
                Button("编辑") {
                    isEditing = true
                }
            }
            .simultaneousGesture(
                TapGesture(count: 2).onEnded {
                    isEditing = true
                }
            )
            .sheet(isPresented: $isEditing) {
                EditTaskView(task: task, isPresented: $isEditing)
            }
            
            if task.hasSubtasks {
                subtasksList
            }
            
            if isAddingSubtask {
                addSubtaskField
            }
        }
    }
    
    @ViewBuilder
    private var subtasksList: some View {
        let uncompletedSubtasks = task.subtasks?.filter { !$0.isCompleted } ?? []
        let completedSubtasks = task.subtasks?.filter { $0.isCompleted } ?? []
        
        VStack(alignment: .leading, spacing: 2) {
            ForEach(uncompletedSubtasks) { subtask in
                SubtaskRowView(subtask: subtask, task: task)
            }
            
            if !completedSubtasks.isEmpty {
                Button(action: {
                    isShowingCompleted.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isShowingCompleted ? "eye.slash" : "eye")
                            .font(.system(size: 12))
                        Text(isShowingCompleted ? "隐藏已完成" : "显示已完成 (\(completedSubtasks.count))")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .padding(.leading, 36)
                .padding(.top, 4)
                
                if isShowingCompleted {
                    ForEach(completedSubtasks) { subtask in
                        SubtaskRowView(subtask: subtask, task: task)
                    }
                }
            }
            
            Button(action: {
                isAddingSubtask = true
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12))
                    Text("添加子任务")
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 36)
            .padding(.top, 4)
        }
    }
    
    private var addSubtaskField: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 18, height: 18)
            
            TextField("子任务", text: $newSubtaskTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .onSubmit {
                    addSubtask()
                }
                .onExitCommand {
                    isAddingSubtask = false
                    newSubtaskTitle = ""
                }
        }
        .padding(.leading, 36)
        .padding(.vertical, 4)
    }
    
    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            isAddingSubtask = false
            newSubtaskTitle = ""
            return
        }
        viewModel.addSubtask(trimmed, to: task)
        newSubtaskTitle = ""
        isAddingSubtask = false
    }
}

struct SubtaskRowView: View {
    let subtask: Subtask
    let task: Task
    @EnvironmentObject var viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                viewModel.toggleSubtask(subtask, in: task)
            }) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14))
                    .foregroundColor(subtask.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            Text(subtask.title)
                .font(.system(size: 12))
                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                .strikethrough(subtask.isCompleted)
                .draggable("subtask:\(subtask.id.uuidString)")
            
            Spacer()
            
            Button(action: {
                viewModel.removeSubtaskAndPromote(subtask: subtask, from: task.id)
            }) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.leading, 36)
    }
}
