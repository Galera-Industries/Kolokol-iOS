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
    
    
    private var reviews: [Item] = [] {
        didSet {
            if reviews.count == 0 {
                noReviewsStackView.alpha = 1
                reviewsTableView.alpha = 0
            } else {
                noReviewsStackView.alpha = 0
                reviewsTableView.alpha = 1
            }
        }
    }
    private let reviewsTableView: UITableView = UITableView()
    private let refresh: UIRefreshControl = UIRefreshControl()
    private let noReviewsStackView: UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewLoaded()
        configureU()
    }
    
    // MARK: - Protocol Methods
    
    func showReviews(_ reviews: [Item]) {
        self.reviews = reviews
        reviewsTableView.reloadData()
        refresh.endRefreshing()
    }
    
    func setName(_ name: String) {
        nameLabel.text = name
    }
    
    func setGrade(_ grade: Int) {
        if grade != -1 {
            gradeLabel.text = "Итог: \(String(grade))"
        }
    }
    
    func stopRefresherIfNeeded() {
        refresh.endRefreshing()
    }
    
    
    private func configureU() {
        configureMainBackground()
        configureNavbar()
        configureStack()
        configureReviewsTableView()
        configureRefresh()
        configureNoReviewsStackView()
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
        reviewsTableView.separatorStyle = .none
        reviewsTableView.register(DetailedCell.self, forCellReuseIdentifier: DetailedCell.reuse)
        
        reviewsTableView.rowHeight = 85
        reviewsTableView.estimatedRowHeight = 85
        
        reviewsTableView.pinTop(stackView.bottomAnchor, 12)
        reviewsTableView.pinHorizontal(view)
        reviewsTableView.pinBottom(view.bottomAnchor, 12)
    }
    
    private func configureRefresh() {
        refresh.tintColor = Colors.textPrimary
        refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        reviewsTableView.refreshControl = refresh
    }
    
    private func configureNoReviewsStackView() {
        view.addSubview(noReviewsStackView)
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "text.page")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.textSecondary
        imageView.preferredSymbolConfiguration = .init(pointSize: 68, weight: .regular)
        
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textColor = Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 4
        label.text = "Отобразим здесь оценки и комментарии преподавателя"
        
        noReviewsStackView.addArrangedSubview(imageView)
        noReviewsStackView.addArrangedSubview(label)
        
        noReviewsStackView.axis = .vertical
        noReviewsStackView.spacing = 12
        noReviewsStackView.alignment = .center
        noReviewsStackView.alpha = 1
        
        noReviewsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noReviewsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noReviewsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noReviewsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 100),
            noReviewsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -100)
        ])
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { 20 }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = reviews[indexPath.section]
        navigationController?.present(CommentView(answer: item.text, comment: item.comment ?? "Комментария пока нет"), animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DetailedCell.reuse, for: indexPath) as? DetailedCell else { return UITableViewCell() }
        let item = reviews[indexPath.section]
        cell.configure(item)
        return cell
    }
}
