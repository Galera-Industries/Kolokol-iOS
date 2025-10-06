import UIKit

final class TeacherGradingViewController: UIViewController, TeacherGradingViewProtocol {
    var presenter: TeacherGradingPresenterProtocol?

    // MARK: - UI Compontnes
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.estimatedRowHeight = 44
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()

    // MARK: - Row Model

    private enum Row {
        case screenTitle(String)
        case spacer(CGFloat)
        case sectionHeader(String)
        case student(name: String, mail: String, grade: String?)
    }

    private var rows: [Row] = []

    private var toGradeItems: [(name: String, mail: String, grade: String?)] = [
        ("Ульяна Еськова", "udeskova@edu.hse.ru", nil),
        ("Иван Петров", "ivan.petrov@edu.hse.ru", nil),
        ("Мария Сидорова", "m.sidorova@edu.hse.ru", nil),
        ("Антон Смирнов", "a.smirnov@edu.hse.ru", nil)
    ]

    private var readyItems: [(name: String, mail: String, grade: String?)] = [
        ("Ульяна Еськова", "udeskova@edu.hse.ru", "8/40"),
        ("Иван Петров", "ivan.petrov@edu.hse.ru", "35/40"),
        ("Мария Сидорова", "m.sidorova@edu.hse.ru", "40/40"),
        ("Антон Смирнов", "a.smirnov@edu.hse.ru", "29/40")
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureNavbar()
        configureTable()
        configureConstraints()
        configureDismissKeyboardGesture()

        buildRows(
            title: "Оценивание",
            remainingHeader: "Осталось 12 из 24",
            toGrade: toGradeItems,
            readyHeader: "Готовы",
            ready: readyItems
        )

        tableView.reloadData()
    }

    // MARK: - Private Methods

    private func buildRows(title: String,
                           remainingHeader: String,
                           toGrade: [(String, String, String?)],
                           readyHeader: String,
                           ready: [(String, String, String?)]) {
        rows.removeAll()
        // Отступ от верха
        rows.append(.spacer(32))

        // Секция 1: Заголовок
        rows.append(.screenTitle(title))

        // Отступ между секцией 1 и 2
        rows.append(.spacer(32))

        // Секция 2: Заголовок + отступ 16 + список студентов
        rows.append(.sectionHeader(remainingHeader))
        rows.append(.spacer(16))
        for (idx, item) in toGrade.enumerated() {
            rows.append(.student(name: item.0, mail: item.1, grade: item.2))
            if idx != toGrade.count - 1 { rows.append(.spacer(8)) }
        }

        // Отступ между секцией 2 и 3
        rows.append(.spacer(32))

        // Секция 3: Заголовок + отступ 16 + список студентов с оценками
        rows.append(.sectionHeader(readyHeader))
        rows.append(.spacer(16))
        for (idx, item) in ready.enumerated() {
            rows.append(.student(name: item.0, mail: item.1, grade: item.2))
            if idx != ready.count - 1 { rows.append(.spacer(8)) }
        }
    }

    private func configureTable() {
        tableView.register(ScreenTitleCell.self, forCellReuseIdentifier: ScreenTitleCell.reuseID)
        tableView.register(SectionHeaderCell.self, forCellReuseIdentifier: SectionHeaderCell.reuseID)
        tableView.register(StudentGradingCell.self, forCellReuseIdentifier: StudentGradingCell.reuseID)
        tableView.register(SpacerCell.self, forCellReuseIdentifier: SpacerCell.reuseID)

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
    }

    private func configureConstraints() {
        tableView.pinTop(view.safeAreaLayoutGuide.topAnchor, 0)
        tableView.pinBottom(view.bottomAnchor, 0)
        tableView.pinLeft(view, 16)
        tableView.pinRight(view, 16)
    }

    private func configureNavbar() {
        navigationItem.title = "Kollocol"
        let titleFont = UIFont(name: "TTCommons-DemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        navigationController?.navigationBar.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: Colors.textSecondary
        ]
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    private func configureDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRootTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions

    @objc
    private func didTapDismiss() {
        if let navigation = navigationController, navigation.viewControllers.first != self {
            navigation.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc
    private func handleRootTap() {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDataSource
extension TeacherGradingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rows[indexPath.row] {
        case .screenTitle(let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ScreenTitleCell.reuseID, for: indexPath) as? ScreenTitleCell
            else {return UITableViewCell() }
            cell.configure(title: text)
            return cell

        case .sectionHeader(let text):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SectionHeaderCell.reuseID, for: indexPath) as? SectionHeaderCell
            else { return UITableViewCell() }
            cell.configure(title: text)
            return cell

        case .student(let name, let mail, let grade):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: StudentGradingCell.reuseID, for: indexPath) as? StudentGradingCell
            else { return UITableViewCell()}
            cell.configure(
                name: name,
                mail: mail,
                grade: grade
            )
            return cell

        case .spacer(let h):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SpacerCell.reuseID, for: indexPath) as? SpacerCell
            else {return UITableViewCell() }
            cell.configure(height: h)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension TeacherGradingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rows[indexPath.row] {
        case .screenTitle:
            return UITableView.automaticDimension
        case .sectionHeader:
            return UITableView.automaticDimension
        case .student:
            return 86
        case .spacer(let h):
            return h
        }
    }
}
