//
//  SettingsViewController.swift
//  ViteMaDose
//
//  Created by Corentin Medina on 22/05/2021.
//

import UIKit
import SafariServices

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let title: String
    let icon: UIImage
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
    var isOn: Bool
}

struct SettingsOption {
    let title: String
    let icon: UIImage
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var versionLabel: UILabel!
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.register(SettingsTableViewCell.self,
                       forCellReuseIdentifier: SettingsTableViewCell.identifier)
        table.register(SettingsSwitchTableViewCell.self,
                       forCellReuseIdentifier: SettingsSwitchTableViewCell.identifier)
        return table
    }()

    var models = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureLabel()
        title = Localization.Settings.Main.title
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.allowsSelection = false
        tableView.frame = view.bounds
        tableView.frame = CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.width, height: view.frame.height)
        tableView.layer.cornerRadius = 15
        tableView.layer.masksToBounds = true
        backBarButtonItem.image = UIImage(systemName: "xmark")
        backBarButtonItem.target = self
        backBarButtonItem.action = #selector(close)
    }

    @objc func close() {
        self.dismiss(animated: true, completion: nil)

    }

    func configure() {

        models.append(Section(title: Localization.Settings.SectionTitle.appareance, options: [
            .switchCell(model: SettingsSwitchOption(title: Localization.Settings.CellTitle.darkmode, icon: UIImage(systemName: "moon.fill")!, iconBackgroundColor: .royalBlue, handler: {

            }, isOn: getUserInterfaceStyle()))
        ]))

        models.append(Section(title: Localization.Settings.SectionTitle.contributors, options: [
            .staticCell(model: SettingsOption(title: Localization.Settings.CellTitle.contributors, icon: UIImage(systemName: "person")!, iconBackgroundColor: .royalBlue) {
                // #PR122
            })

        ]))

        models.append(Section(title: Localization.Settings.SectionTitle.useful_links, options: [
            .staticCell(model: SettingsOption(title: Localization.Settings.CellTitle.faq, icon: UIImage(systemName: "questionmark")!, iconBackgroundColor: .systemYellow) {
                self.openURL(url: "https://vitemadose.covidtracker.fr/#about")
            }),

            .staticCell(model: SettingsOption(title: Localization.Settings.CellTitle.vaccin_tracker, icon: UIImage(systemName: "globe")!, iconBackgroundColor: .systemBlue) {
                self.openURL(url: "https://covidtracker.fr/vaccintracker/")
            })
        ]))

        models.append(Section(title: Localization.Settings.SectionTitle.help, options: [
            .staticCell(model: SettingsOption(title: Localization.Settings.CellTitle.contact_us, icon: UIImage(systemName: "envelope")!, iconBackgroundColor: .systemYellow) {
                self.openURL(url: "https://covidtracker.fr/contact/")
            }),

            .staticCell(model: SettingsOption(title: Localization.Settings.CellTitle.bug_report, icon: UIImage(systemName: "square.and.arrow.up")!, iconBackgroundColor: .blue) {
                self.openURL(url: "https://covidtracker.fr/contact/")
            })

        ]))
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = models[section]
        return model.title
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]

        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsTableViewCell.identifier,
                for: indexPath
            ) as? SettingsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)

            return cell
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SettingsSwitchTableViewCell.identifier,
                for: indexPath
            ) as? SettingsSwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
    }

    func getUserInterfaceStyle() -> Bool {
        if traitCollection.userInterfaceStyle == .dark {
            return true
        } else {
            return false
        }
    }

    func openURL(url: String) {
        if let url = URL(string: url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true

            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }

    func configureLabel() {
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildString = "Version: \(appVersion ?? "") (\(build ?? ""))"
        versionLabel.textAlignment = .center
        versionLabel.text = buildString
        versionLabel.textColor = .gray
        versionLabel.layer.zPosition = 1

        #if DEBUG
        versionLabel.isHidden = false
        #else
        versionLabel.isHidden = true
        #endif

    }

}
