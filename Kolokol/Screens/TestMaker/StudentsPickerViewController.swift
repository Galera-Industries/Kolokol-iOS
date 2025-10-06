//
//  StudentsPickerViewController.swift
//  Kolokol
//
//  Created by Tom Tim on 26.09.2025.
//

import UIKit

final class StudentsPickerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    struct Student {
        let id: String
        let firstName: String
        let lastName: String
        let tg: String

        var fullName: String { "\(lastName) \(firstName)" }
    }

    private let students: [Student]
    private var selection: StudentSelection
    private let onDone: (StudentSelection) -> Void

    private let tableView = UITableView(frame: .zero, style: .plain)

    private lazy var indexByID: [String: Int] = {
        var dict: [String: Int] = [:]
        for (i, s) in students.enumerated() { dict[s.id] = i }
        return dict
    }()

    init(students: [Student],
         preselected: StudentSelection,
         onDone: @escaping (StudentSelection) -> Void) {
        self.students = students
        self.selection = preselected
        self.onDone = onDone
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = titleText()

        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))

        let selectAll = UIBarButtonItem(title: "Выбрать всех", style: .plain, target: self, action: #selector(selectAllTapped))
        let clearAll = UIBarButtonItem(title: "Снять все", style: .plain, target: self, action: #selector(clearAllTapped))
        toolbarItems = [selectAll, .flexibleSpace(), clearAll]
        navigationController?.isToolbarHidden = false

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StudentCheckCell.self, forCellReuseIdentifier: StudentCheckCell.reuseId)

        view.addSubview(tableView)
        
        tableView.pinTop(view.safeAreaLayoutGuide.topAnchor, 0)
        tableView.pinLeft(view.leadingAnchor, 0)
        tableView.pinRight(view.trailingAnchor, 0)
        tableView.pinBottom(view.bottomAnchor, 0)

        applyPreselection()
    }

    private func titleText() -> String {
        let total = students.count
        let selectedCount: Int = {
            switch selection {
            case .all: return total
            case .some(let ids): return ids.count
            }
        }()
        return "Выбор студентов (\(selectedCount)/\(total))"
    }

    private func refreshTitle() {
        self.title = titleText()
    }

    private func applyPreselection() {
        switch selection {
        case .all:
            for row in students.indices {
                let ip = IndexPath(row: row, section: 0)
                tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
            }
        case .some(let ids):
            for id in ids {
                if let row = indexByID[id] {
                    tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }
        }
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func doneTapped() {
        onDone(selection)
        dismiss(animated: true)
    }

    @objc private func selectAllTapped() {
        selection = .all
        for row in students.indices {
            let ip = IndexPath(row: row, section: 0)
            tableView.selectRow(at: ip, animated: false, scrollPosition: .none)
            if let cell = tableView.cellForRow(at: ip) as? StudentCheckCell {
                cell.setChecked(true, animated: false)
            }
        }
        refreshTitle()
    }

    @objc private func clearAllTapped() {
        selection = .some([])
        for row in students.indices {
            let ip = IndexPath(row: row, section: 0)
            tableView.deselectRow(at: ip, animated: false)
            if let cell = tableView.cellForRow(at: ip) as? StudentCheckCell {
                cell.setChecked(false, animated: false)
            }
        }
        refreshTitle()
    }

    // MARK: DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { students.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let s = students[indexPath.row]
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: StudentCheckCell.reuseId, for: indexPath) as? StudentCheckCell
        else { fatalError() }

        let isChecked: Bool = {
            switch selection {
            case .all: return true
            case .some(let ids): return ids.contains(s.id)
            }
        }()

        cell.configure(fullName: s.fullName, tg: s.tg, checked: isChecked)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? StudentCheckCell else { return }
        let s = students[indexPath.row]
        let checked: Bool = {
            switch selection {
            case .all: return true
            case .some(let ids): return ids.contains(s.id)
            }
        }()
        cell.setChecked(checked, animated: false)
    }

    // MARK: Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = students[indexPath.row]
        switch selection {
        case .all:
            selection = .some(Set(students.map { $0.id }))
        case .some(var set):
            set.insert(s.id)
            selection = .some(set)
        }
        if let cell = tableView.cellForRow(at: indexPath) as? StudentCheckCell {
            cell.setChecked(true, animated: true)
        }
        refreshTitle()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let s = students[indexPath.row]
        switch selection {
        case .all:
            var set = Set(students.map { $0.id })
            set.remove(s.id)
            selection = .some(set)
        case .some(var set):
            set.remove(s.id)
            selection = .some(set)
        }
        if let cell = tableView.cellForRow(at: indexPath) as? StudentCheckCell {
            cell.setChecked(false, animated: true)
        }
        refreshTitle()
    }
}

