import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        let documentsVC = DocumentsViewController()
        documentsVC.tabBarItem = UITabBarItem(
            title: "Файлы",
            image: UIImage(systemName: "folder"),
            selectedImage: UIImage(systemName: "folder.fill")
        )
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(
            title: "Настройки",
            image: UIImage(systemName: "gear"),
            selectedImage: UIImage(systemName: "gear")
        )
        
        viewControllers = [
            UINavigationController(rootViewController: documentsVC),
            UINavigationController(rootViewController: settingsVC)
        ]
    }
}
