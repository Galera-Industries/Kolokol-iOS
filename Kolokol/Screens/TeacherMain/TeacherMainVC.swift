//
//  TeacherMainVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

final class TeacherMainViewController: UIViewController, TeacherMainViewProtocol {
    var presenter: TeacherMainPresenterProtocol!
    private var tests: [TestModel] = [] {
        didSet {
            // мб понадобится
        }
    }
    private let testsTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let titleLabel: UILabel = UILabel()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setWidth(54)
        imageView.setHeight(54)
        imageView.layer.cornerRadius = 54 / 2
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: "#D9D9D9")
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textSecondary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, emailLabel])
        stack.axis = .vertical
        stack.spacing = 0
        stack.alignment = .leading
        return stack
    }()

    private lazy var personInfoStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, infoStackView])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    override func viewDidLoad() {
        presenter.viewLoaded()
        configureMainBackground()
        configureUI()
    }
    
    func showTests(_ tests: [TestModel]) {
        self.tests = tests
        testsTableView.reloadData()
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Ooops", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    private func configureUI() {
        configureTitleLabel()
        configurePersonInfoStackView()
        configureTestsTableView()
    }
    
    private func configureTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "Kollocol"
        titleLabel.textColor = Colors.textSecondary
        titleLabel.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        titleLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 16)
        titleLabel.pinCenterX(view.centerXAnchor)
    }
    
    private func configurePersonInfoStackView() {
        view.addSubview(personInfoStackView)
        personInfoStackView.pinHorizontal(view, 16)
        personInfoStackView.pinTop(titleLabel.bottomAnchor, 24)
    }
    
    private func configureTestsTableView() {
        view.addSubview(testsTableView)
    }
}
