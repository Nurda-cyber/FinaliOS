import UIKit
import ARKit

// MARK: - TasksView

class TasksView: UIView {

    let tableView = UITableView()

    let profileButton = UIButton(type: .system)
    let addTaskButton = UIButton(type: .system)
    let tasksButton = UIButton(type: .system)
    let inProgressButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    let arButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        tableView.layer.cornerRadius = 15
        tableView.register(TaskCell.self, forCellReuseIdentifier: "TaskCell")
        addSubview(tableView)

        func configureButton(_ button: UIButton, icon: String, tintColor: UIColor) {
            button.setImage(UIImage(systemName: icon), for: .normal)
            button.tintColor = tintColor
        }

        configureButton(profileButton, icon: "person.circle", tintColor: .systemBlue)
        configureButton(addTaskButton, icon: "plus.circle.fill", tintColor: .systemGreen)
        configureButton(tasksButton, icon: "list.bullet", tintColor: .systemGray)
        configureButton(inProgressButton, icon: "clock.arrow.circlepath", tintColor: .systemOrange)
        configureButton(doneButton, icon: "checkmark.circle", tintColor: .systemGreen)
        configureButton(arButton, icon: "arkit", tintColor: .systemPurple)
    }

    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)

        // StackView құрамыз
        let buttonStack = UIStackView(arrangedSubviews: [
            inProgressButton,
            profileButton,
            addTaskButton,
            tasksButton,
            arButton,
            doneButton
        ])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .equalSpacing
        buttonStack.alignment = .center
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonStack)

        NSLayoutConstraint.activate([
            // TableView constraints
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -80),

            // StackView constraints
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
        ])

        // Барлық батырмалардың өлшемі бірдей
        [inProgressButton, profileButton, addTaskButton, tasksButton, arButton, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 40).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
    }
}
