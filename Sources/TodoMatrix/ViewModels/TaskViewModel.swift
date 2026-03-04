import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var completedTasks: [Task] = []
    @Published var showCompleted: Bool = false
    
    private let persistenceManager = PersistenceManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTasks()
    }
    
    func tasks(for quadrant: Quadrant) -> [Task] {
        tasks.filter { $0.quadrant == quadrant && !$0.isCompleted && $0.parentTaskId == nil }
            .sorted { $0.createdAt > $1.createdAt }
    }
    
    func subtasks(for task: Task) -> [Subtask] {
        task.subtasks ?? []
    }
    
    func createTask(title: String, in quadrant: Quadrant) {
        let task = Task(title: title, quadrant: quadrant)
        tasks.append(task)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func completeTask(_ task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        var updatedTask = task
        updatedTask.isCompleted = true
        updatedTask.completedAt = Date()
        tasks.remove(at: index)
        completedTasks.insert(updatedTask, at: 0)
        saveTasks()
    }
    
    func uncompleteTask(_ task: Task) {
        guard let index = completedTasks.firstIndex(where: { $0.id == task.id }) else { return }
        var updatedTask = task
        updatedTask.isCompleted = false
        updatedTask.completedAt = nil
        completedTasks.remove(at: index)
        tasks.append(updatedTask)
        saveTasks()
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        completedTasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func moveTask(_ task: Task, to quadrant: Quadrant) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].quadrant = quadrant
            saveTasks()
        }
    }
    
    func reorderTask(from sourceIndex: Int, to destinationIndex: Int, in quadrant: Quadrant) {
        var quadrantTasks = tasks.filter { $0.quadrant == quadrant && $0.parentTaskId == nil }
        
        guard sourceIndex >= 0 && sourceIndex < quadrantTasks.count else { return }
        
        let taskToMove = quadrantTasks[sourceIndex]
        
        guard let taskToMoveId = quadrantTasks.first(where: { $0.id == taskToMove.id })?.id else { return }
        
        if let sourceTaskIndex = tasks.firstIndex(where: { $0.id == taskToMoveId }) {
            let task = tasks.remove(at: sourceTaskIndex)
            let targetPos = destinationIndex > quadrantTasks.count ? quadrantTasks.count : destinationIndex
            tasks.insert(task, at: min(targetPos, tasks.count))
        }
        
        saveTasks()
    }
    
    func moveTaskToPosition(taskId: UUID, toPosition: Int, in quadrant: Quadrant) {
        guard let sourceIndex = tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        let task = tasks.remove(at: sourceIndex)
        let targetPos = min(toPosition, tasks.count)
        tasks.insert(task, at: targetPos)
        
        saveTasks()
    }
    
    func addSubtask(_ subtaskTitle: String, to task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = tasks[index]
            var subtasks = updatedTask.subtasks ?? []
            subtasks.append(Subtask(title: subtaskTitle))
            updatedTask.subtasks = subtasks
            tasks[index] = updatedTask
            saveTasks()
        }
    }
    
    func toggleSubtask(_ subtask: Subtask, in task: Task) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = tasks[taskIndex]
            var subtasks = updatedTask.subtasks ?? []
            if let subtaskIndex = subtasks.firstIndex(where: { $0.id == subtask.id }) {
                subtasks[subtaskIndex].isCompleted.toggle()
                updatedTask.subtasks = subtasks
                tasks[taskIndex] = updatedTask
                saveTasks()
            }
        }
    }
    
    func deleteSubtask(_ subtask: Subtask, in task: Task) {
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = tasks[taskIndex]
            var subtasks = updatedTask.subtasks ?? []
            subtasks.removeAll { $0.id == subtask.id }
            updatedTask.subtasks = subtasks.isEmpty ? nil : subtasks
            tasks[taskIndex] = updatedTask
            saveTasks()
        }
    }
    
    func makeSubtask(childTaskId: UUID, parentTaskId: UUID) {
        guard let childIndex = tasks.firstIndex(where: { $0.id == childTaskId }),
              let parentIndex = tasks.firstIndex(where: { $0.id == parentTaskId }) else { return }
        
        var childTask = tasks[childIndex]
        var parentTask = tasks[parentIndex]
        
        var subtasks = parentTask.subtasks ?? []
        subtasks.append(Subtask(title: childTask.title))
        parentTask.subtasks = subtasks
        
        tasks[parentIndex] = parentTask
        tasks.remove(at: childIndex)
        
        saveTasks()
    }
    
    func removeSubtaskAndPromote(subtask: Subtask, from parentTaskId: UUID) {
        guard let parentIndex = tasks.firstIndex(where: { $0.id == parentTaskId }) else { return }
        
        var parentTask = tasks[parentIndex]
        var subtasks = parentTask.subtasks ?? []
        subtasks.removeAll { $0.id == subtask.id }
        parentTask.subtasks = subtasks.isEmpty ? nil : subtasks
        tasks[parentIndex] = parentTask
        
        let newTask = Task(title: subtask.title, quadrant: parentTask.quadrant)
        tasks.append(newTask)
        
        saveTasks()
    }
    
    func clearCompletedTasks() {
        completedTasks.removeAll()
        saveTasks()
    }
    
    private func loadTasks() {
        let loaded = persistenceManager.load()
        tasks = loaded.filter { !$0.isCompleted }
        completedTasks = loaded.filter { $0.isCompleted }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
    
    private func saveTasks() {
        let allTasks = tasks + completedTasks
        persistenceManager.save(allTasks)
    }
}
