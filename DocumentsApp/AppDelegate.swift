import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Проверяем, создан ли пароль
        if KeychainManager.shared.isPasswordSet() {
            // Показываем экран ввода пароля
            window?.rootViewController = PasswordViewController()
        } else {
            // Показываем экран создания пароля
            window?.rootViewController = PasswordViewController()
        }
        
        window?.makeKeyAndVisible()
        return true
    }
}
