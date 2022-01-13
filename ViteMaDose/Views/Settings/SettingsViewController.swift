// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import Foundation
import Haptica
import SafariServices
import UIKit

/// `UIViewController` dedicated to the settings screen.
final class SettingsViewController: UIViewController, Storyboarded {

    @IBOutlet private var tableView: UITableView!

    /// Cells to add in the embedded `tableView`
    private lazy var cellsTypes: [SettingsDataType] = [
        .header, .website, .contributors, .contact, .twitter, .appSourceCode, .systemSettings
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .athensGray

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .athensGray
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "SettingsTitleCell", bundle: nil), forCellReuseIdentifier: "SettingsTitleCell")
        tableView.register(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // TODO: Analytics?
    }
}

// MARK: - UI Table View Data Source

extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        if index == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTitleCell", for: indexPath) as! SettingsTitleCell
            let data = HomeTitleCellViewData(
                titleText: SettingsTitleCell.mainTitleAttributedText(),
                topMargin: 30,
                bottomMargin: 10
            )
            cell.configure(with: data)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            let data = SettingsCellViewData(cellsTypes[indexPath.item])!
            cell.configure(with: data)
            cell.accessibilityHint = data.voiceOverHint
            return cell
        }
    }
}

// MARK: - UI Table View Delegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Analytics?
        Haptic.impact(.light).generate()
        switch SettingsDataType.init(rawValue: indexPath.item) {
        case .website:
            openUrl("https://covidtracker.fr/")
        case .contributors:
            presentCreditViewController()
        case .contact:
            openUrl("https://covidtracker.fr/contact/")
        case .twitter:
            openUrl("https://twitter.com/ViteMaDose_off")
        case .appSourceCode:
            openUrl("https://github.com/CovidTrackerFr/vitemadose-ios")
        case .systemSettings:
            UIApplication.shared.open(URL(staticString: UIApplication.openSettingsURLString))
        case .header, .none:
            break
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return cellsTypes.count
    }
}

// MARK: - Actions

extension SettingsViewController {

    private func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        Haptic.impact(.light).generate()
        present(safariViewController, animated: true)
    }

    private func presentCreditViewController() {
        let creditViewController = CreditViewController.instantiate()
        creditViewController.viewModel = CreditViewModel(credits: [])

        DispatchQueue.main.async { [weak self] in
            self?.present(creditViewController, animated: true)
        }
    }

}
