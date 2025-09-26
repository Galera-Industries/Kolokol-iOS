//
//  TestMakerViewController.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

// MARK: - Models
public struct TestDraft {
    public var title: String
    public var code6: String
    public var ttlMinutes: Int?   // nil = без ограничения
    public var deadline: Date?    // nil = без дедлайна
    public var questions: [QuestionRow]
}

public struct QuestionRow {
    public var id: UUID
    public var title: String
    public var kind: String
}

private enum OptionRow: Equatable {
    case timeSwitch
    case timeDetail
    case deadlineSwitch
    case deadlineDetail
}

// MARK: - VC
final class CreateTestViewController: UIViewController, CreateTestViewProtocol {
    var presenter: CreateTestPresenterProtocol?
    
    var test: TestModel?
    private var isPublished = false
    
    private var allStudents: [GetStudentsResponse.Student] = []
    private var currentSelection: StudentSelection = .all
    
    var onSave: ((TestDraft) -> Void)?
    var onPublish: ((TestDraft) -> Void)?
    var onAddQuestion: (() -> Void)?
    var onPreview: (() -> Void)?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let bottomBar = UIStackView()
    private let saveButton = PrimaryActionButton(title: "Сохранить")
    private let publishButton = PrimaryActionButton(title: "Опубликовать")
    
    private let headerContainer = UIView()
    private let headerStack = UIStackView()
    private let titleCaption = UILabel()
    private let titleInputView = TitleInputView()
    private let codeCaption = UILabel()
    private let codeRowView = CodeRowView()
    private let optionsCaption = UILabel()
    
    private let durationProxyField = UITextField(frame: .zero)
    private let deadlineProxyField = UITextField(frame: .zero)
    private let durationPicker: UIDatePicker = {
        let p = UIDatePicker()
        p.datePickerMode = .countDownTimer
        p.minuteInterval = 5
        return p
    }()
//    private let deadlinePicker: UIDatePicker = {
//        let p = UIDatePicker()
//        p.datePickerMode = .dateAndTime
//        p.minimumDate = Date()
//        return p
//    }()
    
    private var titleText: String = ""
    private var code6: String = ""
    private var timeLimitOn = false
    private var ttlMinutesValue: Int = 45
    private var deadlineOn = false
    private var deadlineValue: Date?
    private var rows: [QuestionRow] = []
    
    private var optionRows: [OptionRow] {
        var a: [OptionRow] = [.timeSwitch]
        if timeLimitOn { a.append(.timeDetail) }
        a.append(.deadlineSwitch)
        if deadlineOn { a.append(.deadlineDetail) }
        return a
    }
    
    private func indexPathForOption(_ kind: OptionRow) -> IndexPath? {
        guard let row = optionRows.firstIndex(of: kind) else { return nil }
        return IndexPath(row: row, section: 0)
    }
    
    private var totalRowsCount: Int { optionRows.count + rows.count + 2 }
    
    init(test: TestModel? = nil) {
        self.test = test
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        overrideUserInterfaceStyle = .dark
        title = "Создание теста"
        navigationController?.navigationBar.barTintColor = .white

        configureUI()

        codeRowView.setEnabled(false)

        rows = []
        durationPicker.countDownDuration = TimeInterval(ttlMinutesValue * 60)

        presenter?.viewDidLoad()
        
        onAddQuestion = { [weak self] in
            self?.presentAddTextQuestion()
        }
    }
    
    private func configureUI() {
        setupTable()
        setupHeader()
        setupBottomBar()
        setupInputViews()
        bindPickers()
    }
    
    // MARK: - Setup
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(white: 1, alpha: 0.12)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .onDrag
        
        tableView.register(AssignCell.self, forCellReuseIdentifier: AssignCell.reuseId)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.reuseID)
        tableView.register(TTLValueCell.self, forCellReuseIdentifier: TTLValueCell.reuseID)
        tableView.register(DeadlineValueCell.self, forCellReuseIdentifier: DeadlineValueCell.reuseID)
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.reuseID)
        tableView.register(AddQuestionCell.self, forCellReuseIdentifier: AddQuestionCell.reuseID)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.pinTop(view.topAnchor, 0)
        tableView.pinBottom(view.bottomAnchor, 0)
        tableView.pinLeft(view.leadingAnchor, 0)
        tableView.pinRight(view.trailingAnchor, 0)
    }
    
    private func setupHeader() {
        // Настраиваем подписи
        func styleCaption(_ l: UILabel, _ text: String) {
            l.text = text
            l.textColor = UIColor(white: 1, alpha: 0.75)
            l.font = UIFont(name: "TTCommons-DemiBold", size: 13)
        }
        styleCaption(titleCaption, "Название")
        styleCaption(codeCaption, "Код теста")
        styleCaption(optionsCaption, "Параметры")
        
        titleInputView.configure(text: titleText, placeholder: "Придумайте название") { [weak self] text in
            guard let self else { return }
            self.titleText = text
            self.updateHeaderSizeFitting()
        }
        
        codeRowView.configure(
            code: spaced(code6),
            onRegenerate: { [weak self] in
                guard let self else { return }
                self.generateCode()
                self.codeRowView.setCode(self.spaced(self.code6))
                self.updateHeaderSizeFitting()
            },
            onCopy: { [weak self] in
                guard let self, !self.code6.isEmpty else { return }
                UIPasteboard.general.string = self.code6
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        )
        
        headerStack.axis = .vertical
        headerStack.alignment = .fill
        headerStack.spacing = 8
        headerStack.isLayoutMarginsRelativeArrangement = true
        headerStack.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 10, right: 20)
        [titleCaption, titleInputView, codeCaption, codeRowView, optionsCaption].forEach { headerStack.addArrangedSubview($0) }
        
        headerContainer.addSubview(headerStack)
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            headerStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            headerStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor)
        ])
        
        tableView.tableHeaderView = headerContainer
        updateHeaderSizeFitting()
    }
    
    private func updateHeaderSizeFitting() {
        let target = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = headerContainer.systemLayoutSizeFitting(
            target,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if headerContainer.frame.size.height != size.height {
            headerContainer.frame.size = CGSize(width: target.width, height: size.height)
            tableView.tableHeaderView = headerContainer
        }
    }
    
    private func setupBottomBar() {
        bottomBar.axis = .horizontal
        bottomBar.spacing = 12
        bottomBar.distribution = .fillEqually
        bottomBar.addArrangedSubview(saveButton)
        bottomBar.addArrangedSubview(publishButton)
        
        view.addSubview(bottomBar)
        
        bottomBar.pinLeft(view.leadingAnchor, 20)
        bottomBar.pinRight(view.trailingAnchor, 20)
        bottomBar.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 12)
        saveButton.setHeight(56)
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        publishButton.addTarget(self, action: #selector(publishTapped), for: .touchUpInside)
        
        updateTableInsets()
    }
    
    private func setupInputViews() {
        durationProxyField.isHidden = true
        deadlineProxyField.isHidden = true
        view.addSubview(durationProxyField)
        view.addSubview(deadlineProxyField)
        
        durationProxyField.inputView = durationPicker
        
        let tb1 = makeToolbar(done: #selector(durationDone), cancel: #selector(closePickers))
        let tb2 = makeToolbar(done: #selector(deadlineDone), cancel: #selector(closePickers))
        durationProxyField.inputAccessoryView = tb1
        deadlineProxyField.inputAccessoryView = tb2
    }
    
    private func bindPickers() {
        durationPicker.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
    }
    
    private func makeToolbar(done: Selector, cancel: Selector) -> UIToolbar {
        let tb = UIToolbar()
        tb.items = [
            UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: cancel),
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "Готово", style: .done, target: self, action: done)
        ]
        tb.sizeToFit()
        return tb
    }
    
    private func updateTableInsets() {
        view.layoutIfNeeded()
        let inset = 56 + 12 + view.safeAreaInsets.bottom
        tableView.contentInset.bottom = inset
        tableView.verticalScrollIndicatorInsets.bottom = inset
    }
    
    @objc private func saveTapped() {
        let req = makeRequest(publish: false)
        presenter?.saveTapped(request: req, publish: false)
    }

    @objc private func publishTapped() {
        let req = makeRequest(publish: true)
        presenter?.saveTapped(request: req, publish: true)
    }
    
    @objc private func durationChanged() {
        ttlMinutesValue = max(1, Int(durationPicker.countDownDuration / 60))
        if let ip = indexPathForOption(.timeDetail),
           let cell = tableView.cellForRow(at: ip) as? TTLValueCell {
            cell.update(minutes: ttlMinutesValue)
        }
    }
    
    @objc private func durationDone() { view.endEditing(true) }
    @objc private func deadlineDone() { view.endEditing(true) }
    @objc private func closePickers() { view.endEditing(true) }
    
    private func currentDraft() -> TestDraft {
        TestDraft(
            title: titleText.trimmingCharacters(in: .whitespacesAndNewlines),
            code6: code6,
            ttlMinutes: timeLimitOn ? ttlMinutesValue : nil,
            // TODO: должно быть deadline value или value на пикере
            deadline: deadlineOn ? (deadlineValue) : nil,
            questions: rows
        )
    }
    
    // MARK: - Helpers
    private func generateCode() {
        code6 = (0..<6).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
    
    private func spaced(_ s: String) -> String {
        guard !s.isEmpty else { return "— — — — — —" }
        return s.map(String.init).joined(separator: " ")
    }
    
    private func format(date: Date) -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateStyle = .medium
        df.timeStyle = .short
        return df.string(from: date)
    }
    
    private func makeRequest(publish: Bool) -> CreateTestRequest {
        let title = titleText.trimmingCharacters(in: .whitespacesAndNewlines)

        let ttlSec: Int? = timeLimitOn ? (ttlMinutesValue * 60) : nil
        // TODO: должно быть deadline value или value на пикере
        let deadline: Date? = deadlineOn ? (deadlineValue) : nil

        let qs: [CreateTestRequest.Question] = rows.enumerated().map { idx, row in
            CreateTestRequest.Question(
                type: .text,
                text: row.title,
                imageUrl: nil,
                order: idx,
                options: nil
            )
        }       
        // да я кринжанул и что
        if let id = test?.id {
            let uuid = UUID(uuidString: id)
            return CreateTestRequest(
                title: title,
                published: publish,
                deadlineAt: deadline,
                ttl: ttlSec,
                scoringMode: .equal,
                resultsPublished: false,
                answersVisible: false,
                questions: qs,
                testId: uuid
            )
        } else {
            return CreateTestRequest(
                title: title,
                published: publish,
                deadlineAt: deadline,
                ttl: ttlSec,
                scoringMode: .equal,
                resultsPublished: false,
                answersVisible: false,
                questions: qs,
                testId: nil
            )
        }
    }
    
    private func presentAddTextQuestion() {
        let vc = SimpleTextQuestionVC()
        vc.onDone = { [weak self] text in
            guard let self, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
            let new = QuestionRow(id: UUID(), title: text, kind: "text")
            self.rows.append(new)
            let ip = IndexPath(row: self.optionRows.count + self.rows.count + 1 , section: 0)
            self.tableView.insertRows(at: [ip], with: .automatic)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

// MARK: - DataSource & Delegate (одна секция)
extension CreateTestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        totalRowsCount
    }
    
    private func isAssignRow(_ indexPath: IndexPath) -> Bool {
        indexPath.row == 0
    }
    
    private func isOptionRow(_ indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && 0 < indexPath.row && indexPath.row < optionRows.count + 1
    }
    private func isQuestionRow(_ indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && indexPath.row >= optionRows.count + 2
    }
    private func isAddQuestionRow(_ indexPath: IndexPath) -> Bool {
        indexPath.section == 0 && indexPath.row == optionRows.count + 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        isQuestionRow(indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard isQuestionRow(indexPath) else { return nil }
        let localIndex = indexPath.row - optionRows.count - 1
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, done in
            self?.rows.remove(at: localIndex)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        delete.backgroundColor = UIColor(red: 0.86, green: 0.26, blue: 0.30, alpha: 0.85)
        return .init(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAssignRow(indexPath) {
            if let cell = tableView.cellForRow(at: indexPath) as? AssignCell {
                if allStudents.isEmpty {
                    presenter?.chooseStudentsOpened()
                } else {
                    cell.handleTap()
                }
            }
        }
        if isOptionRow(indexPath) {
            switch optionRows[indexPath.row - 1] {
            case .timeDetail: durationProxyField.becomeFirstResponder()
            default: break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isAssignRow(indexPath) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AssignCell.reuseId, for: indexPath) as? AssignCell
            else { return UITableViewCell() }

            let vm = AssignCell.ViewModel(
                title: "Назначен",
                selection: currentSelection,
                totalCount: allStudents.count
            )
            cell.configure(vm) { [weak self] in
                self?.presentStudentsPicker()
            }
            return cell
        }
        if isOptionRow(indexPath) {
            switch optionRows[indexPath.row - 1] {
            case .timeSwitch:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseID, for: indexPath) as? SwitchCell
                else { return UITableViewCell() }
                cell.configure(title: "Ограничение времени", isOn: timeLimitOn) { [weak self] isOn in
                    guard let self else { return }
                    let detailIP = IndexPath(row: indexPath.row + 1, section: 0)
                    tableView.performBatchUpdates({
                        if isOn {
                            self.timeLimitOn = true
                            tableView.insertRows(at: [detailIP], with: .fade)
                        } else {
                            self.timeLimitOn = false
                            tableView.deleteRows(at: [detailIP], with: .fade)
                        }
                    })
                }
                return cell
                
            case .timeDetail:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: TTLValueCell.reuseID, for: indexPath) as? TTLValueCell
                else { return UITableViewCell() }
                cell.configure(
                    minutes: ttlMinutesValue,
                    onTapCell: { [weak self] in self?.durationProxyField.becomeFirstResponder() },
                    onStepper: { [weak self] newVal in
                        guard let self else { return }
                        self.ttlMinutesValue = newVal
                        self.durationPicker.countDownDuration = TimeInterval(newVal * 60)
                    }
                )
                return cell
                
            case .deadlineSwitch:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchCell.reuseID, for: indexPath) as? SwitchCell
                else {return UITableViewCell() }
                cell.configure(title: "Дедлайн", isOn: deadlineOn) { [weak self, weak cell] isOn in
                    guard let self = self, let cell = cell, let ip = tableView.indexPath(for: cell) else { return }
                    let detailIP = IndexPath(row: ip.row + 1, section: 0)
                    tableView.performBatchUpdates({
                        if isOn {
                            self.deadlineOn = true
                            tableView.insertRows(at: [detailIP], with: .fade)
                        } else {
                            self.deadlineOn = false
                            if self.deadlineProxyField.isFirstResponder { self.view.endEditing(true) }
                            tableView.deleteRows(at: [detailIP], with: .fade)
                        }
                    })
                }
                return cell
                
            case .deadlineDetail:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: DeadlineValueCell.reuseID, for: indexPath) as? DeadlineValueCell
                else { return UITableViewCell() }
                cell.onChange = { [weak self] newVal in
                    self?.deadlineValue = newVal
                }
                return cell
            }
        }
        
        if isQuestionRow(indexPath) {
            let localIndex = indexPath.row - optionRows.count - 2
            guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionCell.reuseID, for: indexPath) as? QuestionCell
            else { return UITableViewCell() }
            cell.configure(with: rows[localIndex], index: localIndex)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddQuestionCell.reuseID, for: indexPath) as? AddQuestionCell else { return UITableViewCell() }
        cell.configure { [weak self] in self?.onAddQuestion?() }
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat { .leastNormalMagnitude }
    
    func tableView(
        _ tableView: UITableView,
        heightForFooterInSection section: Int
    ) -> CGFloat { .leastNormalMagnitude }
}

extension CreateTestViewController {
    // MARK: - CreateTestViewProtocol

    func setLoading(_ loading: Bool) {
        view.isUserInteractionEnabled = !loading
        loading ? UINotificationFeedbackGenerator().prepare() : ()
    }

    func fillFromEdit(_ dto: EditTestResponse) {
        titleText = dto.title
        titleInputView.configure(text: titleText, placeholder: "Придумайте название") { [weak self] text in
            self?.titleText = text
            self?.updateHeaderSizeFitting()
        }

        isPublished = dto.published
        setPublishedUI(dto.published)

        if let ttl = dto.timeLimitSec {
            timeLimitOn = true
            ttlMinutesValue = max(1, ttl / 60)
            durationPicker.countDownDuration = TimeInterval(ttlMinutesValue * 60)
        } else {
            timeLimitOn = false
        }

        if let dd = dto.deadlineAt {
            deadlineOn = true
            deadlineValue = dd
        } else {
            deadlineOn = false
            deadlineValue = nil
        }
        
        if dto.assignedMode != .all {
            let ids = Set(dto.assignees)
            currentSelection = .some(ids)
        }

        rows = dto.questions.enumerated().map { idx, q in
            QuestionRow(id: UUID(), title: q.text, kind: q.type.rawValue)
        }

        tableView.reloadData()
        updateHeaderSizeFitting()
    }

    func setCode(_ code: Int) {
        let spaced = String(code).map(String.init).joined(separator: " ")
        codeRowView.setCode(spaced)
        codeRowView.setEnabled(true)
    }

    func setPublishedUI(_ published: Bool) {
        isPublished = published
        if published {
            switchToPublishedBottomBar()
        } else {
            switchToDraftBottomBar()
        }
    }

    func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    func routeToProgress(for id: UUID) {
        // TODO: сюда в будущем роут на экран результатов
        // Пока заглушка:
        print("routeToProgress: \(id)")
    }
    
    private func switchToPublishedBottomBar() {
        bottomBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let stopButton = PrimaryActionButton(title: "Остановить")
        let resultsButton = PrimaryActionButton(title: "Результаты")
        bottomBar.addArrangedSubview(stopButton)
        bottomBar.addArrangedSubview(resultsButton)

        stopButton.addTarget(self, action: #selector(stopTapped), for: .touchUpInside)
        resultsButton.addTarget(self, action: #selector(resultsTapped), for: .touchUpInside)

        updateTableInsets()
    }

    private func switchToDraftBottomBar() {
        bottomBar.arrangedSubviews.forEach { $0.removeFromSuperview() }
        bottomBar.addArrangedSubview(saveButton)
        bottomBar.addArrangedSubview(publishButton)
        updateTableInsets()
    }

    @objc private func stopTapped() {
        guard let id = test else { return }
        let a = UIAlertController(title: "Остановить тест?", message: "Вы уверены, что хотите остановить приём попыток?", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        a.addAction(UIAlertAction(title: "Остановить", style: .destructive, handler: { [weak self] _ in
            self?.presenter?.stopTapped()
        }))
        present(a, animated: true)
    }

    @objc private func resultsTapped() {
        guard let id = test?.id,
        let uuid = UUID(uuidString: id) else { return }
        routeToProgress(for: uuid)
    }
}

extension CreateTestViewController {
    private func presentStudentsPicker() {
        let items: [StudentsPickerViewController.Student] = allStudents.map {
            .init(id: $0.id, firstName: $0.firstName, lastName: $0.lastName, tg: $0.tg)
        }

        let vc = StudentsPickerViewController(
            students: items,
            preselected: currentSelection
        ) { [weak self] newSelection in
            guard let self else { return }
            self.currentSelection = self.normalized(selection: newSelection, total: items.count)
            let first = IndexPath(row: 0, section: 0)
            if let cell = self.tableView.cellForRow(at: first) as? AssignCell {
                cell.configure(.init(title: "Назначен", selection: self.currentSelection, totalCount: self.allStudents.count)) { [weak self] in
                    self?.presentStudentsPicker()
                }
            } else {
                self.tableView.reloadRows(at: [first], with: .none)
            }
        }

        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    private func normalized(selection: StudentSelection, total: Int) -> StudentSelection {
        switch selection {
        case .all: return .all
        case .some(let ids):
            return ids.count == total ? .all : .some(ids)
        }
    }
    
    func setStudents(all: [GetStudentsResponse.Student]) {
        allStudents = all
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AssignCell else { return }
        cell.handleTap()
    }
    
}

// MARK: - PrimaryActionButton (как было)
final class PrimaryActionButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        let baseCfg: UIButton.Configuration = {
            if #available(iOS 26.0, *) { return .bordered() }
            var c = UIButton.Configuration.filled()
            c.baseBackgroundColor = UIColor(white: 1, alpha: 0.14)
            return c
        }()
        var c = baseCfg
        c.cornerStyle = .large
        c.attributedTitle = .init(title, attributes: .init([
            .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
        ]))
        c.baseForegroundColor = .white
        configuration = c
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 56).isActive = true
        layer.cornerRadius = 18
        layer.masksToBounds = true
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class SimpleTextQuestionVC: UIViewController, UITextViewDelegate {
    var onDone: ((String) -> Void)?
    
    private let tv: UITextView = {
        let v = UITextView()
        v.font = UIFont.systemFont(ofSize: 17)
        v.backgroundColor = UIColor(white: 1, alpha: 0.06)
        v.textColor = .white
        v.layer.cornerRadius = 12
        v.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Текст вопроса"
        view.backgroundColor = .black
        view.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tv.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tv.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tv.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = .init(title: "Готово", style: .done, target: self, action: #selector(done))
    }
    
    @objc private func cancel() { dismiss(animated: true) }
    @objc private func done() { onDone?(tv.text); dismiss(animated: true) }
}


