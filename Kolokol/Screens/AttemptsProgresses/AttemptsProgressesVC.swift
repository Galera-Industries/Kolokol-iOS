//
//  AttemptsProgressesVC.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

final class AttemptsProgressesVC: UIViewController, AttemptsView {
    enum Section { case main }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var dataSource: UITableViewDiffableDataSource<Section, UUID>!
    
    private var itemsById: [UUID: AttemptDisplayItem] = [:]
    
    var presenter: AttemptsPresenterProtocol!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Прогресс теста"
        view.backgroundColor = .systemBackground
        setupTable()
        setupDataSource()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.attach()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent || self.isBeingDismissed {
            presenter.detach()
        }
    }
    
    private func setupTable() {
        tableView.register(AttemptProgressCell.self, forCellReuseIdentifier: AttemptProgressCell.reuseId)
        tableView.rowHeight = 60
        tableView.separatorStyle = .singleLine
        view.addSubview(tableView)
        tableView.pinTop(view.safeAreaLayoutGuide.topAnchor, 0)
        tableView.pinLeft(view.safeAreaLayoutGuide.leadingAnchor, 0)
        tableView.pinRight(view.safeAreaLayoutGuide.trailingAnchor, 0)
        tableView.pinTop(view.bottomAnchor, 0)
    }
    
    private var lastItemsById: [UUID: AttemptDisplayItem] = [:]
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UUID>(tableView: tableView) { [weak self] tableView, indexPath, attemptId in
            guard
                let self,
                let cell = tableView.dequeueReusableCell(withIdentifier: AttemptProgressCell.reuseId, for: indexPath) as? AttemptProgressCell,
                let item = self.itemsById[attemptId]
            else { return UITableViewCell() }
            let was = self.lastItemsById[attemptId]
            let changed = was?.answered != item.answered || was?.total != item.total || was?.fullName != item.fullName
            cell.configure(fullName: item.fullName, answered: item.answered, total: item.total, animated: changed)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    @MainActor
    func render(items: [AttemptDisplayItem], animate: Bool) {
        let newById = Dictionary(uniqueKeysWithValues: items.map { ($0.attemptId, $0) })
        itemsById = newById
        
        let idsInOrder = items.map(\.attemptId)
        let changedIds: [UUID] = idsInOrder.filter { id in
            guard let new = newById[id] else { return false }
            let old = lastItemsById[id]
            return old == nil || old!.answered != new.answered || old!.total != new.total || old!.fullName != new.fullName
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(idsInOrder, toSection: .main)
        
        if #available(iOS 15.0, *) {
            snapshot.reconfigureItems(changedIds)
        } else {
            snapshot.reloadItems(changedIds)
        }
        
        dataSource.apply(snapshot, animatingDifferences: animate)
        lastItemsById = newById
        
        tableView.backgroundView = items.isEmpty ? {
            let lb = UILabel()
            lb.text = "Пока никого"
            lb.textAlignment = .center
            lb.textColor = .secondaryLabel
            return lb
        }() : nil
    }
}
