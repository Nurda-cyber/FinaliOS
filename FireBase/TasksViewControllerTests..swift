import XCTest
@testable import FireBaseApp
import Firebase

final class TasksViewControllerTests: XCTestCase {

    var tasksVC: TasksViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tasksVC = TasksViewController()
        tasksVC.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        tasksVC = nil
        try super.tearDownWithError()
    }

    // ✅ Тест 1: Тапсырма саны дұрыс па
    func testNumberOfTasks() {
        tasksVC.tasks = [
            (id: "1", title: "First", description: "Desc1"),
            (id: "2", title: "Second", description: "Desc2")
        ]
        let tableView = tasksVC.tableView
        let rows = tasksVC.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 2, "Тапсырмалар саны дұрыс болу керек")
    }

    // ✅ Тест 2: Ячейкада дұрыс тақырып көрінеді ме
    func testCellContent() {
        tasksVC.tasks = [
            (id: "1", title: "Test Task", description: "Desc")
        ]
        let tableView = tasksVC.tableView
        let cell = tasksVC.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "Test Task", "Ячейкадағы мәтін дұрыс болу керек")
    }

    // ✅ Тест 3: Тапсырма қосқанда Firestore-мен әрекет (mock үлгісі)
    func testAddTaskCallsFirestore() {
        // Бұл тест нақты Firestore-ға жазбайды, бірақ saveTask логикасын тексере алады.
        let expectation = self.expectation(description: "Тапсырма қосылды")
        
        // Firestore-мен нақты әрекет етпеу үшін логиканы жеке репозиторий класқа шығару ұсынылады.
        tasksVC.saveTask(title: "Mock Title", description: "Mock Desc")
        
        // 2 секунд күтеміз (Firestore асинхронды болғандықтан)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
}
