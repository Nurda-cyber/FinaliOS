import XCTest
@testable import FireBase

// Мок қызмет (реаль TaskService орнына)
class MockTaskService: TaskService {
    var fetchTasksCalled = false
    var fetchTasksCompletion: (([Task]) -> Void)?

    override func fetchTasks(completion: @escaping ([Task]) -> Void) {
        fetchTasksCalled = true
        fetchTasksCompletion = completion
    }

    override func deleteTask(id: String, completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }

    override func updateTaskStatus(id: String, to status: String, completion: ((Error?) -> Void)? = nil) {
        completion?(nil)
    }
}

final class TasksViewControllerTests: XCTestCase {

    var sut: TasksViewController!
    var mockTaskService: MockTaskService!

    override func setUp() {
        super.setUp()
        sut = TasksViewController()
        mockTaskService = MockTaskService()
        sut.taskService = mockTaskService
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockTaskService = nil
        super.tearDown()
    }

    func testFetchAllTasks_CallsFetchTasksAndReloadsTable() {
        // 1. Күтеміз (expectation)
        let expectation = self.expectation(description: "Tasks loaded")

        // 2. fetchAllTasks шақырамыз
        sut.fetchAllTasks()
        XCTAssertTrue(mockTaskService.fetchTasksCalled)

        // 3. Мок деректерді жібереміз
        let dummyTasks = [
            Task(id: "1", title: "Test1", description: "Desc1", status: "todo"),
            Task(id: "2", title: "Test2", description: "Desc2", status: "done")
        ]
        mockTaskService.fetchTasksCompletion?(dummyTasks)

        // 4. Нәтижені main queue-да тексереміз
        DispatchQueue.main.async {
            XCTAssertEqual(self.sut.tasks.count, 2)
            XCTAssertEqual(self.sut.tasks[0].title, "Test1")
            expectation.fulfill()
        }

        // 5. Күтуді бастаймыз
        wait(for: [expectation], timeout: 1.0)
    }

    func testDeleteTask_RemovesTaskFromArray() {
        let expectation = self.expectation(description: "Task deleted")

        sut.tasks = [
            Task(id: "1", title: "Task1", description: "", status: "todo"),
            Task(id: "2", title: "Task2", description: "", status: "todo")
        ]

        sut.deleteTask(at: 0)

        DispatchQueue.main.async {
            XCTAssertEqual(self.sut.tasks.count, 1)
            XCTAssertEqual(self.sut.tasks[0].title, "Task2")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
