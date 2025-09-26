//
//  TestCell.swift
//  Kolokol
//
//  Created by Кирилл Исаев on 25.09.2025.
//

import UIKit

final class TestCell: UITableViewCell {
    static let cellIdentifier: String = "TestCell"
 
    private let testStatusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 18)
        label.textColor = Colors.textSecondary
        label.text = "Идет"
        return label
    }()
    private let testCode: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "TTCommons-DemiBold", size: 40)
        label.textColor = Colors.textPrimary
        label.text = "672 321"
        return label
    }()
    private let upperStackView: UIStackView = UIStackView()
    
    private var timerLabel: UILabel = UILabel()
    
    private var timer: Timer?
    private var startAt: Date?
    private var deadlineAt: Date?
    
    private var timerText: UILabel = UILabel()
    private var participants: UILabel = UILabel()
    private var participantsText: UILabel = UILabel()
    private var questions: UILabel = UILabel()
    private var questionsText: UILabel = UILabel()
    
    private var timeStackView: UIStackView = UIStackView()
    private var participantsStackView: UIStackView = UIStackView()
    private var questionsStackView: UIStackView = UIStackView()
    private lazy var bottomStackView: UIStackView =
    UIStackView(arrangedSubviews: [timeStackView, participantsStackView, questionsStackView])
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopTimer()
        timerLabel.text = nil
        startAt = nil
        deadlineAt = nil
    }
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        selectionStyle = .none
        backgroundColor = .clear
        configureCellBackground()
        configureUpperStackView()
        configureLabels()
        configureVerticalStackView()
        configureBottomStackView()
    }
    
    private func configureCellBackground() {
        let bg = UIImageView()
        bg.image = UIImage(named: "cellBackground")
        bg.contentMode = .scaleAspectFill
        bg.translatesAutoresizingMaskIntoConstraints = false
        contentView.insertSubview(bg, at: 0)
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: contentView.topAnchor),
            bg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    
    private func configureUpperStackView() {
        contentView.addSubview(upperStackView)
        upperStackView.axis = .vertical
        upperStackView.spacing = 4
        upperStackView.alignment = .leading
        upperStackView.addArrangedSubview(testStatusLabel)
        upperStackView.addArrangedSubview(testCode)
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            upperStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            upperStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func configureLabels() {
        timerLabel = createLabel("")
        timerText = createLabel("Тест не начался")
        participants = createLabel("")
        participantsText = createLabel("участника")
        questions = createLabel("")
        questionsText = createLabel("вопросов")
    }
    
    private func configureVerticalStackView() {
        timeStackView = createVerticalStackView(timerLabel, timerText)
        participantsStackView = createVerticalStackView(participants, participantsText)
        questionsStackView = createVerticalStackView(questions, questionsText)
    }
    
    private func configureBottomStackView() {
        contentView.addSubview(bottomStackView)
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        bottomStackView.alignment = .firstBaseline
        bottomStackView.spacing = 20
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func createVerticalStackView(_ amount: UILabel, _ text: UILabel) -> UIStackView {
        let v = UIStackView(arrangedSubviews: [amount, text])
        v.axis = .vertical
        v.spacing = 2
        v.alignment = .leading
        return v
    }
    
    private func createLabel(_ text: String) -> UILabel {
        let l = UILabel()
        l.font = UIFont(name: "TTCommons-DemiBold", size: 18)
        l.textColor = UIColor(hex: "FFFFFF", alpha: 1)
        l.text = text
        l.textAlignment = .left
        l.numberOfLines = 0
        return l
    }
    
    func configure(_ test: TestModel?, _ testResult: TestResult?) {
        if let test = test {
            configureWithTest(test)
        } else if let testResult = testResult {
            configureWithTestResult(testResult)
        }
    }
    
    private func configureWithTest(_ test: TestModel) {
        if test.published {
            testStatusLabel.text = test.isStopped ? "Окончен" : "Идет"
        } else {
            testStatusLabel.text = "Ждет публикации"
        }
        testCode.text = getCodeString(test.code6)
        participants.text = String(test.participants)
        questions.text = String(test.questions)
        if let publishedAt = test.publishedAt {
            if test.deadlineAt != nil {
                timerText.text = test.isStopped ? "Завершен" : "до конца"
            } else {
                timerText.text = test.isStopped ? "Завершен" : "Лимит по времени"
            }
            startAt = publishedAt
            deadlineAt = test.deadlineAt
            updateNow()
            startTimerIfNeeded()
        }
    }
    
    private func configureWithTestResult(_ testResult: TestResult) {
        if let grade10 = testResult.grade10,
           let submittedAt = testResult.submittedAt {
            testStatusLabel.text = "Оценено"
            testCode.text = getCodeString(testResult.code6)
            timerLabel.text = String(grade10) // превращаем timerLabel в gradeLabel(чтобы не дублировать код)
            timerText.text = "Оценка"
            participants.text = "Сдано в"
            participantsText.text = formatDate(submittedAt)
            questions.text = ""
            questionsText.text = ""
        } else {
            testStatusLabel.text = "Ждет оценивания"
            testCode.text = getCodeString(testResult.code6)
            timerText.text = "Нет оценки"
            participants.text = "Не сдано"
            participantsText.text = ""
            questions.text = ""
            questionsText.text = ""
        }
    }
    
    private func getCodeString(_ str: String) -> String {
        let n = Int(str) ?? 123456
        let firstThree = n / 1000
        let secondThree = n % 1000
        let code = String(firstThree) + " " + String(secondThree)
        return code
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        
        if calendar.isDateInToday(date) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else {
            dateFormatter.dateFormat = "dd/MM/yyyy"
        }
        
        return dateFormatter.string(from: date)
    }
    
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateNow()
        }
        // чтобы не тормозил скролл
        RunLoop.current.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateNow() {
        guard let start = startAt, let end = deadlineAt else { return }
        let now = Date()

        // если ещё не началось — показываем до старта, по желанию можно скрывать
        let effectiveStart = min(max(now, start), end)

        let remaining = max(0, Int(end.timeIntervalSince(effectiveStart)))
        if remaining == 0 {
            timerLabel.text = "00:00"
            testStatusLabel.text = "Окончен"
            stopTimer()
            return
        }
        timerLabel.text = Self.format(remainingSeconds: remaining)
    }

    private static func format(remainingSeconds: Int) -> String {
        let sec = remainingSeconds
        let day = sec / 86400
        if day >= 1 {
            let hours = (sec % 86400) / 3600
            return String(format: "%02d:%02d", day, hours)
        }
        let hours = sec / 3600
        if hours >= 1 {
            let minutes = (sec % 3600) / 60
            return String(format: "%02d:%02d", hours, minutes)
        } else {
            let minutes = (sec % 3600) / 60
            let seconds = sec % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    deinit {
        stopTimer()
    }
}
