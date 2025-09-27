//
//  DetailedTestResultVC.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 27.09.2025.
//

import UIKit

final class DetailedTestResultViewController: UIViewController, DetailedTestResultViewProtocol {
    var presenter: DetailedTestResultPresenterProtocol?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textColor = Colors.textPrimary
        return label
    }()
    
    private let gradeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textColor = Colors.textSecondary
        label.text = "Не оценено"
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        stack.alignment = .leading
        return stack
    }()
    
    
    private var reviews: [Item] = []
    private let reviewsTableView: UITableView = UITableView()
    private let refresh: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
        configureU()
    }
    
    // MARK: - Protocol Methods
    
    func showReviews(_ reviews: [Item]) {
        self.reviews = [
            Item(questionId: UUID(), order: 1, comment: "YO", answer: "Great job", maxPoints: 10, gotPoints: 8, type: .text),
            Item(questionId: UUID(), order: 1, comment: "YO", answer: "Great job", maxPoints: 10, gotPoints: 8, type: .text),
            Item(questionId: UUID(), order: 1, comment: "YO", answer: "Great job", maxPoints: 10, gotPoints: 8, type: .text)
        ]
        refresh.endRefreshing()
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setGrade(_ grade: Int) {
        gradeLabel.text = "Итог: \(String(grade))"
    }
    
    
    private func configureU() {
        configureNavbar()
        configureStack()
        configureReviewsTableView()
    }
    
    private func configureNavbar() {
        navigationItem.title = "Kollocol"

        let titleFont = UIFont(name: "TTCommons-DemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: Colors.textSecondary
        ]

        navigationController?.navigationBar.titleTextAttributes = attributes

        let backButton = UIButton(type: .system)

        backButton.setHeight(44)
        backButton.setWidth(44)
        backButton.backgroundColor = Colors.surfaceSecondary
        backButton.layer.cornerRadius = 22
        backButton.clipsToBounds = true

        if let chevron = UIImage(systemName: "chevron.left")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            .withRenderingMode(.alwaysTemplate) {
            backButton.setImage(chevron, for: .normal)
            backButton.tintColor = Colors.textSecondary
        }

        backButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)

        let item = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = item
    }
    
    private func configureStack() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(gradeLabel)
        stackView.pinTop(view.safeAreaLayoutGuide.topAnchor, 12)
        stackView.pinLeft(view.safeAreaLayoutGuide.leadingAnchor, 12)
        stackView.pinRight(view.safeAreaLayoutGuide.trailingAnchor, 12)
    }
    
    private func configureReviewsTableView() {
        view.addSubview(reviewsTableView)
        reviewsTableView.dataSource = self
        reviewsTableView.delegate = self
        reviewsTableView.backgroundColor = .clear
        reviewsTableView.separatorStyle = .singleLine
        reviewsTableView.register(TestCell.self, forCellReuseIdentifier: TestCell.cellIdentifier)
        
        reviewsTableView.pinTop(stackView.bottomAnchor, 12)
        reviewsTableView.pinHorizontal(view)
        reviewsTableView.pinBottom(view.bottomAnchor, 12)
    }
    
    private func configureRefresh() {
        refresh.tintColor = Colors.textPrimary
        refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        reviewsTableView.refreshControl = refresh
    }
    
    @objc private func onRefresh() {
        presenter?.viewLoaded()
    }
    
    @objc private func didTapDismiss() {
        navigationController?.popViewController(animated: true)
    }
}

extension DetailedTestResultViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { reviews.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedCell.reuse, for: indexPath) as? DetailedCell else { return UITableViewCell() }
        let item = reviews[indexPath.section]
        cell.configure(item)
        return cell
    }
}
