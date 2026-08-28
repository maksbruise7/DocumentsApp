import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    private let sortKey = "alphabeticalSort"
    
    private init() {}
    
    var isAlphabeticalSort: Bool {
        get {
            return defaults.bool(forKey: sortKey)
        }
        set {
            defaults.set(newValue, forKey: sortKey)
        }
    }
}
