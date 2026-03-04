import Foundation

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var quadrant: Quadrant
    var dueDate: Date?
    var notes: String?
    var subtasks: [Subtask]?
    var isCompleted: Bool
    let createdAt: Date
    var completedAt: Date?
    var parentTaskId: UUID?
    var sortOrder: Int
    
    init(
        id: UUID = UUID(),
        title: String,
        quadrant: Quadrant,
        dueDate: Date? = nil,
        notes: String? = nil,
        subtasks: [Subtask]? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        parentTaskId: UUID? = nil,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.quadrant = quadrant
        self.dueDate = dueDate
        self.notes = notes
        self.subtasks = subtasks
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.parentTaskId = parentTaskId
        self.sortOrder = sortOrder
    }
    
    var hasSubtasks: Bool {
        guard let subtasks = subtasks else { return false }
        return !subtasks.isEmpty
    }
    
    var completedSubtaskCount: Int {
        subtasks?.filter { $0.isCompleted }.count ?? 0
    }
    
    var totalSubtaskCount: Int {
        subtasks?.count ?? 0
    }
}
