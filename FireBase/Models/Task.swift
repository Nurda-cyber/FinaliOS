import Foundation
import FirebaseFirestore

struct Task {
    let id: String
    let title: String
    let description: String
    let status: String

    init(id: String, title: String, description: String, status: String) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let status = data["status"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.title = title
        self.description = description
        self.status = status
    }

    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "description": description,
            "status": status
        ]
    }
}
