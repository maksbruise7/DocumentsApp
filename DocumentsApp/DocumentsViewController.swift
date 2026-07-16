import UIKit
import UniformTypeIdentifiers

class DocumentsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.identifier)
        return tableView
    }()
    
    // MARK: - Properties
    private var files: [URL] = []
    private let fileManager = FileManager.default
    private var documentsDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private let settingsManager = SettingsManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        loadFiles()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sortingChanged),
            name: .sortingChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFiles()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupNavigationBar() {
        title = "Файлы"
        
        let addButton = UIBarButtonItem(
            title: "Добавить фотографию",
            style: .plain,
            target: self,
            action: #selector(addPhotoTapped)
        )
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - File Management
    private func loadFiles() {
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: documentsDirectory,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            // Фильтруем только изображения
            files = contents.filter { url in
                let uti = UTType(filenameExtension: url.pathExtension)
                return uti?.conforms(to: .image) == true
            }
            
            // Сортировка в зависимости от настроек
            if settingsManager.isAlphabeticalSort {
                files.sort { $0.lastPathComponent < $1.lastPathComponent }
            } else {
                files.sort { $0.lastPathComponent > $1.lastPathComponent }
            }
            
            tableView.reloadData()
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось загрузить файлы: \(error.localizedDescription)")
        }
    }
    
    private func saveImageToDocuments(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            showAlert(title: "Ошибка", message: "Не удалось конвертировать изображение")
            return
        }
        
        let fileName = "photo_\(Date().timeIntervalSince1970).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            loadFiles()
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось сохранить фото: \(error.localizedDescription)")
        }
    }
    
    private func deleteFile(at index: Int) {
        let fileURL = files[index]
        
        do {
            try fileManager.removeItem(at: fileURL)
            files.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        } catch {
            showAlert(title: "Ошибка", message: "Не удалось удалить файл: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    @objc private func addPhotoTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [UTType.image.identifier]
        present(imagePicker, animated: true)
    }
    
    @objc private func sortingChanged() {
        loadFiles()
    }
    
    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension DocumentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else {
            return UITableViewCell()
        }
        
        let fileURL = files[indexPath.row]
        cell.configure(with: fileURL)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DocumentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            self?.deleteFile(at: indexPath.row)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

// MARK: - UIImagePickerControllerDelegate
extension DocumentsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            showAlert(title: "Ошибка", message: "Не удалось получить изображение")
            return
        }
        
        saveImageToDocuments(image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
