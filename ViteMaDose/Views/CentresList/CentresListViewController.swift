//
//  CentresListViewController.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 09/04/2021.
//

import UIKit
import SafariServices
import MapKit
import Haptica

protocol CentresListViewControllerDelegate: class {
    func didChange(mode: CentresSortOrder)
}

class CentresListViewController: UIViewController, Storyboarded {

    @IBOutlet private var tableView: UITableView!
    var viewModel: CentresListViewModel!

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

    private lazy var dataSource = makeDataSource()

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

        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension

        tableView.refreshControl = refreshControl
        tableView.backgroundView = activityIndicator
        tableView.contentInset.bottom = 10

        tableView.register(cellType: CentresTitleCell.self)
        tableView.register(cellType: CentreCell.self)
        tableView.register(cellType: CentresStatsCell.self)
    }

}

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
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.text = text
        label.sizeToFit()

        tableView.tableFooterView = label
    }

    func updateLoadingState(isLoading: Bool, isEmpty: Bool) {
        tableView.tableFooterView?.isHidden = isLoading

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

}

extension CentresListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: Show details
    }

}

// MARK: - DataSource

extension CentresListViewController {

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
        case let .sorting(cellViewData):
            let cell = tableView.dequeueReusableCell(with: CentresTitleCell.self, for: indexPath)
            cell.configure(with: cellViewData)
            cell.delegate = self
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
        }
    }

    private func configureHandlers(for cell: CentreCell, at indexPath: IndexPath) {
        // Address button tap
        cell.addressTapHandler = { [weak self] in
            guard let centreInfo = self?.viewModel.centreLocation(at: indexPath) else {
                return
            }
            let location = CLLocationCoordinate2D(latitude: centreInfo.lat, longitude: centreInfo.long)
            let placemark =  MKPlacemark(coordinate: location)
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
    }

    private func presentOpenMapAlert(
        sourceView: UIView,
        address: String?,
        mapItem: MKMapItem
    ) {
        let actionSheet = UIAlertController(
            title: mapItem.name,
            message: address,
            preferredStyle: .actionSheet
        )

        let openAction = UIAlertAction(title: "Ouvrir l'itinéraire", style: .default) { _ in
            MKMapItem.openMaps(
                with: [mapItem],
                launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
                ]
            )
        }

        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)

        actionSheet.addAction(openAction)
        actionSheet.addAction(cancelAction)
        actionSheet.preferredAction = openAction
        actionSheet.popoverPresentationController?.sourceView = sourceView

        present(actionSheet, animated: true)
    }
}

extension CentresListViewController: UIGestureRecognizerDelegate {

    /// Enable swipe to go back
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

}

extension CentresListViewController: CentresListViewControllerDelegate {

    func didChange(mode: CentresSortOrder) {
        viewModel.sort = mode
        viewModel.sort(animated: true)
    }

}
