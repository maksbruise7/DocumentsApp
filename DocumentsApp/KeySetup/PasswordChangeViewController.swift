import UIKit

class PasswordChangeViewController: UIViewController {
    
    // MARK: - UI Elements
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Новый пароль"
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
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Сохранить", for: .normal)
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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Сменить пароль"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        view.addSubview(passwordTextField)
        view.addSubview(repeatTextField)
        view.addSubview(saveButton)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            repeatTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            repeatTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            repeatTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            repeatTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: repeatTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveTapped() {
        errorLabel.isHidden = true
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            showError("Введите пароль")
            return
        }
        
        guard password.count >= 4 else {
            showError("Пароль должен содержать минимум 4 символа")
            return
        }
        
        guard let repeatPassword = repeatTextField.text, !repeatPassword.isEmpty else {
            showError("Повторите пароль")
            return
        }
        
        if password == repeatPassword {
            if KeychainManager.shared.savePassword(password) {
                dismiss(animated: true)
            } else {
                showError("Не удалось сохранить пароль")
            }
        } else {
            showError("Пароли не совпадают")
            passwordTextField.text = ""
            repeatTextField.text = ""
        }
    }
    
    // MARK: - Helpers
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
}
