import UIKit

final class AlertManager {

    static let shared = AlertManager()
    private init() {}

    func show(title: String = "Uyarı", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))

        if let vc = UIApplication.shared.windows.first?.rootViewController {
            vc.present(alert, animated: true)
        }
    }
}
