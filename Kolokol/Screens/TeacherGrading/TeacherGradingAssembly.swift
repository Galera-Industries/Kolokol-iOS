import UIKit

enum TeacherGradingAssembly {
    static func build() -> UIViewController {
        let view = TeacherGradingViewController()
        let model = TeacherGradingModel()
        let keychain = KeychainManager()
        let presenter = TeacherGradingPresenter(view: view, model: model, keychain: keychain)
        view.presenter = presenter
        return view
    }
}
