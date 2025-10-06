//
//  TestVC.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

final class TestViewController: UIViewController, TestViewProtocol {
    var presenter: TestPresenterProtocol?

    private var answers: [String] = []
    private var questions: [StudentQuestion] = []
    
    private var tableBottomToNextButton: NSLayoutConstraint?
    private var tableBottomToKeyboard: NSLayoutConstraint?
    private var selectedIndex: IndexPath?
    private weak var waitingTitleStack: UIStackView?
    private weak var countdownLabel: UILabel?
    private weak var waitingWhiteCover: UIView?
    
    private var isWaitingAnimating = false

    
    // MARK: - UI Components
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:59"
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var numbersCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cv.register(TestNumberCell.self, forCellWithReuseIdentifier: TestNumberCell.reuseID)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Далее", for: .normal)
        button.setTitleColor(Colors.textPrimary, for: .normal)
        button.backgroundColor = Colors.surfacePrimary
        button.titleLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        button.layer.cornerRadius = 32
        button.setHeight(86)
        button.addTarget(self, action: #selector(nextButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.keyboardDismissMode = .interactive
        tv.register(TestAnswerCell.self, forCellReuseIdentifier: TestAnswerCell.reuseID)
        tv.register(TestQuestionCell.self, forCellReuseIdentifier: TestQuestionCell.reuseID)
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var waitingOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        
        let bg = UIImageView(image: UIImage(named: "background"))
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.contentMode = .scaleAspectFill
        v.addSubview(bg)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Waiting room"
        title.textColor = Colors.textPrimary
        title.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        title.textAlignment = .center
        title.numberOfLines = 1
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Ждем пока \nвсе подключатся"
        subtitle.textColor = Colors.textSecondary
        subtitle.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        subtitle.textAlignment = .center
        subtitle.numberOfLines = 0
        
        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        v.addSubview(stack)
        
        let countdown = UILabel()
        countdown.translatesAutoresizingMaskIntoConstraints = false
        countdown.textColor = Colors.textPrimary
        countdown.font = UIFont(name: "TTCommons-DemiBold", size: 140)
        countdown.textAlignment = .center
        countdown.alpha = 0
        v.addSubview(countdown)
        
        let whiteCover = UIView()
        whiteCover.translatesAutoresizingMaskIntoConstraints = false
        whiteCover.backgroundColor = .white
        whiteCover.alpha = 0
        v.addSubview(whiteCover)
        
        bg.pinTop(v.topAnchor, 0)
        bg.pinBottom(v.bottomAnchor, 0)
        bg.pinLeft(v.leadingAnchor, 0)
        bg.pinRight(v.trailingAnchor, 0)
        
        stack.pinCenterX(v.centerXAnchor)
        stack.pinCenterY(v.centerYAnchor)
        
        countdown.pinCenterX(v.centerXAnchor)
        countdown.pinCenterY(v.centerYAnchor)
        
        whiteCover.pinTop(v.topAnchor, 0)
        whiteCover.pinBottom(v.bottomAnchor, 0)
        whiteCover.pinRight(v.trailingAnchor, 0)
        whiteCover.pinLeft(v.leadingAnchor, 0)
        
        self.waitingTitleStack = stack
        self.countdownLabel = countdown
        self.waitingWhiteCover = whiteCover
        
        return v
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        configureBackground()
        configureNavbar()
        configureConstraints()
        setupDismissKeyboardGesture()
        
        timerLabel.hideOnCapture()
        numbersCollectionView.hideOnCapture()
        nextButton.hideOnCapture()
        questionLabel.hideOnCapture()
        tableView.hideOnCapture()

        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        presenter?.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    func showQuestions(_ questions: [StudentQuestion]) {
        self.questions = questions
        self.answers = Array(repeating: "", count: questions.count)
        
        selectedIndex = IndexPath(item: 0, section: 0)
        questionLabel.text = questions.first?.text
        
        numbersCollectionView.reloadData()
        numbersCollectionView.layoutIfNeeded()
        
        if let index = selectedIndex {
            numbersCollectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
            if let cell = numbersCollectionView.cellForItem(at: index) as? TestNumberCell {
                cell.configure(number: index.item + 1,
                               selected: true,
                               hasAnswer: hasAnswer(at: index.item))
            }
        }
        
        updateNextButtonTitle()
        tableView.reloadData()
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    
    func showError(_ error: String) {
        let ac = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func showWaitingRoom() {
        waitingOverlay.isHidden = false
        waitingOverlay.alpha = 1.0
        waitingWhiteCover?.alpha = 0.0
        
        waitingTitleStack?.alpha = 1.0
        waitingTitleStack?.transform = .identity
        
        countdownLabel?.alpha = 0.0
        countdownLabel?.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        countdownLabel?.text = nil
        
        isWaitingAnimating = false
    }
    
    func hideWaitingRoom() {
        guard !waitingOverlay.isHidden, !isWaitingAnimating else {
            return
        }
        isWaitingAnimating = true
        
        let collapseDuration: TimeInterval = 0.2
        UIView.animate(withDuration: collapseDuration, delay: 0, options: [.curveEaseIn], animations: {
            self.waitingTitleStack?.alpha = 0.0
            self.waitingTitleStack?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            self.playCountdownSequence {
                self.finishWaitingOverlay()
            }
        })
    }
    
    // MARK: - Private Methods
    private func playCountdownSequence(completion: @escaping () -> Void) {
        animateDigit("3") { [weak self] in
            self?.animateDigit("2") { [weak self] in
                self?.animateDigitOneAndFlash { [weak self] in
                    completion()
                }
            }
        }
    }
    
    private func animateDigit(_ text: String, completion: @escaping () -> Void) {
        guard let label = countdownLabel else { return completion() }
        
        label.text = text
        label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        label.alpha = 0.0
        
        // Фаза появления (0.35s)
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: {
            label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            label.alpha = 1.0
        }, completion: { _ in
            // Фаза исчезновения (0.65s)
            UIView.animate(withDuration: 0.65, delay: 0, options: [.curveEaseIn], animations: {
                label.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                label.alpha = 0.0
            }, completion: { _ in
                completion()
            })
        })
    }
    
    private func animateDigitOneAndFlash(completion: @escaping () -> Void) {
        guard let label = countdownLabel else { return completion() }
        
        label.text = "1"
        label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        label.alpha = 0.0
        
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut], animations: {
            label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            label.alpha = 1.0
        }, completion: { _ in
            let bigScale: CGFloat = 0.1
            
            UIView.animate(withDuration: 0.65, delay: 0, options: [.curveEaseIn], animations: {
                label.transform = CGAffineTransform(scaleX: bigScale, y: bigScale)
                self.waitingWhiteCover?.alpha = 1.0
            }, completion: { _ in
                completion()
            })
        })
    }
    
    private func finishWaitingOverlay() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.curveEaseInOut], animations: {
            self.waitingOverlay.alpha = 0.0
        }, completion: { _ in
            self.waitingOverlay.isHidden = true
            self.isWaitingAnimating = false
        })
    }
    
    private func configureNavbar() {
        // title
        navigationItem.title = "Kollocol"
        
        let titleFont = UIFont(name: "TTCommons-DemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: Colors.textSecondary
        ]
        
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        // back button
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
    
    private func setupDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRootTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func configureConstraints() {
        // timerLabel
        view.addSubview(timerLabel)
        timerLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 32)
        timerLabel.pinLeft(view.leadingAnchor, 16)

        // numbersCollectionView
        view.addSubview(numbersCollectionView)
        numbersCollectionView.pinTop(timerLabel.bottomAnchor, 12)
        numbersCollectionView.pinLeft(view.leadingAnchor, 0)
        numbersCollectionView.pinRight(view.trailingAnchor, 0)
        numbersCollectionView.setHeight(60)

        // nextButton
        view.addSubview(nextButton)
        nextButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 0)
        nextButton.pinLeft(view.leadingAnchor, 16)
        nextButton.pinCenterX(view.centerXAnchor)

        // tableView
        view.addSubview(tableView)
        tableView.pinTop(numbersCollectionView.bottomAnchor, 32)
        tableView.pinLeft(view.leadingAnchor, 16)
        tableView.pinRight(view.trailingAnchor, 16)
        tableBottomToNextButton = tableView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -32)
        tableBottomToNextButton?.isActive = true

        tableBottomToKeyboard = tableView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        tableBottomToKeyboard?.isActive = false

        // waitingOverlay
        view.addSubview(waitingOverlay)
        waitingOverlay.pinTop(view.topAnchor, 0)
        waitingOverlay.pinBottom(view.bottomAnchor, 0)
        waitingOverlay.pinLeft(view.leadingAnchor, 0)
        waitingOverlay.pinRight(view.trailingAnchor, 0)
    }
    
    private func selectNumber(at indexPath: IndexPath,
                              animated: Bool = true,
                              scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally) {
        guard indexPath.item < questions.count, !questions.isEmpty else { return }
        
        if let oldItem = selectedIndex?.item, oldItem != indexPath.item {
            reportAnsweredIfNeeded(for: oldItem)
        }
        
        let old = selectedIndex
        selectedIndex = indexPath
        
        var toUpdate: [IndexPath] = [indexPath]
        if let old = old, old != indexPath { toUpdate.append(old) }
        
        for ip in toUpdate {
            if let cell = numbersCollectionView.cellForItem(at: ip) as? TestNumberCell {
                cell.configure(number: ip.item + 1,
                               selected: ip == selectedIndex,
                               hasAnswer: hasAnswer(at: ip.item))
            }
        }
        
        numbersCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
        if let old = old, old != indexPath { numbersCollectionView.deselectItem(at: old, animated: false) }
        
        questionLabel.text = questions[indexPath.item].text
        
        let answerIndexPath = IndexPath(row: 1, section: 0)
        tableView.reloadRows(at: [answerIndexPath], with: .none)
        
        updateNextButtonTitle()
    }
    
    private func updateNextButtonTitle() {
        guard let idx = selectedIndex else {
            nextButton.setTitle("Далее", for: .normal)
            return
        }
        let last = max(questions.count - 1, 0)
        nextButton.setTitle(idx.item == last ? "Завершить" : "Далее", for: .normal)
    }
    
    private func presentFinishSheet() {
        let alert = UIAlertController(title: nil, message: "Уверен, что хочешь завершить?", preferredStyle: .actionSheet)
        
        let finish = UIAlertAction(title: "Закончить", style: .destructive) { [weak self] _ in
            // TODO: обработка завершения
            self?.presenter?.submit()
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(finish)
        alert.addAction(cancel)
        
        if let pop = alert.popoverPresentationController {
            pop.sourceView = view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 1, width: 0, height: 0)
            pop.permittedArrowDirections = []
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func animateAlongsideKeyboard(_ note: Notification) {
        let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (note.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hasAnswer(at index: Int) -> Bool {
        guard index >= 0, index < answers.count else { return false }
        return !answers[index].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Отправляет сообщение на бек, что на вопрос с данным индексом был дан ответ
    private func reportAnsweredIfNeeded(for index: Int) {
        guard hasAnswer(at: index),
              let id = UUID(uuidString: questions[index].id) else { return }
        // TODO: - дергаем презентер
        print("Отправляем данные на бек что дан ответ на вопрос")
        presenter?.answer(id, answers[index].trimmingCharacters(in: .whitespacesAndNewlines))
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
    private func nextButtonPressed() {
        guard !questions.isEmpty else { return }
        
        guard let current = selectedIndex else {
            let first = IndexPath(item: 0, section: 0)
            selectNumber(at: first, animated: true)
            return
        }
        let lastIndex = max(questions.count - 1, 0)
        if current.item == lastIndex {
            reportAnsweredIfNeeded(for: current.item)
            presentFinishSheet()
        } else {
            reportAnsweredIfNeeded(for: current.item)
            let next = IndexPath(item: current.item + 1, section: 0)
            selectNumber(at: next, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    @objc
    private func handleKeyboardWillShow(_ note: Notification) {
        tableBottomToNextButton?.isActive = false
        tableBottomToKeyboard?.isActive = true
        animateAlongsideKeyboard(note)
    }
    
    @objc
    private func handleKeyboardWillHide(_ note: Notification) {
        tableBottomToKeyboard?.isActive = false
        tableBottomToNextButton?.isActive = true
        animateAlongsideKeyboard(note)
    }
    
    @objc
    private func handleRootTap() {
        view.endEditing(true)
    }
}

// MARK: - CollectionVie DataSource & Delegate
extension TestViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        questions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestNumberCell.reuseID, for: indexPath) as? TestNumberCell
        else { fatalError() }
        let answered = hasAnswer(at: indexPath.item)
        cell.configure(number: indexPath.item + 1,
                       selected: indexPath == selectedIndex,
                       hasAnswer: answered)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 48, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == selectedIndex { return }
        selectNumber(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

// MARK: - UITableView DataSource & Delegate
extension TestViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: TestQuestionCell.reuseID, for: indexPath) as? TestQuestionCell
            else { fatalError() }
            cell.hostLabel(questionLabel, bottomPadding: 32)

            cell.contentView.hideOnCapture()
            return cell
        } else {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: TestAnswerCell.reuseID, for: indexPath) as? TestAnswerCell
            else { fatalError() }
            let currentIndex = selectedIndex?.item ?? 0
            let currentText = (currentIndex < answers.count) ? answers[currentIndex] : ""

            cell.configure(font: questionLabel.font,
                           color: Colors.textSecondary,
                           alignment: questionLabel.textAlignment,
                           text: currentText)

            cell.contentView.hideOnCapture()

            cell.onTextChange = { [weak self] text in
                guard let self = self,
                      let idx = self.selectedIndex?.item,
                      idx < self.answers.count else { return }
                self.answers[idx] = text

                let ip = IndexPath(item: idx, section: 0)
                if let numberCell = self.numbersCollectionView.cellForItem(at: ip) as? TestNumberCell {
                    let answered = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    numberCell.setHasAnswer(answered)
                }
            }

            cell.onHeightChange = { [weak self] in
                self?.tableView.performBatchUpdates(nil)
            }

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.hideOnCapture()
    }
}
