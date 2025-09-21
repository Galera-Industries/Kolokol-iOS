//
//  CodeEnteringPresenter.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 21.09.2025.
//

import Foundation

final class CodeEnteringPresenter: CodeEnteringPresenterProtocol {
    weak var view: CodeEnteringViewProtocol?
    var model: CodeEnteringModelProtocol
    
    init(view: CodeEnteringViewProtocol, model: CodeEnteringModelProtocol) {
        self.view = view
        self.model = model
    }
    
    func textFieldFilled(withStringCode stringCode: String) {
        Task {
            do {
                let request = ConfirmOTPRequest(email: <#T##String#>, regToken: <#T##UUID#>, otp: <#T##Int#>)
                let response = try await model.sendOtpConfirmationRequest(<#T##request: ConfirmOTPRequest##ConfirmOTPRequest#>)
            } catch {
                
            }
        }
    }
}
