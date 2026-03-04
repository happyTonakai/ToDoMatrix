import XCTest
@testable import TodoMatrix

final class TaskTests: XCTestCase {
    func testTaskCreation() throws {
        let task = Task(title: "Test Task", quadrant: .q1)
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.quadrant, .q1)
        XCTAssertFalse(task.isCompleted)
        XCTAssertNil(task.completedAt)
    }
    
    func testSubtaskCreation() throws {
        let subtask = Subtask(title: "Test Subtask")
        XCTAssertEqual(subtask.title, "Test Subtask")
        XCTAssertFalse(subtask.isCompleted)
    }
    
    func testQuadrantDisplayNames() throws {
        XCTAssertEqual(Quadrant.q1.displayName, "重要且紧急")
        XCTAssertEqual(Quadrant.q2.displayName, "不重要但紧急")
        XCTAssertEqual(Quadrant.q3.displayName, "重要不紧急")
        XCTAssertEqual(Quadrant.q4.displayName, "不重要不紧急")
    }
    
    func testTaskWithSubtasks() throws {
        let subtasks = [
            Subtask(title: "Subtask 1"),
            Subtask(title: "Subtask 2", isCompleted: true)
        ]
        let task = Task(title: "Task with subtasks", quadrant: .q1, subtasks: subtasks)
        
        XCTAssertTrue(task.hasSubtasks)
        XCTAssertEqual(task.totalSubtaskCount, 2)
        XCTAssertEqual(task.completedSubtaskCount, 1)
    }
}
