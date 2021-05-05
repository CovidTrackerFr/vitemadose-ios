//
//  VaccinationCentresTitleCell.swift
//  ViteMaDose
//
//  Created by Victor Sarda on 18/04/2021.
//

import UIKit

class CentresTitleCell: HomeTitleCell {
    private enum Constant {
        static let titleFont: UIFont = .rounded(ofSize: 26, weight: .bold)
        static let titleColor: UIColor = .label
    }
}

extension CentresTitleCell {

    static func mainTitleAttributedText(
        withAppointmentsCount appointmentsCount: Int,
        andDepartmentName departmentName: String
    ) -> NSMutableAttributedString {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constant.titleColor,
            NSAttributedString.Key.font: Constant.titleFont
        ]

        guard appointmentsCount > 0 else {
            let title = NSMutableAttributedString(
                string: Localization.Locations.no_results.format(departmentName),
                attributes: attributes
            )
            title.setColorForText(textForAttribute: departmentName, withColor: .mandy)
            return title
        }

        let appointmentsCountString = Localization.Locations.appointments.format(appointmentsCount)
        let titleString = Localization.Locations.MainTitle.title.format(appointmentsCount, departmentName)
        let title = NSMutableAttributedString(
            string: titleString,
            attributes: attributes
        )
        title.setColorForText(textForAttribute: appointmentsCountString, withColor: .mandy)
        title.setColorForText(textForAttribute: departmentName, withColor: .royalBlue)

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
