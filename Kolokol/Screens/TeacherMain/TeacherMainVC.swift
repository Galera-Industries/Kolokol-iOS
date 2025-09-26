import UIKit

final class TeacherMainViewController: UIViewController, TeacherMainViewProtocol {
    var presenter: TeacherMainPresenterProtocol!
    private var tests: [TestModel] = [] {
        didSet {
            if tests.count == 0 {
                noTestsStackView.alpha = 1
                testsTableView.alpha = 0
            } else {
                noTestsStackView.alpha = 0
                testsTableView.alpha = 1
            }
        }
    }
    private let testsTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let noTestsStackView: UIStackView = UIStackView()
    
    private lazy var monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.setLocalizedDateFormatFromTemplate("MMMM")
        return f
    }()
    
    private lazy var monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        f.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return f
    }()
    
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
        configureNavbar()
        configurePersonInfoStackView()
        configureNoTestsStackView()
        configureTestsTableView()
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

        if let chevron = UIImage(systemName: "plus")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            .withRenderingMode(.alwaysTemplate) {
            backButton.setImage(chevron, for: .normal)
            backButton.tintColor = Colors.textSecondary
        }
        
        backButton.addTarget(self, action: #selector(createTestButtonPressed), for: .touchUpInside)

        let item = UIBarButtonItem(customView: backButton)
        navigationItem.rightBarButtonItem = item
    }
    
    private func configurePersonInfoStackView() {
        view.addSubview(personInfoStackView)
        personInfoStackView.pinHorizontal(view, 16)
        personInfoStackView.pinTop(view.safeAreaLayoutGuide.topAnchor, 12)
    }
    
    private func configureNoTestsStackView() {
        view.addSubview(noTestsStackView)
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "text.page")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Colors.textSecondary
        imageView.preferredSymbolConfiguration = .init(pointSize: 68, weight: .regular)
        
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textColor = Colors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Отобразим здесь все ваши тесты"
        
        noTestsStackView.addArrangedSubview(imageView)
        noTestsStackView.addArrangedSubview(label)
        
        noTestsStackView.axis = .vertical
        noTestsStackView.spacing = 12
        noTestsStackView.alignment = .center
        noTestsStackView.alpha = 1
        
        noTestsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noTestsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noTestsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noTestsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 100),
            noTestsStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -100)
        ])
    }
    
    private func configureTestsTableView() {
        view.addSubview(testsTableView)
        testsTableView.backgroundColor = .clear
        testsTableView.separatorStyle = .singleLine
        testsTableView.delegate = self
        testsTableView.dataSource = self
        testsTableView.register(TestCell.self, forCellReuseIdentifier: TestCell.cellIdentifier)
        
        testsTableView.pinTop(personInfoStackView.bottomAnchor, 12)
        testsTableView.pinHorizontal(view)
        testsTableView.pinBottom(view.bottomAnchor, 12)
        
        testsTableView.alpha = 0
    }
    
    
    @objc private func createTestButtonPressed() {
        //navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }
}


extension TeacherMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { tests.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestCell.cellIdentifier, for: indexPath) as? TestCell else {
            return UITableViewCell()
        }
        let item = tests[indexPath.section]
        cell.configure(item)
        return cell
    }
}

