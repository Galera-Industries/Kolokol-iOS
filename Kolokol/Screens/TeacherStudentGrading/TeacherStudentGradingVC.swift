//
//  TestVC.swift
//  Kolokol
//
//  Created by Арсений Потякин on 22.09.2025.
//

import UIKit

final class TeacherStudentGradingViewController: UIViewController, TeacherStudentGradingViewProtocol {

    var presenter: TeacherStudentGradingPresenterProtocol?

    private var answers: [String] = []
    private var questions: [String] = []
    private var scores: [Int] = []
    private var commentsPerTask: [String] = []

    private var inputBottomToNextButton: NSLayoutConstraint?
    private var inputBottomToKeyboard: NSLayoutConstraint?

    private var selectedIndex: IndexPath?
    private weak var waitingTitleStack: UIStackView?
    private weak var countdownLabel: UILabel?
    private weak var waitingWhiteCover: UIView?

    private var isWaitingAnimating = false

    // MARK: - UI Components
    private lazy var studentNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textPrimary
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var gradingStepper = GradingStepperView()

    private lazy var commentTextField: UITextField = {
        let tf = UITextField()
        tf.backgroundColor = Colors.surfaceSecondary
        tf.layer.cornerRadius = 32
        tf.clipsToBounds = true
        tf.textColor = Colors.textPrimary
        tf.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        tf.attributedPlaceholder = NSAttributedString(
            string: "Комментарий",
            attributes: [
                .foregroundColor: Colors.textSecondary,
                .font: UIFont(name: "TTCommons-DemiBold", size: 24) as Any
            ]
        )
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        tf.addTarget(self, action: #selector(commentChanged(_:)), for: .editingChanged)
        return tf
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
        tv.register(TestAnswerLabelCell.self, forCellReuseIdentifier: TestAnswerLabelCell.reuseID)
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

    private var loadingCover: UIView?
    private lazy var rings = LoadingRingsView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureNavbar()
        configureConstraints()
        setupDismissKeyboardGesture()

        gradingStepper.onChange = { [weak self] newValue in
            guard let self, let idx = self.selectedIndex?.item, idx < self.scores.count else { return }
            self.scores[idx] = newValue
        }

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

    func setLoading(_ active: Bool) {
        active ? showLoader() : hideLoader()
    }

    private func showLoader() {
        guard loadingCover == nil else { return }

        let cover = UIImageView()
        cover.image = UIImage(named: "background")
        cover.contentMode = .scaleAspectFill
        cover.isUserInteractionEnabled = true
        view.addSubview(cover)

        cover.pin(view, 0)

        rings.lineWidth = 4
        rings.colors = [
            UIColor.systemRed.withAlphaComponent(0.95),
            UIColor.systemRed.withAlphaComponent(0.7),
            UIColor.systemRed.withAlphaComponent(0.5)
        ]

        cover.addSubview(rings)
        rings.pinCenter(cover)
        rings.setWidth(40)
        rings.setHeight(40)

        loadingCover = cover
        rings.start()
    }

    private func hideLoader() {
        rings.stop()
        loadingCover?.removeFromSuperview()
        loadingCover = nil
    }

    func showQuestions(_ questions: [String]) {
        self.questions = questions

        self.answers = Array(repeating: "Some answerr", count: questions.count)

        self.scores = Array(repeating: 0, count: questions.count)
        self.commentsPerTask = Array(repeating: "", count: questions.count)

        selectedIndex = IndexPath(item: 0, section: 0)
        guard let selectedIndex = selectedIndex else { return }
        questionLabel.text = questions[selectedIndex.row]

        numbersCollectionView.reloadData()
        numbersCollectionView.layoutIfNeeded()

        if let index = self.selectedIndex {
            numbersCollectionView.selectItem(at: index, animated: false, scrollPosition: .centeredHorizontally)
            if let cell = numbersCollectionView.cellForItem(at: index) as? TestNumberCell {
                cell.configure(number: index.item + 1,
                               selected: true,
                               hasAnswer: hasAnswer(at: index.item))
            }
        }

        gradingStepper.setValue(scores.first ?? 0, animated: false)
        commentTextField.text = commentsPerTask.first ?? ""

        updateNextButtonTitle()
        tableView.reloadData()
    }

    func showStudentName(_ name: String) {
        studentNameLabel.text = name
    }

    func showAnswers(_ answers: [String]) {
        self.answers = answers
    }

    func showError(_ error: String) {
        let ac = UIAlertController(title: "Ошибка", message: error, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
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
        // studentNameLabel
        view.addSubview(studentNameLabel)
        studentNameLabel.pinTop(view.safeAreaLayoutGuide.topAnchor, 32)
        studentNameLabel.pinLeft(view.leadingAnchor, 16)

        // numbersCollectionView
        view.addSubview(numbersCollectionView)
        numbersCollectionView.pinTop(studentNameLabel.bottomAnchor, 12)
        numbersCollectionView.pinLeft(view.leadingAnchor, 0)
        numbersCollectionView.pinRight(view.trailingAnchor, 0)
        numbersCollectionView.setHeight(60)

        // nextButton
        view.addSubview(nextButton)
        nextButton.pinBottom(view.safeAreaLayoutGuide.bottomAnchor, 0)
        nextButton.pinLeft(view.leadingAnchor, 16)
        nextButton.pinCenterX(view.centerXAnchor)

        // tableView (вопрос + ответ-лейбл)
        view.addSubview(tableView)
        tableView.pinTop(numbersCollectionView.bottomAnchor, 32)
        tableView.pinLeft(view.leadingAnchor, 16)
        tableView.pinRight(view.trailingAnchor, 16)

        // Stepper
        view.addSubview(gradingStepper)
        gradingStepper.pinTop(tableView.bottomAnchor, 24)
        gradingStepper.pinLeft(view.leadingAnchor, 16)
        gradingStepper.pinRight(view.trailingAnchor, 16)
        gradingStepper.setHeight(70)

        // Comment
        view.addSubview(commentTextField)
        commentTextField.pinTop(gradingStepper.bottomAnchor, 0)
        commentTextField.pinLeft(view.leadingAnchor, 16)
        commentTextField.pinRight(view.trailingAnchor, 16)
        commentTextField.setHeight(70)

        inputBottomToNextButton = commentTextField.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -24)
        inputBottomToNextButton?.isActive = true

        inputBottomToKeyboard = commentTextField.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        inputBottomToKeyboard?.isActive = false
    }

    private func selectNumber(at indexPath: IndexPath,
                              animated: Bool = true,
                              scrollPosition: UICollectionView.ScrollPosition = .centeredHorizontally) {
        guard indexPath.item < questions.count, !questions.isEmpty else { return }

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

        questionLabel.text = questions[indexPath.row]

        let idx = indexPath.item
        if idx < scores.count { gradingStepper.setValue(scores[idx], animated: false) }
        if idx < commentsPerTask.count { commentTextField.text = commentsPerTask[idx] }

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
        nextButton.setTitle(idx.item == last ? "Итог" : "Далее", for: .normal)
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

    private func reportAnsweredIfNeeded(for index: Int) {
        guard hasAnswer(at: index),
              let id = UUID(uuidString: questions[index]) else { return }
        // TODO: - дергаем презентер
        print("Отправляем данные на бек что дан ответ на вопрос")
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
            // TODO: РОУТ НА ДРУГОЙ ЭКРАН ЧЕРЕЗ ПРЕЗЕНТЕР
            print("РОУТ НА ДРУГОЙ ЭКРАН ЧЕРЕЗ ПРЕЗЕНТЕР")
            return
        } else {
            reportAnsweredIfNeeded(for: current.item)
            let next = IndexPath(item: current.item + 1, section: 0)
            selectNumber(at: next, animated: true, scrollPosition: .centeredHorizontally)
        }
    }

    @objc
    private func handleKeyboardWillShow(_ note: Notification) {
        inputBottomToNextButton?.isActive = false
        inputBottomToKeyboard?.isActive = true
        animateAlongsideKeyboard(note)
    }

    @objc
    private func handleKeyboardWillHide(_ note: Notification) {
        inputBottomToKeyboard?.isActive = false
        inputBottomToNextButton?.isActive = true
        animateAlongsideKeyboard(note)
    }

    @objc
    private func commentChanged(_ tf: UITextField) {
        guard let idx = selectedIndex?.item, idx < commentsPerTask.count else { return }
        commentsPerTask[idx] = tf.text ?? ""
    }

    @objc
    private func handleRootTap() {
        view.endEditing(true)
    }
}

// MARK: - CollectionVie DataSource & Delegate
extension TeacherStudentGradingViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        questions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TestNumberCell.reuseID, for: indexPath) as! TestNumberCell
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
extension TeacherStudentGradingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 2 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TestQuestionCell.reuseID, for: indexPath) as! TestQuestionCell
            cell.hostLabel(questionLabel, bottomPadding: 32)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TestAnswerLabelCell.reuseID, for: indexPath) as! TestAnswerLabelCell
            let currentIndex = selectedIndex?.item ?? 0
            let currentText = (currentIndex < answers.count) ? answers[currentIndex] : ""
            cell.configure(font: questionLabel.font,
                           color: Colors.textSecondary,
                           alignment: questionLabel.textAlignment,
                           text: currentText)
            return cell
        }
    }
}
