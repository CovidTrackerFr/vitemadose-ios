//
//  HomeViewModelTests.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 24/04/2021.
//

import XCTest
@testable import ViteMaDose

class HomeViewModelTests: XCTestCase {

    private var departments = [
        Department(codeDepartement: "1", nomDepartement: "Amazing department", codeRegion: 0, nomRegion: "Amazing Region"),
        Department(codeDepartement: "2", nomDepartement: "Amazing department 2", codeRegion: 1, nomRegion: "Amazing Region 2")
    ]
    private var stats = [
        StatsKey.allDepartments.rawValue: StatsValue(disponibles: 123, total: 456, creneaux: 789),
        "Another Key": StatsValue(disponibles: 0, total: 0, creneaux: 0),
    ]

    private var apiServiceMock: BaseAPIServiceMock!
    private var userDefaults: UserDefaults!

    private lazy var viewModel = HomeViewModel(
        apiService: apiServiceMock,
        userDefaults: userDefaults
    )

    override func setUp() {
        super.setUp()
        apiServiceMock = BaseAPIServiceMock()
        userDefaults = .makeClearedInstance()
    }

    func testLoadWithNoError() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)),
            .departmentSelection(HomeDepartmentSelectionViewData())
        ]

        let expectedPercentage = (Double(123) * 100) / Double(456)

        let expectedStatsCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 15.0, bottomMargin: 5.0)),
            .stats(.init(.allCentres(456))),
            .stats(.init(.allAvailabilities(789))),
            .stats(.init(.centresWithAvailabilities(123))),
            .stats(.init(.percentageAvailabilities(expectedPercentage))),
            .stats(.init(.externalMap))
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        let statsCells = try XCTUnwrap(delegateSpy.reloadTableView?.statsCells)

        XCTAssertEqual(headingCells, expectedHeadingCells)
        XCTAssertEqual(statsCells, expectedStatsCells)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentInitialLoadError)
    }

    func testReloadWithoutError() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        XCTAssertEqual(delegateSpy.reloadTableView?.headingCells.count, 2)
        XCTAssertEqual(delegateSpy.reloadTableView?.statsCells.count, 6)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentInitialLoadError)

        // Reload with changes

        apiServiceMock.fetchStatsResult = .success([
            StatsKey.allDepartments.rawValue: StatsValue(disponibles: 0, total: 0, creneaux: 0)
        ])
        viewModel.reloadStats()

        let expectedHeadingCells: [HomeCell] = [
            .title(HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)),
            .departmentSelection(HomeDepartmentSelectionViewData())
        ]
        let expectedStatsCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 15.0, bottomMargin: 5.0)),
            .stats(.init(.allCentres(0))),
            .stats(.init(.allAvailabilities(0))),
            .stats(.init(.centresWithAvailabilities(0))),
            .stats(.init(.percentageAvailabilities(nil))),
            .stats(.init(.externalMap))
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        let statsCells = try XCTUnwrap(delegateSpy.reloadTableView?.statsCells)

        XCTAssertEqual(headingCells, expectedHeadingCells)
        XCTAssertEqual(statsCells, expectedStatsCells)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentFetchStatsError)
    }

    func testLoadWithDepartmentsError() throws {
        let error = BaseAPIErrorMock.networkError

        apiServiceMock.fetchDepartmentsResult = .failure(error)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedError = try XCTUnwrap(delegateSpy.presentInitialLoadError as? BaseAPIErrorMock)

        XCTAssertNil(delegateSpy.reloadTableView)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, true)
        XCTAssertEqual(expectedError, error)
    }

    func testLoadWithStatsError() throws {
        let error = BaseAPIErrorMock.networkError

        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .failure(error)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedError = try XCTUnwrap(delegateSpy.presentInitialLoadError as? BaseAPIErrorMock)

        XCTAssertNil(delegateSpy.reloadTableView)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, true)
        XCTAssertEqual(expectedError, error)
    }

    func testReloadError() throws {
        let error = BaseAPIErrorMock.networkError

        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        XCTAssertNotNil(delegateSpy.reloadTableView)
        XCTAssertNil(delegateSpy.presentInitialLoadError)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, false)

        apiServiceMock.fetchStatsResult = .failure(error)
        viewModel.reloadStats()

        let expectedReloadError = try XCTUnwrap(delegateSpy.presentFetchStatsError as? BaseAPIErrorMock)

        XCTAssertNil(delegateSpy.presentInitialLoadError)
        XCTAssertEqual(expectedReloadError, error)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, false)
    }

    func testLastSelectedDepartmentIsAdded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.mainTitleAttributedText)),
            .departmentSelection(.init())
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        XCTAssertEqual(headingCells, expectedHeadingCells)

        let firstDepartment = try XCTUnwrap(departments.first)
        userDefaults.lastSelectedDepartmentCode = firstDepartment.codeDepartement
        viewModel.load()

        let expectedUpdatedCells = expectedHeadingCells + [
            .department(.init(titleText: Localization.Home.recent_search, name: firstDepartment.nomDepartement!, code: firstDepartment.codeDepartement!))
        ]

        XCTAssertEqual(delegateSpy.reloadTableView?.headingCells, expectedUpdatedCells)
    }

    func testExistingLastSelectedDepartmentIsAdded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstDepartment = try XCTUnwrap(departments.first)
        userDefaults.lastSelectedDepartmentCode = firstDepartment.codeDepartement

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.mainTitleAttributedText)),
            .departmentSelection(.init()),
            .department(.init(
                titleText: Localization.Home.recent_search,
                name: firstDepartment.nomDepartement ?? "",
                code: firstDepartment.codeDepartement ?? ""
            ))
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        XCTAssertEqual(headingCells, expectedHeadingCells)
    }

    func testDidSelectLastDepartmentPresentsList() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstDepartment = try XCTUnwrap(departments.first)
        userDefaults.lastSelectedDepartmentCode = firstDepartment.codeDepartement

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelectLastDepartment()

        XCTAssertEqual(delegateSpy.presentVaccinationCentresDepartment, firstDepartment)
    }

    func testDidSelectDepartmentPresentsList() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        let firstDepartment = try XCTUnwrap(departments.first)

        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelect(firstDepartment)

        XCTAssertEqual(delegateSpy.presentVaccinationCentresDepartment, firstDepartment)
    }

    func testLastSelectedDepartmentIsUpdatedIfNeeded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(departments)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        let firstDepartment = try XCTUnwrap(departments.first)
        let secondDepartment = try XCTUnwrap(departments[safe: 1])

        viewModel.delegate = delegateSpy
        viewModel.load()

        viewModel.updateLastSelectedDepartmentIfNeeded(firstDepartment.codeDepartement)
        XCTAssertEqual(viewModel.lastSelectedDepartmentCode, firstDepartment.codeDepartement)

        viewModel.updateLastSelectedDepartmentIfNeeded(secondDepartment.codeDepartement)
        XCTAssertEqual(viewModel.lastSelectedDepartmentCode, secondDepartment.codeDepartement)
    }
}
