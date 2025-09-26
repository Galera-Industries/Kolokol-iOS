//
//  DetailedTestResultVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

final class DetailedTestResultViewController: UIViewController, DetailedTestResultViewProtocol {
    var presenter: DetailedTestResultPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureU()
    }
    
    // MARK: - Protocol Methods
    
    func showReviews(_ reviews: [Item]) {
        //
    }
    
    func setName(_ name: String) {
        //
    }
    
    func setGrade(_ grade: Int) {
        //
    }
    
    
    private func configureU() {
        
    }
}
