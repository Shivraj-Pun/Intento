import Foundation
import SwiftData

@Model
final class AppUser {
    @Attribute(.unique) var id: UUID
    var phone: String
    var name: String?
    
    init(id: UUID = UUID(), phone: String, name: String? = nil) {
        self.id = id
        self.phone = phone
        self.name = name
    }
}
