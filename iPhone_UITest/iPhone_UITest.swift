//  iPhone_UITest.swift
//  iPhone_UITest

//  Description: iPhone UITest (for testing on Physical iPhone ONLY! Testing on Simulator will lead to failed tests due to the lack of hardware support (camera) and not containing any stock photos to test Gallery Mode)

//  CMPT 275 Group 3 - SavePark
//  Fall 2018

//  File Created By: Curtis Cheung
//  File Modified By: Curtis Cheung, David Ling

//  Changes:
//  11/02/2018 - David: Added Test Cases

import XCTest

class iPhone_UITest: XCTestCase {
    
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
    
    // Test Photo Mode view Instruction Prompt and back button
    func testPhotoModeLaunch() {
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Back"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Photo Mode Shutter button functionality
    func testPhotoModeCapture() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        
        let okButton = app.alerts["Instructions"].buttons["OK"]
        okButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        okButton.tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Photo Mode process (Select Photo Mode, Capture Picture, Select Save)
    func testPhotoModeNoSelectAndSave() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        
        let okButton = app.alerts["Instructions"].buttons["OK"]
        okButton.tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        okButton.tap()
        app.buttons["Save"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Flash Mode toggle button in Photo Mode
    func testPhotoModeFlash() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Flash Off Icon"].tap()
        app.buttons["Flash On Icon"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Camera Selection toggle button in Photo Mode
    func testPhotoModeRearCamera() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["Rear Camera Icon"].tap()
        app.buttons["Front Camera Icon"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test HVAA Selection toggle button in Photo Mode
    func testPhotoModeHVAA() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["HVAA OFF"].tap()
        app.buttons["HVAA ON"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test HVAA feature to produce error in Photo Mode
    func testPhotoModeHVAAError() {
        
        let app = XCUIApplication()
        app.buttons["Photo Mode"].tap()
        app.alerts["Instructions"].buttons["OK"].tap()
        app.buttons["HVAA OFF"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .button).element.tap()
        app.alerts["Error"].buttons["OK"].tap()
   
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode View
    func testGalleryModeLaunch() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.buttons["Back"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Share button functionality
    func testGalleryModeShare() {
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        usleep(8000)
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 0).tap()
        XCUIApplication().buttons["Share"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Backup button functionality
    func testGalleryModeBackup() {
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        usleep(8000)
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Backup"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Delete button functionality
    func testGalleryModeDelete() {
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Delete"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Firebase button functionality
    func testGalleryModeFirebase() {
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.buttons["Firebase"].tap()
        sleep(17) // retrieving wait time
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Back"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Gallery Mode Firebase share button functionality
    func testGalleryModeFirebaseShare() {
        
        let app = XCUIApplication()
        app.buttons["Gallery Mode"].tap()
        app.buttons["Firebase"].tap()
        sleep(17) // retrieving wait time
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        app.buttons["Share"].tap()
        
        
        XCTAssertFalse(false)
    }
    
    // Test Editor Mode View
    func testEditorModeLaunch() {
        
        let app = XCUIApplication()
        app.buttons["Editor Mode"].tap()
        app.buttons["Back"].tap()
        
        XCTAssertFalse(false)
    }
    
    // Test Editor Mode Save Photo
    func testEditorModeSavePhoto() {
        
        let app = XCUIApplication()
        app.buttons["Editor Mode"].tap()
        usleep(8000)
        app.collectionViews.children(matching: .cell).element(boundBy: 0).tap()
        XCUIApplication().buttons["Save photo"].tap()
        
        XCTAssertFalse(false)
    }
    
}
