//
//  AttemptsProgressesVC.swift
//  Kolokol
//
//  Created by Tom Tim on 21.09.2025.
//

import UIKit

final class AttemptsProgressesVC: UIViewController, AttemptsView, UITableViewDelegate {
    func showPublishResult() {
        //
    }
    
    enum Section { case remaining, ready }
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var dataSource: UITableViewDiffableDataSource<Section, UUID>?
    
    private var itemsById: [UUID: AttemptDisplayItem] = [:]
    private var lastItemsById: [UUID: AttemptDisplayItem] = [:]
    
    private var orderRemaining: [UUID] = []
    private var orderReady: [UUID] = []
    
    private var remainingCount: Int = 0
    private var totalCount: Int = 0
    private var prevRemainingCount: Int = -1
    private var prevTotalCount: Int = -1
    
    let publishButton = UIButton()
    
    private let headerReuseID = "hdr"
    
    var presenter: AttemptsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Результаты"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        edgesForExtendedLayout = [.top]
        extendedLayoutIncludesOpaqueBars = true
        
        setupTable()
        setupDataSource()
        configureUI()
        configureNavBarAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.attach()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent || self.isBeingDismissed {
            presenter?.detach()
        }
    }
    
    private func configureNavBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        let navBar = navigationController!.navigationBar
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = .white
    }
    
    private func configureUI() {
        configureBackground()
        view.addSubview(publishButton)
        publishButton.isHidden = true
        publishButton.isEnabled = false
        publishButton.alpha = 0
        publishButton.configureMainButton(with: "Опубликовать")
        publishButton.pinLeft(view.leadingAnchor, 20)
        publishButton.pinRight(view.trailingAnchor, 20)
        publishButton.pinBottom(view.bottomAnchor, 36)
//        publishButton.addTarget(self, action: #selector(<#T##@objc method#>), for: .touchUpInside)
    }
    
    private func setupTable() {
        tableView.register(AttemptProgressCell.self, forCellReuseIdentifier: AttemptProgressCell.reuseId)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerReuseID)
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .automatic
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 8 }
        tableView.delegate = self
        
        view.addSubview(tableView)
        tableView.pinTop(view.topAnchor, 0)
        tableView.pinLeft(view.leadingAnchor, 0)
        tableView.pinRight(view.trailingAnchor, 0)
        tableView.pinBottom(view.bottomAnchor, 0)
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, UUID>(tableView: tableView) { [weak self] tableView, indexPath, attemptId in
            guard
                let self,
                let cell = tableView.dequeueReusableCell(withIdentifier: AttemptProgressCell.reuseId, for: indexPath) as? AttemptProgressCell,
                let item = self.itemsById[attemptId]
            else { return UITableViewCell() }
            let was = self.lastItemsById[attemptId]
            let changed = was?.answered != item.answered || was?.total != item.total || was?.fullName != item.fullName
            cell.configure(fullName: item.fullName, tg: item.tg, answered: item.answered, total: item.total, animated: changed, assessed: item.assessed, result: item.result)
            return cell
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.remaining, .ready])
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sections = dataSource?.snapshot().sectionIdentifiers, section < sections.count else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseID)!
        view.contentView.backgroundColor = .clear
        view.textLabel?.textColor = .white
        view.textLabel?.font = UIFont(name: "TTCommons-DemiBold", size: 24)
        switch sections[section] {
        case .remaining:
            view.textLabel?.text = "Осталось \(remainingCount) из \(totalCount)"
        case .ready:
            view.textLabel?.text = "Готовы"
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 32 }
    
    @MainActor
    func render(items: [AttemptDisplayItem], animate: Bool) {
        let newById = Dictionary(uniqueKeysWithValues: items.map { ($0.attemptId, $0) })
        itemsById = newById
        
        totalCount = items.count
        
        let remainingIDsSet = Set(items.filter { !$0.assessed }.map(\.attemptId))
        let readyIDsSet = Set(items.filter { $0.assessed }.map(\.attemptId))
        remainingCount = remainingIDsSet.count
        
        var newOrderRemaining = orderRemaining.filter { remainingIDsSet.contains($0) }
        var newOrderReady = orderReady.filter { readyIDsSet.contains($0) }
        
        for id in remainingIDsSet where !newOrderRemaining.contains(id) { newOrderRemaining.insert(id, at: 0) }
        for id in readyIDsSet where !newOrderReady.contains(id) { newOrderReady.insert(id, at: 0) }
        
        orderRemaining = newOrderRemaining
        orderReady = newOrderReady
        if orderRemaining.isEmpty {
            publishButton.isUserInteractionEnabled = false
            publishButton.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.publishButton.alpha = 1
            }, completion: { _ in
                self.publishButton.isUserInteractionEnabled = true
            })
        } else {
            publishButton.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.publishButton.alpha = 0
            }, completion: { _ in
                self.publishButton.isHidden = true
            })
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
        snapshot.appendSections([.remaining, .ready])
        snapshot.appendItems(orderRemaining, toSection: .remaining)
        snapshot.appendItems(orderReady, toSection: .ready)
        
        let changedIds: [UUID] = newById.compactMap { id, new in
            guard let old = lastItemsById[id] else { return nil }
            return (old.answered != new.answered || old.total != new.total || old.fullName != new.fullName) ? id : nil
        }
        if #available(iOS 15.0, *) {
            let presentIds = Set(orderRemaining + orderReady)
            snapshot.reconfigureItems(changedIds.filter { presentIds.contains($0) })
        } else {
            snapshot.reloadItems(changedIds)
        }
        
        let headersChanged = (prevRemainingCount != remainingCount) || (prevTotalCount != totalCount)
        if headersChanged {
            dataSource?.applySnapshotUsingReloadData(snapshot)
        } else {
            dataSource?.apply(snapshot, animatingDifferences: animate)
        }
        
        prevRemainingCount = remainingCount
        prevTotalCount = totalCount
        lastItemsById = newById
        
        tableView.backgroundView = nil
    }
}
