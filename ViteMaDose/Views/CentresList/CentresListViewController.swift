// Software Name: vitemadose-ios
// SPDX-FileCopyrightText: Copyright (c) 2021 CovidTracker.fr
// SPDX-License-Identifier: GNU General Public License v3.0 or later
//
// This software is distributed under the GPL-3.0-or-later license.
//

import UIKit
import SafariServices
import MapKit
import Haptica

// MARK: - Centres List View Controller

class CentresListViewController: UIViewController, Storyboarded {
    @IBOutlet private var tableView: UITableView!

    var viewModel: CentresListViewModelProvider!
    private typealias Snapshot = NSDiffableDataSourceSnapshot<CentresListSection, CentresListCell>

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private let footerView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var dataSource = makeDataSource()

    // MARK: View Did

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            preconditionFailure("VaccinationCentresViewController should have a ViewModel!")
        }

        configureTableView()
        configureNavigationBar()

        view.backgroundColor = .athensGray
        viewModel.delegate = self
        viewModel.load(animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppAnalytics.logScreen(.searchResults, screenClass: Self.className)
    }

    @objc private func didPullToRefresh() {
        viewModel.load(animated: true)
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: Open Actions

    private func openBookingUrl(_ url: URL?) {
        guard let url = url else { return }
        let config = SFSafariViewController.Configuration()
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        Haptic.impact(.light).generate()
        present(safariViewController, animated: true)
    }

    private func openPhoneNumberUrl(_ url: URL?) {
        guard
            let url = url,
            UIApplication.shared.canOpenURL(url)
        else {
            return
        }

        UIApplication.shared.open(url)
    }

    // MARK: Configurations

    private func configureNavigationBar() {
        let backButtonImageConfiguration = UIImage.SymbolConfiguration.init(
            pointSize: 24,
            weight: .semibold,
            scale: .medium
        )
        let backButtonImage = UIImage(
            systemName: "arrow.left",
            withConfiguration: backButtonImageConfiguration
        )?.withTintColor(.label, renderingMode: .alwaysOriginal)

        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.accessibilityLabel = Localization.A11y.VoiceOver.Navigation.back_button

        let backBarButtonItem = UIBarButtonItem(customView: backButton)

        navigationItem.setLeftBarButton(backBarButtonItem, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource

        tableView.backgroundColor = .athensGray
        tableView.contentInset.top = -10

        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension

        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator
        tableView.contentInset.bottom = 10
        tableView.tableFooterView = footerView

        tableView.register(cellType: CentresTitleCell.self)
        tableView.register(cellType: CentreActionCell.self)
        tableView.register(cellType: CentreCell.self)
        tableView.register(cellType: CentresStatsCell.self)
        tableView.register(cellType: CentresSortOptionsCell.self)
        tableView.register(cellType: CentreDataDisclaimerCell.self)
    }

}

// MARK: - Centres List View Model Delegate

extension CentresListViewController: CentresListViewModelDelegate {

    func reloadTableView(
        with headingCells: [CentresListCell],
        andCentresCells centresCells: [CentresListCell],
        animated: Bool
    ) {
        var snapshot = Snapshot()
        snapshot.appendSections(CentresListSection.allCases)
        snapshot.appendItems(headingCells, toSection: .heading)
        snapshot.appendItems(centresCells, toSection: .centres)

        dataSource.defaultRowAnimation = .fade
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func reloadTableViewFooter(with text: String?) {
        footerView.text = text
        footerView.sizeToFit()
        tableView.tableFooterView = footerView
    }

    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        if !isLoading {
            activityIndicator.stopAnimating()
            refreshControl.endRefreshing()
        } else {
            guard isEmpty else { return }
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }

    func presentLoadError(_ error: Error) {
        presentRetryableAndCancellableError(
            error: error,
            retryHandler: { [unowned self] _ in
                self.viewModel.load(animated: false)
            },
            cancelHandler: { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            },
            completionHandler: nil
        )
    }

    func dismissViewController() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: - UI Table View Delegate

extension CentresListViewController: UITableViewDelegate {

    // MARK: Dequeue and Configure

    private func makeDataSource() -> UITableViewDiffableDataSource<CentresListSection, CentresListCell> {
        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] _, indexPath, vaccinationCentreCell in
                return self?.dequeueAndConfigure(cell: vaccinationCentreCell, at: indexPath)
            }
        )
    }

    private func dequeueAndConfigure(cell: CentresListCell, at indexPath: IndexPath) -> UITableViewCell {
        switch cell {
        case let .title(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentresTitleCell.self, for: indexPath)
            cell.configure(with: cellViewData)
            return cell
        case let .titleWithButton(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentreActionCell.self, for: indexPath)
            configureHandlers(for: cell)
            cell.configure(with: cellViewData)
            return cell
        case let .stats(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentresStatsCell.self, for: indexPath)
            cell.configure(with: cellViewData)
            return cell
        case let .centre(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentreCell.self, for: indexPath)
            configureHandlers(for: cell, at: indexPath)
            cell.configure(with: cellViewData)
            return cell
        case let .sort(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentresSortOptionsCell.self, for: indexPath)
            cell.sortSegmentedControlHandler = { [weak self] option in
                Haptic.impact(.light).generate()
                self?.viewModel.sortList(by: CentresListSortOption(option))
            }
            cell.configure(with: cellViewData)
            return cell
        case let .disclaimer(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentreDataDisclaimerCell.self, for: indexPath)
            cell.configure(with: cellViewData)
            return cell
        }
    }

    // MARK: Configuration for CentreCell

    private func configureHandlers(for cell: CentreCell, at indexPath: IndexPath) {
        // Address button tap
        cell.addressTapHandler = { [weak self] in
            guard let centreInfo = self?.viewModel.centreLocation(at: indexPath) else {
                return
            }
            let placemark =  MKPlacemark(coordinate: centreInfo.location.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = centreInfo.name

            self?.presentOpenMapAlert(
                sourceView: cell.addressNameContainer,
                address: centreInfo.address,
                mapItem: mapItem
            )
        }
        // Phone number tap
        cell.phoneNumberTapHandler = { [weak self] in
            let phoneUrl = self?.viewModel.phoneNumberLink(at: indexPath)
            self?.openPhoneNumberUrl(phoneUrl)
        }
        // Booking button tap
        cell.bookingButtonTapHandler = { [weak self] in
            let bookingURL = self?.viewModel.bookingLink(at: indexPath)
            self?.openBookingUrl(bookingURL)
        }
        // Follow/Unfollow button tap
        cell.followButtonTapHandler = { [weak self] in
            guard let isFollowing = self?.viewModel.isCentreFollowed(at: indexPath) else { return }
            if isFollowing {
                self?.presentUnfollowCentreBottomSheet(forCell: cell, atIndexPath: indexPath)
            } else {
                self?.presentFollowCentreBottomSheet(forCell: cell, atIndexPath: indexPath)
            }
        }
    }

    private func presentOpenMapAlert(sourceView: UIView, address: String?, mapItem: MKMapItem) {
        let actionSheet = UIAlertController(
            title: mapItem.name,
            message: address,
            preferredStyle: .actionSheet
        )

        let openAction = UIAlertAction(title: Localization.Location.open_route, style: .default) { _ in
            MKMapItem.openMaps(
                with: [mapItem],
                launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
                ]
            )
        }

        let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel, handler: nil)

        actionSheet.addAction(openAction)
        actionSheet.addAction(cancelAction)
        actionSheet.preferredAction = openAction
        actionSheet.popoverPresentationController?.sourceView = sourceView

        present(actionSheet, animated: true)
    }

    private func presentFollowCentreBottomSheet(forCell cell: CentreCell, atIndexPath indexPath: IndexPath) {
        let bottomSheet = UIAlertController(
            title: Localization.Location.start_following_title,
            message: Localization.Location.start_following_message,
            preferredStyle: .actionSheet
        )

        let allNotificationsAction = UIAlertAction(title: "Toutes les notifications", style: .default) { [weak self] _ in
            self?.viewModel.requestNotificationsAuthorizationIfNeeded {
                self?.viewModel.followCentre(at: indexPath, notificationsType: .all)
            }
        }

        let chronoDosesNotificationsAction = UIAlertAction(title: "Chronodoses uniquement", style: .default) { [weak self] _ in
            self?.viewModel.requestNotificationsAuthorizationIfNeeded {
                self?.viewModel.followCentre(at: indexPath, notificationsType: .chronodoses)
            }
        }

        let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel)

        bottomSheet.addAction(allNotificationsAction)
        bottomSheet.addAction(chronoDosesNotificationsAction)
        bottomSheet.addAction(cancelAction)
        bottomSheet.popoverPresentationController?.sourceView = cell.followCentreButton

        present(bottomSheet, animated: true)
    }

    private func presentUnfollowCentreBottomSheet(forCell cell: CentreCell, atIndexPath indexPath: IndexPath) {
        let bottomSheet = UIAlertController(
            title: Localization.Location.stop_following_title,
            message: Localization.Location.stop_following_message,
            preferredStyle: .actionSheet
        )

        let unfollowAction = UIAlertAction(title: Localization.Location.stop_following_button, style: .destructive) { [weak self] _ in
            self?.viewModel.unfollowCentre(at: indexPath)
        }

        let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel)

        bottomSheet.addAction(unfollowAction)
        bottomSheet.addAction(cancelAction)
        bottomSheet.popoverPresentationController?.sourceView = cell.followCentreButton

        self.present(bottomSheet, animated: true)
    }

    // MARK: Configuration for CentreActionCell

    /// For the given `cell`, defines its `actionButtonTapHandler` so as to preent a bottom sheet with filtering actions.
    /// - Parameter cell: The cell which will have the callback
    private func configureHandlers(for cell: CentreActionCell) {
        cell.actionButtonTapHandler = { [weak self] in
            self?.presentFilterCentresBottomSheet(from: cell)
        }
    }

    /// Presents an action sheet with filtering actions for the given cell
    /// - Parameter cell: The  `CentreActionCell` to use ffor the action button
    // swiftlint:disable function_body_length
    private func presentFilterCentresBottomSheet(from cell: CentreActionCell) {
        let bottomSheet = UIAlertController(
            title: Localization.Locations.Filtering.title,
            message: Localization.Locations.Filtering.messagge,
            preferredStyle: .actionSheet
        )

        // Actions about doses
        let kidsFirstDoseAction = UIAlertAction(title: Localization.Locations.Filtering.action_kids_doses, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .kidsFirstDoses)
        }
        kidsFirstDoseAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_kids_doses
        let allDosesAction = UIAlertAction(title: Localization.Locations.Filtering.action_all_doses, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .allDoses)
        }
        allDosesAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_all_doses

        // Actions about vaccin types
        let vaccineTypeModernaAction = UIAlertAction(title: Localization.Locations.Filtering.vaccine_type_moderna, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .vaccineTypeModerna)
        }
        vaccineTypeModernaAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_moderna
        let vaccineTypePfizerAction = UIAlertAction(title: Localization.Locations.Filtering.vaccine_type_pfizerbiontech, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .vaccineTypePfizer)
        }
        vaccineTypePfizerAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_pfizer
        let vaccineTypeARNmAction = UIAlertAction(title: Localization.Locations.Filtering.vaccine_type_arnm, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .vaccineTypeARNm)
        }
        vaccineTypeARNmAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_arnm
        let vaccineTypeJanssenAction = UIAlertAction(title: Localization.Locations.Filtering.vaccine_type_janssen, style: .default) { [weak self] _ in
            self?.viewModel.filterList(by: .vaccineTypeJanssen)
        }
        vaccineTypeJanssenAction.accessibilityLabel = Localization.A11y.VoiceOver.Locations.filtering_action_vaccine_type_janssen

        let cancelAction = UIAlertAction(title: Localization.Error.Generic.cancel_button, style: .cancel)

        // Add checkmark if previously selected
        switch viewModel.filterOption {
        case .allDoses:
            allDosesAction.setValue(true, forKey: "checked")
        case .kidsFirstDoses:
            kidsFirstDoseAction.setValue(true, forKey: "checked")
        case .vaccineTypeModerna:
            vaccineTypeModernaAction.setValue(true, forKey: "checked")
        case .vaccineTypePfizer:
            vaccineTypePfizerAction.setValue(true, forKey: "checked")
        case .vaccineTypeARNm:
            vaccineTypeARNmAction.setValue(true, forKey: "checked")
        case .vaccineTypeJanssen:
            vaccineTypeJanssenAction.setValue(true, forKey: "checked")
        }

        // Bottom sheet definition
        bottomSheet.addAction(vaccineTypeARNmAction)
        bottomSheet.addAction(vaccineTypeJanssenAction)
        bottomSheet.addAction(vaccineTypePfizerAction)
        bottomSheet.addAction(vaccineTypeModernaAction)
        bottomSheet.addAction(kidsFirstDoseAction)
        bottomSheet.addAction(allDosesAction)
        bottomSheet.addAction(cancelAction)
        bottomSheet.popoverPresentationController?.sourceView = cell.actionButton

        present(bottomSheet, animated: true)
    }
}

// MARK: - UI Gesture Recognizer Delegate

extension CentresListViewController: UIGestureRecognizerDelegate {
    /// Enable swipe to go back
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}
