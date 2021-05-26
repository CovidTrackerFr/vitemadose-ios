// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GPL-3.0
//
// This software is distributed under the GNU General Public License v3.0 only.
//
// Author: Pierre-Yves LAPERSONNE <dev(at)pylapersonne(dot)info> et al.

import Foundation
import UIKit
import Haptica

/// `UIViewController` dedicated to the settings screen.
final class SettingsViewController: UIViewController, Storyboarded {

    @IBOutlet private var tableView: UITableView!

    /// Cells to add in the embeded `tableView`
    private lazy var cellsTypes: [SettingsDataType] = [
        .website, .contact, .twitter, .appSourceCode, .systemSettings
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

// MARK: - UI Table View Delegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.impact(.light).generate()
        // TODO: Analytics?
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return cellsTypes.count
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
            let data = SettingsCellViewData(cellsTypes[indexPath.item])
            cell.configure(with: data)
            return cell
        }
    }
}
