//
//  VaccinationCentresTitleCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

protocol CentresSortingCellViewDataProvider: HomeTitleCellViewDataProvider {
    var mode: CentresSortOrder { get }
    var showSelector: Bool { get }
}

struct CentresSortingCellViewData: CentresSortingCellViewDataProvider, Hashable {
    let titleText: NSMutableAttributedString
    let subTitleText: NSMutableAttributedString?
    let topMargin: CGFloat
    let bottomMargin: CGFloat
    let mode: CentresSortOrder
    let showSelector: Bool

    init(
        titleText: NSMutableAttributedString,
        subTitleText: NSMutableAttributedString? = nil,
        topMargin: CGFloat = 10,
        bottomMargin: CGFloat = 10,
        mode: CentresSortOrder = .auPlusProche,
        showSelector: Bool
    ) {
        self.titleText = titleText
        self.subTitleText = subTitleText
        self.topMargin = topMargin
        self.bottomMargin = bottomMargin
        self.mode = mode
        self.showSelector = showSelector
    }
}

class CentresTitleCell: HomeTitleCell {
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    weak var delegate: CentresListViewControllerDelegate?

    private enum Constant {
        static let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        static let titleColor: UIColor = .label

        static let highlightedDosesTextColor: UIColor = .systemGreen
        static let highlightedCountyTextColor: UIColor = .mandy
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        segmentedControl.setBackgroundImage(UIImage(color: .white, size: CGSize(width: 1, height: 16)), for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(UIImage(color: .royalBlue, size: CGSize(width: 1, height: 16)), for: .selected, barMetrics: .default)

        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        segmentedControl.setTitle(Localization.Locations.closest, forSegmentAt: 0)
        segmentedControl.setTitle(Localization.Locations.quickest, forSegmentAt: 1)
    }

    override func configure(with viewData: HomeTitleCellViewDataProvider) {
        super.configure(with: viewData)

        if let viewData = viewData as? CentresSortingCellViewData {
            segmentedControl.selectedSegmentIndex = viewData.mode.rawValue
            segmentedControl.isHidden = !viewData.showSelector
        } else {
            segmentedControl.isHidden = true
        }
    }

    @IBAction func sortingSegmentChanged(_ sender: Any) {
        delegate?.didChange(mode: segmentedControl.selectedSegmentIndex == 0 ? .auPlusProche : .auPlusVite)
    }
}

extension CentresTitleCell {

    static func mainTitleAttributedText(
        withAppointmentsCount appointmentsCount: Int,
        andSearchResult searchResult: LocationSearchResult
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]

        let searchResultName = searchResult.name
        guard appointmentsCount > 0 else {
            let title = NSMutableAttributedString(
                string: Localization.Locations.no_results.format(searchResultName),
                attributes: attributes
            )
            title.setColorForText(textForAttribute: searchResultName, withColor: .mandy)
            return title
        }

        let isDepartment = searchResult.coordinates == nil

        let appointmentsCountString = Localization.Locations.appointments.format(appointmentsCount)
        let titleString: String
        if isDepartment {
            titleString  = Localization.Locations.MainTitle.title_department.format(appointmentsCount, searchResultName)
        } else {
            titleString  = Localization.Locations.MainTitle.title_city.format(appointmentsCount, searchResultName)
        }

        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: appointmentsCountString, withColor: .mandy)
        title.setColorForText(textForAttribute: searchResultName, withColor: .royalBlue)

        return title
    }

    static var centresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]
        return NSMutableAttributedString(string: Localization.Locations.list_title, attributes: attributes)
    }

}
