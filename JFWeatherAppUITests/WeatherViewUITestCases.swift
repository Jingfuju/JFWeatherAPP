//
//  WeatherViewUITestCases.swift
//  JFWeatherAppUITests
//
//  Created by Jingfu Ju on 2/22/23.
//

@testable import JFWeatherApp
import XCTest


final class WeatherAppUITest: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.activate()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
    
    func test_tapRightBarButtonItem_shouldBeAlbeToTap() {
        XCTContext.runActivity(
            named: "Tap the history button, search history UI menu should show"
        ) { _ in
            let rightNavigationBarButton = app.navigationBars.buttons["HistoryButton"]
            XCTAssert(rightNavigationBarButton.exists)
            rightNavigationBarButton.tap()
            let isMenuAvailable = app
                .descendants(matching: .any)
                .element(matching: .any, identifier: "ClearHistory")
                .exists
            XCTAssert(isMenuAvailable)
        }
    }

    

    func test_tableView_shouldExist() {
        XCTContext.runActivity(
            named: "tabe view should exist"
        ) { _ in
            let table = app.tables.element
            XCTAssertTrue(table.exists)
        }
    }
}
