import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let loginButton = UIButton(type: .system)
    let registerButton = UIButton(type: .system)
    
    let loadingIndicator = UIActivityIndicatorView(style: .medium)
    let stateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }

    func setupUI() {
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.backgroundColor = UIColor.secondarySystemBackground
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        emailTextField.layer.shadowOpacity = 0.1
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailTextField.layer.shadowRadius = 4
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = UIColor.secondarySystemBackground
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
        passwordTextField.layer.shadowOpacity = 0.1
        passwordTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordTextField.layer.shadowRadius = 4
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = UIColor.systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 10
        loginButton.layer.shadowColor = UIColor.black.cgColor
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        loginButton.layer.shadowRadius = 6
        loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.systemBlue, for: .normal)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        stateLabel.textAlignment = .center
        stateLabel.textColor = .systemRed
        stateLabel.numberOfLines = 0
        stateLabel.isHidden = true
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addSubview(loadingIndicator)
        view.addSubview(stateLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            
            loadingIndicator.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stateLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 20),
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.widthAnchor.constraint(equalToConstant: 300),
        ])
    }

    @objc func handleLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            stateLabel.text = "Пожалуйста, заполните все поля."
            stateLabel.textColor = .systemOrange
            stateLabel.isHidden = false
            return
        }
        
        loadingIndicator.startAnimating()
        stateLabel.isHidden = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    self?.stateLabel.text = "Ошибка входа: \(error.localizedDescription)"
                    self?.stateLabel.textColor = .systemRed
                    self?.stateLabel.isHidden = false
                    return
                }
                
                print("Успешный вход: \(email)")
                self?.stateLabel.isHidden = true
                
                let tasksVC = TasksViewController()
                let navController = UINavigationController(rootViewController: tasksVC)
                navController.modalPresentationStyle = .fullScreen
                self?.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleRegister() {
        let registerVC = RegisterViewController()
        registerVC.modalPresentationStyle = .fullScreen
        present(registerVC, animated: true, completion: nil)
    }
}
