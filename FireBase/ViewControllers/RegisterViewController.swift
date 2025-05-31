import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    let emailTextField = UITextField()
    let passwordTextField = UITextField()
    let registerButton = UIButton(type: .system)
    let loginButton = UIButton(type: .system)
    let titleLabel = UILabel()
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let stateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemBackground
        setupUI()
    }
    
    func setupUI() {
        titleLabel.text = "Create Account"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.autocapitalizationType = .none
        emailTextField.backgroundColor = UIColor.secondarySystemBackground
        emailTextField.layer.cornerRadius = 10
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        emailTextField.layer.shadowOpacity = 0.1
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = UIColor.secondarySystemBackground
        passwordTextField.layer.cornerRadius = 10
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
        passwordTextField.layer.shadowOpacity = 0.1
        passwordTextField.layer.shadowOffset = CGSize(width: 0, height: 2)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = UIColor.systemGreen
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        registerButton.layer.cornerRadius = 10
        registerButton.layer.shadowColor = UIColor.black.cgColor
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        loginButton.setTitle("Already have an account? Login", for: .normal)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.textAlignment = .center
        stateLabel.numberOfLines = 0
        stateLabel.textColor = .systemRed
        stateLabel.isHidden = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, emailTextField, passwordTextField, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(loginButton)
        view.addSubview(loadingIndicator)
        view.addSubview(stateLabel)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            
            loginButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loadingIndicator.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stateLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 20),
            stateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stateLabel.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    @objc func handleRegister() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            self.stateLabel.text = "Пожалуйста, заполните все поля."
            self.stateLabel.textColor = .systemOrange
            self.stateLabel.isHidden = false
            return
        }
        
        loadingIndicator.startAnimating()
        stateLabel.isHidden = true
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                
                if let error = error {
                    self.stateLabel.text = "Ошибка регистрации: \(error.localizedDescription)"
                    self.stateLabel.textColor = .systemRed
                    self.stateLabel.isHidden = false
                    return
                }
                
                guard let userEmail = result?.user.email else {
                    self.stateLabel.text = "Пользователь не найден."
                    self.stateLabel.textColor = .systemOrange
                    self.stateLabel.isHidden = false
                    return
                }
                
                print("Успешная регистрация: \(userEmail)")
                self.stateLabel.isHidden = true
                
                let loginVC = LoginViewController()
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    @objc func goToLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)
    }
}
