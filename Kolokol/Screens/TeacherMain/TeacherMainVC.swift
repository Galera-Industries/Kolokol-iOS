import UIKit

final class TeacherMainViewController: UIViewController, TeacherMainViewProtocol {
    var presenter: TeacherMainPresenterProtocol!
    private var tests: [TestModel] = [] {
        didSet {
            // мб понадобится
        }
    }
    private var testsSections: [TestSection] = []
    private let testsTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let titleLabel: UILabel = UILabel()
    private let myTestsLabel: UILabel = UILabel()
    private let createTestButton: UIButton = UIButton()
    
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
        
        self.tests = [
            TestModel(id: UUID(), code: 123456, title: "Тест по олимпиадной математике 5 класс", published: false, resultsPublished: false, answersVisible: false, createdAt: Date()),
            TestModel(id: UUID(), code: 123456, title: "Тест по матану 2 курс", published: false, resultsPublished: false, answersVisible: false, createdAt: Date()),
            TestModel(id: UUID(), code: 123456, title: "Тест по русскому языку", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Коллоквиум", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по устройству двигателей внутреннего сгорания", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по английскому", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по UIKit", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по SwiftUI", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по iOS - база", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по дискре 5 класс", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -2, to: Date())!)
        ]
        testsSections = buildSections(from: tests)
        testsTableView.reloadData()
    }
    
    func showTests(_ tests: [TestModel]) {
        self.tests = [
            TestModel(id: UUID(), code: 123456, title: "Тест по олимпиадной математике 5 класс", published: false, resultsPublished: false, answersVisible: false, createdAt: Date()),
            TestModel(id: UUID(), code: 123456, title: "Тест по матану 2 курс", published: false, resultsPublished: false, answersVisible: false, createdAt: Date()),
            TestModel(id: UUID(), code: 123456, title: "Тест по русскому языку", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Коллоквиум", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по устройству двигателей внутреннего сгорания", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по английскому", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по UIKit", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по SwiftUI", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по iOS - база", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date())!),
            TestModel(id: UUID(), code: 123456, title: "Тест по дискре 5 класс", published: false, resultsPublished: false, answersVisible: false, createdAt: Calendar.current.date(byAdding: .year, value: -2, to: Date())!)
        ]
        
        testsTableView.reloadData()
    }
    
    func showError(_ error: String) {
        let alert = UIAlertController(title: "Ooops", message: error, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    private func buildSections(from tests: [TestModel]) -> [TestSection] {
        let dated = tests.map { t -> (Date, TestModel) in
            return (t.createdAt, t)
        }
        let cal = Calendar.current
        let grouped = Dictionary(grouping: dated, by: { (pair) -> Date in
            let d = pair.0
            let comps = cal.dateComponents([.year, .month], from: d)
            return cal.date(from: comps)!
        })

        let sections: [TestSection] = grouped.map { (monthStart, pairs) in
            let header: String = {
                let year = cal.component(.year, from: monthStart)
                let thisYear = cal.component(.year, from: Date())
                if year == thisYear {
                    return monthFormatter.string(from: monthStart)
                } else {
                    return monthYearFormatter.string(from: monthStart)
                }
            }()
            let items = pairs
                .sorted { $0.0 > $1.0 }
                .map { $0.1 }
            
            return TestSection(header: header, items: items)
        }
            .sorted { $0.items.first?.createdAt ?? .distantFuture > $1.items.first?.createdAt ?? .distantFuture}
        return sections
    }
    
    private func configureUI() {
        configureTitleLabel()
        configurePersonInfoStackView()
        configureMyTestsLabel()
        configureCreateTestButton()
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
    
    private func configureMyTestsLabel() {
        view.addSubview(myTestsLabel)
        myTestsLabel.text = "Мои тесты"
        myTestsLabel.textColor = Colors.textPrimary
        myTestsLabel.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        myTestsLabel.pinTop(personInfoStackView.bottomAnchor, 20)
        myTestsLabel.pinLeft(view.leadingAnchor, 16)
        myTestsLabel.setWidth(200)
        myTestsLabel.setHeight(40)
    }
    
    private func configureCreateTestButton() {
        view.addSubview(createTestButton)
        createTestButton.setTitle("Создать тест", for: .normal)
        createTestButton.setTitleColor(Colors.textPrimary, for: .normal)
        createTestButton.backgroundColor = UIColor(hex: "7C7C7C", alpha: 0.2)
        createTestButton.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        createTestButton.layer.cornerRadius = 32
        createTestButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 20)
        createTestButton.pinLeft(view.leadingAnchor, 16)
        createTestButton.pinRight(view.trailingAnchor, 16)
        createTestButton.setHeight(86)
        createTestButton.addTarget(self, action: #selector(createTestButtonPressed), for: .touchUpInside)
    }
    
    private func configureTestsTableView() {
        view.addSubview(testsTableView)
        testsTableView.backgroundColor = .clear
        testsTableView.separatorStyle = .singleLine
        testsTableView.delegate = self
        testsTableView.dataSource = self
        testsTableView.register(TestCell.self, forCellReuseIdentifier: TestCell.cellIdentifier)
        testsTableView.register(SectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "SectionHeaderView")
        
        testsTableView.pinTop(myTestsLabel.bottomAnchor, 12)
        testsTableView.pinHorizontal(view)
        testsTableView.pinBottom(createTestButton.topAnchor, 16)
    }
    
    @objc private func createTestButtonPressed() {
        //navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }
}


extension TeacherMainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { testsSections.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < testsSections.count else { return 0 }
        return testsSections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 40 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as? SectionHeaderView else {
            return UIView()
        }
        header.label.text = testsSections[section].header
        header.backgroundColor = .clear
        return header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TestCell.cellIdentifier, for: indexPath) as? TestCell else {
            return UITableViewCell()
        }
        guard indexPath.section < testsSections.count else {
            return UITableViewCell()
        }
        let section = testsSections[indexPath.section]
        guard indexPath.row < section.items.count else {
            return UITableViewCell()
        }
        let item = section.items[indexPath.row]
        cell.configure(item)
        return cell
    }
}
