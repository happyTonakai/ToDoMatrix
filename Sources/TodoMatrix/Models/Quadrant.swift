import Foundation

enum Quadrant: String, CaseIterable, Codable, Identifiable {
    case q1 = "重要且紧急"
    case q2 = "不重要但紧急"
    case q3 = "重要不紧急"
    case q4 = "不重要不紧急"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var englishName: String {
        switch self {
        case .q1: return "Do First"
        case .q2: return "Delegate"
        case .q3: return "Schedule"
        case .q4: return "Eliminate"
        }
    }
    
    var borderPosition: BorderPosition {
        switch self {
        case .q1, .q3: return .leading
        case .q2: return .top
        case .q4: return .bottom
        }
    }
    
    enum BorderPosition {
        case leading, top, bottom, trailing
    }
}
