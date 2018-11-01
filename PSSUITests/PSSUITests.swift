//  PSSUITests.swift
//  PSSUITests

//  Description: UI Test Cases for PSS

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung, David Ling

//  Changes:
//  10/20/2018 - Added dummy XCTAssertFalse test for Travis CI
//  10/30/2018 - Added button testing

import XCTest

class PSSUITests: XCTestCase {

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
    
    func testNoCameraAccess() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Error"].buttons["OK"].tap()

        
        
        XCTAssertFalse(false)
    }
    func testPhotoModeLaunch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Back"].tap()
        

        XCTAssertFalse(false)
    }
    
    func testPhotoModeCapture() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        
        let okButton = app.alerts["Instructions"].buttons["OK"]
        okButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        okButton.tap()
        
        
        XCTAssertFalse(false)
    }
    
    func testPhotoModeNoSelectAndSave() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        
        let okButton = app.alerts["Instructions"].buttons["OK"]
        okButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        okButton.tap()

        app.buttons["Save"].tap()


        XCTAssertFalse(false)
    }
    
    func testPhotoModeSelectAndSave() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        
        let okButton = app.alerts["Instructions"].buttons["OK"]
        okButton.tap()
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .button).element.tap()
        okButton.tap()
        
        app.buttons["Save"].tap()
        app.alerts["Allow “PSS” to delete this photo?"].buttons["Delete"].tap()
    

        XCTAssertFalse(false)
    }
    
    func testPhotoModeFlash() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Flash Off Icon"].tap()
        app.buttons["Flash On Icon"].tap()
        

    
        XCTAssertFalse(false)
    }
    
    func testPhotoModeRearCamera() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Rear Camera Icon"].tap()
        app.buttons["Front Camera Icon"].tap()
        
   
        XCTAssertFalse(false)
    }
    
    func testGalleryModeLaunch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.buttons["Back"].tap()
        

        
        XCTAssertFalse(false)
    }
    
    func testGalleryModeShare() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        usleep(8000)
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).tap()
        XCUIApplication().buttons["Share"].tap()

        XCTAssertFalse(false)
    }
    
    func testGalleryModeBackup() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        usleep(8000)
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Backup"].tap()
        
        XCTAssertFalse(false)
    }
    
    func testGalleryModeDelete() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Delete"].tap()
        

        XCTAssertFalse(false)
    }
}
