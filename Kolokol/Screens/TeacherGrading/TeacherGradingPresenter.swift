import Foundation

final class TeacherGradingPresenter: TeacherGradingPresenterProtocol {
    weak var view: TeacherGradingViewProtocol?
    var model: TeacherGradingModelProtocol
    var keychain: KeychainManagerProtocol

    init(view: TeacherGradingViewProtocol, model: TeacherGradingModelProtocol, keychain: KeychainManagerProtocol) {
        self.view = view
        self.model = model
        self.keychain = keychain
    }
}
