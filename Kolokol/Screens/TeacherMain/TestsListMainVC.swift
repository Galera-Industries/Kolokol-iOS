import UIKit

final class TestsListMainViewController: UIViewController, TeacherMainViewProtocol {
    var presenter: TeacherMainPresenterProtocol!
    private var tests: [TestModel] = [] { // для учителя
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
    private var testsResults: [TestResult] = [] { // для студента
        didSet {
            if testsResults.count == 0 {
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
    private let refresh: UIRefreshControl = UIRefreshControl()
    
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
        navigationItem.setHidesBackButton(true, animated: false)
        presenter.viewLoaded()
        configureMainBackground()
        configureUI()
    }
    
    func setCredentials(_ email: String, _ name: String) {
        emailLabel.text = email
        nameLabel.text = name
    }
    
    func showTests(_ tests: [TestModel]) {
        self.tests = tests
        testsTableView.reloadData()
        refresh.endRefreshing()
    }
    
    func addTest(_ test: TestModel) {
        tests.insert(test, at: 0)
        testsTableView.reloadData()
    }
    
    func updateTest(_ test: TestModel) {
        if let index = tests.firstIndex(where: {$0.id == test.id}) {
            tests[index] = test
            testsTableView.reloadSections(IndexSet(integer: index), with: .automatic)
        }
    }
    
    func routeToMainScreen() {
        navigationController?.pushViewController(MainAssembly.build(), animated: true)
    }
    
    func routeToTestCreate() {
        navigationController?.pushViewController(CreateTestAssembly.build(), animated: true)
    }
    
    func setResults(_ results: [TestResult]) {
        testsResults = results
        testsTableView.reloadData()
        refresh.endRefreshing()
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
        configureRefresh()
    }
    
    private func configureNavbar() {
        navigationItem.title = "Kollocol"
        let titleFont = UIFont(name: "TTCommons-DemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: Colors.textSecondary
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        let plusButton = UIButton(type: .system)
        
        plusButton.setHeight(44)
        plusButton.setWidth(44)
        plusButton.backgroundColor = Colors.surfaceSecondary
        plusButton.layer.cornerRadius = 22
        plusButton.clipsToBounds = true

        if let plus = UIImage(systemName: "plus")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            .withRenderingMode(.alwaysTemplate) {
            plusButton.setImage(plus, for: .normal)
            plusButton.tintColor = Colors.textSecondary
        }
        
        plusButton.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)

        let item = UIBarButtonItem(customView: plusButton)
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
    
    private func configureRefresh() {
        refresh.tintColor = Colors.textPrimary
        refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        
        testsTableView.refreshControl = refresh
    }
    
    @objc private func onRefresh() {
        presenter.viewLoaded()
    }
    
    @objc private func plusButtonPressed() {
        presenter.routeNext()
    }
}


extension TestsListMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { tests.isEmpty ? testsResults.count : tests.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestCell.cellIdentifier, for: indexPath) as? TestCell else {
            return UITableViewCell()
        }
        if tests.isEmpty {
            let item = testsResults[indexPath.section]
            cell.configure(nil, item)
        } else {
            let item = tests[indexPath.section]
            cell.configure(item, nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tests.isEmpty {
            let testResult = testsResults[indexPath.section]
            navigationController?.pushViewController(DetailedTestResultAssembly.build(isStudent: true, testResult: testResult), animated: true)
        } else {
            let test = tests[indexPath.section]
            navigationController?.pushViewController(CreateTestAssembly.build(test: test), animated: true)
        }
    }
}

