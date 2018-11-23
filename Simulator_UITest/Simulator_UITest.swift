//  Simulator_UITest.swift
//  Simulator_UITest

//  Description: Simulator UI Test (FOR SIMULATOR ONLY!)

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung, David Ling

//  Changes:
//  10/20/2018 - Added dummy XCTAssertFalse test for Travis CI
//  10/30/2018 - Added button testing

import XCTest

class Simulator_UITest: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Test Photo Mode (No Camera detected alert prompt)
    func testNoCameraAccess() {
        let app = XCUIApplication()
        app.buttons["Photo Mode Button"].tap()
        app.alerts["Error"].buttons["OK"].tap()
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode View
    func testGalleryModeLaunch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode Button"].tap()
        app.buttons["Back"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Firebase
    func testGalleryModeFirebase() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode Button"].tap()
        app.buttons["Firebase"].tap()
        app.buttons["Back"].tap()
        app.buttons["Back"].tap()
        XCTAssertFalse(false)
    }
    
    // Test Editor Mode View
    func testEditorModeLaunch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Editor Mode Button"].tap()
        app.buttons["Back"].tap()
        XCTAssertFalse(false)
    }
    
}
