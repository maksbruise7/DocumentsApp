import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        return tableView
    }()
    
    // MARK: - Properties
    private let settingsManager = SettingsManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Настройки"
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Helpers
    private func showPasswordChangeScreen() {
        let passwordVC = PasswordChangeViewController()
        let navController = UINavigationController(rootViewController: passwordVC)
        present(navController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // Сортировка
        case 1:
            return 1 // Сменить пароль
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Сортировка по алфавиту"
            let sortSwitch = UISwitch()
            sortSwitch.isOn = settingsManager.isAlphabeticalSort
            sortSwitch.addTarget(self, action: #selector(sortSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = sortSwitch
        case 1:
            cell.textLabel?.text = "Сменить пароль"
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryView = nil
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            showPasswordChangeScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Отображение"
        case 1:
            return "Безопасность"
        default:
            return nil
        }
    }
}

// MARK: - Actions
extension SettingsViewController {
    @objc private func sortSwitchChanged(_ sender: UISwitch) {
        settingsManager.isAlphabeticalSort = sender.isOn
        // Отправляем уведомление об изменении сортировки
        NotificationCenter.default.post(name: .sortingChanged, object: nil)
    }
}

// MARK: - Notification
extension Notification.Name {
    static let sortingChanged = Notification.Name("sortingChanged")
}
