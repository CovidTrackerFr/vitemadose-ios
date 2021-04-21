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

        static let titleFirstPartText = "Nous avons trouvé"
        static let titleSecondPartText = "doses"
        static let titleThirdText = "pour le département"
        static let titleNoDoseText = "Nous n'avons pas trouvé de doses pour le département"
        static let subtitleText = "Liste des centres"
        static let auPlusProcheText = "Au plus proche"
        static let auPlusViteText = "Au plus vite"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        segmentedControl.setBackgroundImage(UIImage(color: .white, size: CGSize(width: 1, height: 16)), for: .normal, barMetrics: .default)
        segmentedControl.setBackgroundImage(UIImage(color: .royalBlue, size: CGSize(width: 1, height: 16)), for: .selected, barMetrics: .default)
        
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        
        segmentedControl.setTitle(Constant.auPlusProcheText, forSegmentAt: 0)
        segmentedControl.setTitle(Constant.auPlusViteText, forSegmentAt: 1)
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
        withDoses dosesCount: Int,
        andCountyName countyName: String
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont,
        ]

        guard dosesCount > 0 else {
            let title = NSMutableAttributedString(
                string:"\(Constant.titleNoDoseText) \(countyName)",
                attributes: attributes
            )
            title.setColorForText(textForAttribute: countyName, withColor: .mandy)
            return title
        }

        let dosesCountString = "\(String(dosesCount)) \(Constant.titleSecondPartText)"
        let titleString = "\(Constant.titleFirstPartText) \(dosesCountString) \(Constant.titleThirdText) \(countyName)"
        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: dosesCountString, withColor: .mandy)
        title.setColorForText(textForAttribute: countyName, withColor: .royalBlue)

        return title
    }

    static var centresListTitle: NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont,
        ]
        return NSMutableAttributedString(string: Constant.subtitleText, attributes: attributes)
    }

}
