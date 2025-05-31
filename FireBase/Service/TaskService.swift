import FirebaseFirestore

class TaskService {
    private let db = Firestore.firestore()

    func fetchTasks(completion: @escaping ([Task]) -> Void) {
        db.collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                print("Қате: \(error.localizedDescription)")
                completion([])
                return
            }

            let tasks = snapshot?.documents.compactMap { Task(document: $0) } ?? []
            completion(tasks)
        }
    }

    func fetchTasks(withStatus status: String, completion: @escaping ([Task]) -> Void) {
        db.collection("tasks").whereField("status", isEqualTo: status).getDocuments { snapshot, error in
            if let error = error {
                print("Қате: \(error.localizedDescription)")
                completion([])
                return
            }

            let tasks = snapshot?.documents.compactMap { Task(document: $0) } ?? []
            completion(tasks)
        }
    }

    func saveTask(_ task: Task, completion: ((Error?) -> Void)? = nil) {
        db.collection("tasks").addDocument(data: task.toDictionary(), completion: completion)
    }

    func deleteTask(id: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("tasks").document(id).delete(completion: completion)
    }

    func updateTaskStatus(id: String, to status: String, completion: ((Error?) -> Void)? = nil) {
        db.collection("tasks").document(id).updateData(["status": status], completion: completion)
    }
}
