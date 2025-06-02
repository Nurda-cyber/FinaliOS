import UIKit
import FirebaseFirestore

protocol TaskDetailViewControllerDelegate: AnyObject {
    func taskDidUpdate()
}

class TaskDetailViewController: UIViewController {

    var taskID: String?
    var taskTitle: String?
    var taskDescription: String?
    weak var delegate: TaskDetailViewControllerDelegate?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Атауы"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isEnabled = false
        return tf
    }()

    private let descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.cornerRadius = 8
        tv.isEditable = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private var isEditingTask = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Тапсырма мәліметі"

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Өңдеу", style: .plain, target: self, action: #selector(editButtonTapped))

        setupLayout()
        fillData()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),

            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 30),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 250),

            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    private func fillData() {
        titleTextField.text = taskTitle
        descriptionTextView.text = taskDescription
    }

    @objc private func editButtonTapped() {
        if isEditingTask {
            guard
                let id = taskID,
                let updatedTitle = titleTextField.text, !updatedTitle.isEmpty,
                let updatedDescription = descriptionTextView.text
            else {
                showAlert(title: "Қате", message: "Атауды бос қалдырмаңыз.")
                return
            }
            updateTaskInFirestore(id: id, title: updatedTitle, description: updatedDescription)
        } else {
            setEditingMode(true)
        }
    }

    private func setEditingMode(_ editing: Bool) {
        isEditingTask = editing
        titleTextField.isEnabled = editing
        descriptionTextView.isEditable = editing
        navigationItem.rightBarButtonItem?.title = editing ? "Сақтау" : "Өңдеу"
    }

    private func updateTaskInFirestore(id: String, title: String, description: String) {
        let db = Firestore.firestore()
        db.collection("tasks").document(id).updateData([
            "title": title,
            "description": description
        ]) { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Қате", message: "Жаңарту сәтсіз: \(error.localizedDescription)")
            } else {
                self.taskTitle = title
                self.taskDescription = description
                self.setEditingMode(false)
                self.delegate?.taskDidUpdate()

                // ✅ Мұнда alert көрсетеміз, OK басылса -> pop
                let alert = UIAlertController(title: "Сәтті", message: "Тапсырма жаңартылды", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            }
        }
    }


    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
