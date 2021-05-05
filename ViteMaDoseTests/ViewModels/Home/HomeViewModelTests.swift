//
//  HomeViewModelTests.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 24/04/2021.
//

import XCTest
import MapKit
@testable import ViteMaDose

class HomeViewModelTests: XCTestCase {
    private let locationSearchResults = [
        LocationSearchResult(name: "Amazing department", departmentCode: "01", nearDepartmentCodes: [], coordinates: nil),
        LocationSearchResult(name: "Amazing city", departmentCode: "02", nearDepartmentCodes: ["01"], coordinates: LocationSearchResult.Coordinates(latitude: 0.123, longitude: 0.456))
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

    func testLoadWithoutError() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedPercentage = (Double(123) * 100) / Double(456)
        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        let statsCells = try XCTUnwrap(delegateSpy.reloadTableView?.statsCells)

        // Heading cells
        assertHomeTitleCell(
            headingCells[0],
            expectedViewData: .init(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0.0)
        )
        assertHomeSearchBarCell(headingCells[1], expectedViewData: .init())

        // Stats cells
        assertHomeTitleCell(statsCells[0], expectedViewData: .init(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 20.0, bottomMargin: 5.0))
        assertHomeStatsCell(statsCells[1], expectedViewData: .init(.allCentres(456)))
        assertHomeStatsCell(statsCells[2], expectedViewData: .init(.allAvailabilities(789)))
        assertHomeStatsCell(statsCells[3], expectedViewData: .init(.centresWithAvailabilities(123)))
        assertHomeStatsCell(statsCells[4], expectedViewData: .init(.percentageAvailabilities(expectedPercentage)))
        assertHomeStatsCell(statsCells[5], expectedViewData: .init(.externalMap))

        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentFetchStatsError)
    }

    func testReloadWithoutError() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        XCTAssertEqual(delegateSpy.reloadTableView?.headingCells.count, 2)
        XCTAssertEqual(delegateSpy.reloadTableView?.statsCells.count, 6)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentFetchStatsError)

        // Reload with changes
        apiServiceMock.fetchStatsResult = .success([
            StatsKey.allDepartments.rawValue: StatsValue(disponibles: 0, total: 0, creneaux: 0)
        ])
        viewModel.load()

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        let statsCells = try XCTUnwrap(delegateSpy.reloadTableView?.statsCells)

        // Heading cells
        assertHomeTitleCell(
            headingCells[0],
            expectedViewData: .init(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0.0)
        )
        assertHomeSearchBarCell(headingCells[1], expectedViewData: .init())

        // Stats cells
        assertHomeTitleCell(statsCells[0], expectedViewData: .init(titleText: HomeTitleCell.lastStatsAttributedText, topMargin: 20.0, bottomMargin: 5.0))
        assertHomeStatsCell(statsCells[1], expectedViewData: .init(.allCentres(0)))
        assertHomeStatsCell(statsCells[2], expectedViewData: .init(.allAvailabilities(0)))
        assertHomeStatsCell(statsCells[3], expectedViewData: .init(.centresWithAvailabilities(0)))
        assertHomeStatsCell(statsCells[4], expectedViewData: .init(.percentageAvailabilities(nil)))
        assertHomeStatsCell(statsCells[5], expectedViewData: .init(.externalMap))

        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertNil(delegateSpy.presentFetchStatsError)
    }

    func testLoadWithStatsError() throws {
        let error = BaseAPIErrorMock.networkError
        apiServiceMock.fetchStatsResult = .failure(error)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedError = try XCTUnwrap(delegateSpy.presentFetchStatsError as? BaseAPIErrorMock)

        XCTAssertNil(delegateSpy.reloadTableView)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, true)
        XCTAssertEqual(expectedError, error)
    }

    func testReloadError() throws {
        let error = BaseAPIErrorMock.networkError
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        XCTAssertNotNil(delegateSpy.reloadTableView)
        XCTAssertNil(delegateSpy.presentFetchStatsError)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, true)

        apiServiceMock.fetchStatsResult = .failure(error)
        viewModel.load()

        let expectedReloadError = try XCTUnwrap(delegateSpy.presentFetchStatsError as? BaseAPIErrorMock)
        XCTAssertEqual(expectedReloadError, error)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isLoading, false)
        XCTAssertEqual(delegateSpy.updateLoadingState?.isEmpty, false)
    }

    func testLastSelectedDepartmentIsAdded() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)

        assertHomeTitleCell(headingCells[0], expectedViewData: .init(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0.0))
        assertHomeSearchBarCell(headingCells[1], expectedViewData: .init())

        let firstSearchResult = try XCTUnwrap(locationSearchResults.first)
        userDefaults.lastSearchResults = [firstSearchResult]
        viewModel.load()

        let expectedSearchResultViewData = HomeSearchResultCellViewData(
            titleText: Localization.Home.recent_search.format(userDefaults.lastSearchResults.count),
            name: firstSearchResult.name,
            code: firstSearchResult.departmentCode
        )

        let updatedHeadingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        assertHomeTitleCell(updatedHeadingCells[0], expectedViewData: .init(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0.0))
        assertHomeSearchBarCell(updatedHeadingCells[1], expectedViewData: .init())
        assertHomeSearchResultCell(updatedHeadingCells[2], expectedViewData: expectedSearchResultViewData)
    }

    func testExistingLastSelectedDepartmentIsAdded() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstSearchResult = try XCTUnwrap(locationSearchResults.first)
        userDefaults.lastSearchResults = [firstSearchResult]

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedSearchResultViewData = HomeSearchResultCellViewData(
            titleText: Localization.Home.recent_search.format(userDefaults.lastSearchResults.count),
            name: firstSearchResult.name,
            code: firstSearchResult.departmentCode
        )

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        assertHomeTitleCell(headingCells[0], expectedViewData: .init(titleText: HomeTitleCell.mainTitleAttributedText, bottomMargin: 0.0))
        assertHomeSearchBarCell(headingCells[1], expectedViewData: .init())
        assertHomeSearchResultCell(headingCells[2], expectedViewData: expectedSearchResultViewData)
    }

    func testDidSelectLastDepartmentPresentsList() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstSearchResult = try XCTUnwrap(locationSearchResults.first)
        userDefaults.lastSearchResults = [firstSearchResult]

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelectSavedSearchResult(withName: firstSearchResult.name)

        XCTAssertEqual(delegateSpy.presentVaccinationCentresLocationSearchResult, firstSearchResult)
    }

    func testDidSelectDepartmentPresentsList() throws {
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        let firstSearchResult = try XCTUnwrap(locationSearchResults.first)

        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelect(firstSearchResult)

        XCTAssertEqual(delegateSpy.presentVaccinationCentresLocationSearchResult, firstSearchResult)
    }

    private func assertHomeTitleCell(_ cell: HomeCell, expectedViewData: HomeTitleCellViewData) {
        guard case let .title(viewData) = cell else {
            XCTFail("Cell type should be title")
            return
        }

        XCTAssertEqual(viewData.titleText, expectedViewData.titleText)
        XCTAssertEqual(viewData.subTitleText, expectedViewData.subTitleText)
        XCTAssertEqual(viewData.topMargin, expectedViewData.topMargin)
        XCTAssertEqual(viewData.bottomMargin, expectedViewData.bottomMargin)
    }

    private func assertHomeSearchBarCell(_ cell: HomeCell, expectedViewData: HomeSearchBarCellViewData) {
        guard case let .searchBar(viewData) = cell else {
            XCTFail("Cell type should be searchBar")
            return
        }

        XCTAssertEqual(viewData.searchBarText, expectedViewData.searchBarText)
    }

    private func assertHomeStatsCell(_ cell: HomeCell, expectedViewData: HomeCellStatsViewData) {
        guard case let .stats(viewData) = cell else {
            XCTFail("Cell type should be stats")
            return
        }

        XCTAssertEqual(viewData.dataType, expectedViewData.dataType)
        XCTAssertEqual(viewData.title.string, expectedViewData.title.string)
        XCTAssertEqual(viewData.description, expectedViewData.description)
        XCTAssertEqual(viewData.icon, expectedViewData.icon)
        XCTAssertEqual(viewData.iconContainerColor, expectedViewData.iconContainerColor)
    }

    private func assertHomeSearchResultCell(_ cell: HomeCell, expectedViewData: HomeSearchResultCellViewData) {
        guard case let .searchResult(viewData) = cell else {
            XCTFail("Cell type should be searchResult")
            return
        }

        XCTAssertEqual(viewData.titleText, expectedViewData.titleText)
        XCTAssertEqual(viewData.name, expectedViewData.name)
        XCTAssertEqual(viewData.code, expectedViewData.code)
    }
}
