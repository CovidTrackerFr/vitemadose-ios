//
//  HomeViewModelTests.swift
//  ViteMaDoseTests
//
//  Created by Victor Sarda on 24/04/2021.
//

import XCTest
@testable import ViteMaDose

class HomeViewModelTests: XCTestCase {

    private var counties = [
        County(codeDepartement: "1", nomDepartement: "Amazing County", codeRegion: 0, nomRegion: "Amazing Region"),
        County(codeDepartement: "2", nomDepartement: "Amazing County 2", codeRegion: 1, nomRegion: "Amazing Region 2")
    ]
    private var stats = [
        StatsKey.allCounties.rawValue: StatsValue(disponibles: 123, total: 456, creneaux: 789),
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
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)),
            .countySelection(HomeCountySelectionViewData())
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
        apiServiceMock.fetchDepartmentsResult = .success(counties)
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
            StatsKey.allCounties.rawValue: StatsValue(disponibles: 0, total: 0, creneaux: 0)
        ])
        viewModel.reloadStats()

        let expectedHeadingCells: [HomeCell] = [
            .title(HomeTitleCellViewData(titleText: HomeTitleCell.mainTitleAttributedText)),
            .countySelection(HomeCountySelectionViewData())
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

    func testLoadWithCountiesError() throws {
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

        apiServiceMock.fetchDepartmentsResult = .success(counties)
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

        apiServiceMock.fetchDepartmentsResult = .success(counties)
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

    func testLastSelectedCountyIsAdded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.mainTitleAttributedText)),
            .countySelection(.init())
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        XCTAssertEqual(headingCells, expectedHeadingCells)

        let firstCounty = try XCTUnwrap(counties.first)
        userDefaults.lastSelectedCountyCode = firstCounty.codeDepartement
        viewModel.load()

        let expectedUpdatedCells = expectedHeadingCells + [
            .county(.init(titleText: Localization.Home.recent_search, countyName: firstCounty.nomDepartement!, countyCode: firstCounty.codeDepartement!))
        ]

        XCTAssertEqual(delegateSpy.reloadTableView?.headingCells, expectedUpdatedCells)
    }

    func testExistingLastSelectedCountyIsAdded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstCounty = try XCTUnwrap(counties.first)
        userDefaults.lastSelectedCountyCode = firstCounty.codeDepartement

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()

        let expectedHeadingCells: [HomeCell] = [
            .title(.init(titleText: HomeTitleCell.mainTitleAttributedText)),
            .countySelection(.init()),
            .county(.init(
                titleText: Localization.Home.recent_search,
                countyName: firstCounty.nomDepartement ?? "",
                countyCode: firstCounty.codeDepartement ?? ""
            ))
        ]

        let headingCells = try XCTUnwrap(delegateSpy.reloadTableView?.headingCells)
        XCTAssertEqual(headingCells, expectedHeadingCells)
    }

    func testDidSelectLastCountyPresentsList() throws {
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let firstCounty = try XCTUnwrap(counties.first)
        userDefaults.lastSelectedCountyCode = firstCounty.codeDepartement

        let delegateSpy = HomeViewModelDelegateSpy()
        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelectLastCounty()

        XCTAssertEqual(delegateSpy.presentVaccinationCentresCounty, firstCounty)
    }

    func testDidSelectCountyPresentsList() throws {
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        let firstCounty = try XCTUnwrap(counties.first)

        viewModel.delegate = delegateSpy
        viewModel.load()
        viewModel.didSelect(firstCounty)

        XCTAssertEqual(delegateSpy.presentVaccinationCentresCounty, firstCounty)
    }

    func testLastSelectedCountyIsUpdatedIfNeeded() throws {
        apiServiceMock.fetchDepartmentsResult = .success(counties)
        apiServiceMock.fetchStatsResult = .success(stats)

        let delegateSpy = HomeViewModelDelegateSpy()
        let firstCounty = try XCTUnwrap(counties.first)
        let secondCounty = try XCTUnwrap(counties[safe: 1])

        viewModel.delegate = delegateSpy
        viewModel.load()

        viewModel.updateLastSelectedCountyIfNeeded(firstCounty.codeDepartement)
        XCTAssertEqual(viewModel.lastSelectedCountyCode, firstCounty.codeDepartement)

        viewModel.updateLastSelectedCountyIfNeeded(secondCounty.codeDepartement)
        XCTAssertEqual(viewModel.lastSelectedCountyCode, secondCounty.codeDepartement)
    }
}


