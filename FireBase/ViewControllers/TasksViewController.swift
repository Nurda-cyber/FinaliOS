import UIKit
import FirebaseAuth

// MARK: - TasksViewController

class TasksViewController: UIViewController {

    private let tasksView = TasksView()

    var tasks: [Task] = []
    var taskService = TaskService()

    override func loadView() {
        view = tasksView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Тапсырмалар"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Шығу", style: .plain, target: self, action: #selector(signOut))

        setupActions()
        setupTableView()
        fetchAllTasks()
    }

    private func setupActions() {
        tasksView.profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)
        tasksView.addTaskButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        tasksView.tasksButton.addTarget(self, action: #selector(fetchAllTasks), for: .touchUpInside)
        tasksView.inProgressButton.addTarget(self, action: #selector(showInProgressTasks), for: .touchUpInside)
        tasksView.doneButton.addTarget(self, action: #selector(showDoneTasks), for: .touchUpInside)

        // AR батырмасына target
        tasksView.arButton.addTarget(self, action: #selector(openARView), for: .touchUpInside)
    }

    private func setupTableView() {
        tasksView.tableView.dataSource = self
        tasksView.tableView.delegate = self
    }

    @objc func fetchAllTasks() {
        taskService.fetchTasks { [weak self] tasks in
            DispatchQueue.main.async {
                self?.tasks = tasks
                self?.tasksView.tableView.reloadData()
            }
        }
    }

    @objc func showInProgressTasks() {
        taskService.fetchTasks(withStatus: "inProgress") { [weak self] tasks in
            DispatchQueue.main.async {
                self?.tasks = tasks
                self?.tasksView.tableView.reloadData()
            }
        }
    }

    @objc func showDoneTasks() {
        taskService.fetchTasks(withStatus: "done") { [weak self] tasks in
            DispatchQueue.main.async {
                self?.tasks = tasks
                self?.tasksView.tableView.reloadData()
            }
        }
    }

    @objc func addTask() {
        let alert = UIAlertController(title: "Жаңа тапсырма", message: "Атау мен сипаттаманы енгізіңіз", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Атау" }
        alert.addTextField { $0.placeholder = "Сипаттама" }

        alert.addAction(UIAlertAction(title: "Болдырмау", style: .cancel))
        alert.addAction(UIAlertAction(title: "Қосу", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let desc = alert.textFields?[1].text else { return }
            let newTask = Task(id: "", title: title, description: desc, status: "todo")
            self?.taskService.saveTask(newTask) { _ in self?.fetchAllTasks() }
        })
        present(alert, animated: true)
    }

    @objc func goToProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true)
        } catch {
            print("Шығу қатесі: \(error.localizedDescription)")
        }
    }

    @objc func openARView() {
        let arVC = TasksARViewController()
        navigationController?.pushViewController(arVC, animated: true)
    }

    func deleteTask(at index: Int) {
        let task = tasks[index]
        taskService.deleteTask(id: task.id) { [weak self] _ in
            self?.tasks.remove(at: index)
            DispatchQueue.main.async {
                self?.tasksView.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }

    func updateTaskStatus(task: Task, to status: String) {
        taskService.updateTaskStatus(id: task.id, to: status) { [weak self] _ in
            self?.fetchAllTasks()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let task = tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        cell.configure(with: task)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = tasks[indexPath.row]

        let detailVC = TaskDetailViewController()
        detailVC.taskID = task.id
        detailVC.taskTitle = task.title
        detailVC.taskDescription = task.description
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let task = tasks[indexPath.row]

        let delete = UIContextualAction(style: .destructive, title: "Өшіру") { [weak self] _, _, handler in
            self?.deleteTask(at: indexPath.row)
            handler(true)
        }

        let inProgress = UIContextualAction(style: .normal, title: "Орындалуда") { [weak self] _, _, handler in
            self?.updateTaskStatus(task: task, to: "inProgress")
            handler(true)
        }
        inProgress.backgroundColor = .systemOrange

        let done = UIContextualAction(style: .normal, title: "Дайын") { [weak self] _, _, handler in
            self?.updateTaskStatus(task: task, to: "done")
            handler(true)
        }
        done.backgroundColor = .systemGreen

        return UISwipeActionsConfiguration(actions: [delete, inProgress, done])
    }
}

// MARK: - TaskDetailViewControllerDelegate

extension TasksViewController: TaskDetailViewControllerDelegate {
    func taskDidUpdate() {
        fetchAllTasks()
    }
}

// MARK: - ARKit ViewController
