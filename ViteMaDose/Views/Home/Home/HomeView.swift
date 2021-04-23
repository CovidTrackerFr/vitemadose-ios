//
//  HomeView.swift
//  ViteMaDose
//
//  Created by Yannick Heinrich on 23/04/2021.
//

import UIKit

final class HomeView: UIView {

    // MARK: - iVar | Subviews
    weak private(set) var refreshControl: UIRefreshControl!

    private(set) lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private(set) lazy var footerView: HomePartnersFooterView = {
        let view: HomePartnersFooterView = HomePartnersFooterView.instanceFromNib()
        view.isHidden = true
        return view
    }()

    private(set) weak var tableView: UITableView!

    /// :nodoc:
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Logo
        let logo = UIImage(named: "logo")
        let logoView = UIImageView(image: logo)
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(logoView)

        // TableView
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.allowsMultipleSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .athensGray
        tableView.alwaysBounceVertical = false
        tableView.separatorStyle = .none
        tableView.register(cellType: HomeTitleCell.self)
        tableView.register(cellType: HomeCountySelectionCell.self)
        tableView.register(cellType: HomeCountyCell.self)
        tableView.register(cellType: HomeStatsCell.self)

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        // Refresh Control
        let refresh = UIRefreshControl()
        tableView.refreshControl = refresh
        self.refreshControl = refresh

        // Footer/background
        tableView.backgroundView = activityIndicator
        tableView.tableFooterView = footerView

        self.addSubview(tableView)
        self.tableView = tableView

        // Constraints
        let safeArea = self.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // Logo
            logoView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24.0),
            logoView.trailingAnchor.constraint(lessThanOrEqualTo: safeArea.leadingAnchor, constant: -24.0),
            logoView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            logoView.widthAnchor.constraint(equalTo: logoView.heightAnchor, multiplier: 83.0/25.0),
            logoView.heightAnchor.constraint(equalToConstant: 80.0),

            // TableView
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 10.0),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    /// :nodoc:
    required init?(coder: NSCoder) {
        fatalError("not used")
    }
}
