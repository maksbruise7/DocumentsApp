import UIKit

class PasswordViewController: UIViewController {
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Введите пароль"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        return textField
    }()
    
    private let repeatTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Повторите пароль"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isHidden = true
        return textField
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать пароль", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private var isPasswordSet: Bool {
        return KeychainManager.shared.isPasswordSet()
    }
    
    private var isFirstPasswordEntered = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialState()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(passwordTextField)
        view.addSubview(repeatTextField)
        view.addSubview(actionButton)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            repeatTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            repeatTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            repeatTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            repeatTextField.heightAnchor.constraint(equalToConstant: 50),
            
            actionButton.topAnchor.constraint(equalTo: repeatTextField.bottomAnchor, constant: 30),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func setupInitialState() {
        if isPasswordSet {
            titleLabel.text = "Введите пароль"
            actionButton.setTitle("Войти", for: .normal)
            passwordTextField.placeholder = "Введите пароль"
            repeatTextField.isHidden = true
        } else {
            titleLabel.text = "Создайте пароль"
            actionButton.setTitle("Создать пароль", for: .normal)
            passwordTextField.placeholder = "Придумайте пароль"
            repeatTextField.isHidden = true
        }
    }
    
    private func resetToInitialState() {
        isFirstPasswordEntered = false
        passwordTextField.text = ""
        repeatTextField.text = ""
        repeatTextField.isHidden = true
        errorLabel.isHidden = true
        
        if isPasswordSet {
            actionButton.setTitle("Войти", for: .normal)
            passwordTextField.placeholder = "Введите пароль"
        } else {
            actionButton.setTitle("Создать пароль", for: .normal)
            passwordTextField.placeholder = "Придумайте пароль"
        }
    }
    
    // MARK: - Actions
    @objc private func actionButtonTapped() {
        errorLabel.isHidden = true
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Введите пароль")
            return
        }
        
        if isPasswordSet {
            // Проверка существующего пароля
            if let savedPassword = KeychainManager.shared.getPassword() {
                if password == savedPassword {
                    openMainApp()
                } else {
                    showError("Неверный пароль")
                    passwordTextField.text = ""
                }
            }
            return
        }
        
        // Создание нового пароля
        if !isFirstPasswordEntered {
            // Первый ввод пароля
            guard password.count >= 4 else {
                showError("Пароль должен содержать минимум 4 символа")
                passwordTextField.text = ""
                return
            }
            
            isFirstPasswordEntered = true
            actionButton.setTitle("Повторите пароль", for: .normal)
            repeatTextField.isHidden = false
            passwordTextField.placeholder = "Пароль"
            passwordTextField.text = ""
            repeatTextField.becomeFirstResponder()
        } else {
            // Повторный ввод пароля
            guard let firstPassword = passwordTextField.text, !firstPassword.isEmpty else {
                showError("Введите пароль")
                return
            }
            
            guard let repeatPassword = repeatTextField.text, !repeatPassword.isEmpty else {
                showError("Повторите пароль")
                return
            }
            
            if firstPassword == repeatPassword {
                // Сохраняем пароль в Keychain
                if KeychainManager.shared.savePassword(firstPassword) {
                    openMainApp()
                } else {
                    showError("Не удалось сохранить пароль")
                    resetToInitialState()
                }
            } else {
                showError("Пароли не совпадают")
                resetToInitialState()
            }
        }
    }
    
    // MARK: - Helpers
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func openMainApp() {
        let tabBarController = MainTabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true)
    }
}
