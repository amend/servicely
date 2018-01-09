//
//  servicelyUITests.swift
//  servicelyUITests
//
//  Created by Andoni Mendoza on 1/8/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import XCTest

class servicelyUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        self.app = XCUIApplication()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoginTokyoUser() {
        self.app.launch()
        
        loginTokyoUser()
    }
    
    func loginTokyoUser() {
        if(self.isDisplayingFeed) {
            app.tabBars.buttons["Settings"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Enter your email"].typeText("tokyo@tokyo.com\r")
        tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.secureTextFields["Enter your password"].typeText("123456\r")
        
    }
    
    func testCreateClientRequest() {
        self.app.launch()

        // in case user is logged out
        loginTokyoUser()
        
        // in case not on feed
        if(!isDisplayingFeed) {
            app.tabBars.buttons["Feed"].tap()
        }
        
        app.navigationBars["Feed"].buttons["Post"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("Test")
        
        let submitButton = app.buttons["Submit"]
        submitButton.tap()
        
        if(app.staticTexts["Getting city location... Please wait"].exists) {
            
            
            let predicate = NSPredicate(format: "exists == 0")
            let query = app.staticTexts["Getting city location... Please wait"]
            expectation(for: predicate, evaluatedWith: query, handler: nil)
            waitForExpectations(timeout: 20, handler: nil)
            
            // after delay
            submitButton.tap()
            
            XCTAssert(!self.app.staticTexts["Getting city location... Please wait"].exists)
            
            XCTAssert(self.app.staticTexts["saved!"].exists)

            
            
            /*
            let when = DispatchTime.now() + 15 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // after delay
                submitButton.tap()
                
                // will fail if getting location took more than 15 seconds
                XCTAssert(!self.app.staticTexts["Getting city location... Please wait"].exists)
                
                XCTAssert(self.app.staticTexts["saved!"].exists)
            }
            */
            
            
            
        } else {
            submitButton.tap()
            XCTAssert(self.app.staticTexts["saved!"].exists)
        }
    }
}

extension servicelyUITests {
    var isDisplayingFeed: Bool {
        return app.navigationBars["Feed"].buttons["Post"].exists
    }
}
