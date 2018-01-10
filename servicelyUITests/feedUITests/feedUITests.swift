//
//  feedUITests.swift
//  servicelyUITests
//
//  Created by Andoni Mendoza on 1/9/18.
//  Copyright © 2018 Andoni Mendoza. All rights reserved.
//

import XCTest

class feedUITests: XCTestCase {
        
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        app = XCUIApplication()
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        sleep(3)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testCreateClientRequestShowsOnFeed() {
        
        
        let app = XCUIApplication()
        
        loginClientUser()
        goToFeed()
        
        let feedNavigationBar = app.navigationBars["Feed"]
        feedNavigationBar.buttons["Post"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        
        // create new randonized client request
        
        let randomString = String(Int(arc4random_uniform(100000)))
        
        textView.typeText(randomString)
        app.buttons["Submit"].tap()
        feedNavigationBar.buttons["Feed"].tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Settings"].tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Email"]/*[[".cells[\"EmailCellAccessibilityID\"].staticTexts[\"Email\"]",".staticTexts[\"Email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Enter your email"].typeText("provider@provider.com\r")
        
        tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.secureTextFields["Enter your password"].typeText("123456\r")
        tabBarsQuery.buttons["Feed"].tap()
        
        XCUIApplication().tables.children(matching: .cell).element(boundBy: 0).staticTexts["C C"].waitForExistence(timeout: 10)
        
        XCUIApplication().tables.children(matching: .cell).element(boundBy: 0).staticTexts["C C"].tap()
        
        XCTAssertTrue(app.staticTexts[randomString].exists)
    }
    
    func testCreateServiceOfferShowsOnFeed() {
        let app = XCUIApplication()
        
        loginProviderUser()
        goToFeed()
        
        let feedNavigationBar = app.navigationBars["Feed"]
        feedNavigationBar.buttons["Post"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let textView = scrollViewsQuery.otherElements.containing(.staticText, identifier:"What type of service offer?").children(matching: .textView).element
        textView.tap()
        
        let randomString = String(Int(arc4random_uniform(100000)))
        textView.typeText(randomString)
        
        let whatTypeOfServiceOfferElement = scrollViewsQuery.otherElements.containing(.staticText, identifier:"What type of service offer?").element
        whatTypeOfServiceOfferElement.swipeUp()
        
        let elementsQuery = scrollViewsQuery.otherElements
        let textField = elementsQuery.textFields["$15/hour"]
        textField.tap()
        textField.tap()
        textField.typeText("$5")
        
        let handyMenTextField = elementsQuery.textFields["Handy Men"]
        handyMenTextField.tap()
        handyMenTextField.typeText("Test Inc")
        
        let textField2 = elementsQuery.textFields["956 321 9876"]
        textField2.tap()
        textField2.tap()
        textField2.typeText("483 843 8383")
        elementsQuery.buttons["Submit"].tap()
        whatTypeOfServiceOfferElement.swipeUp()
        
        let feedButton = app.navigationBars["Feed"].buttons["Feed"]
        feedButton.tap()
        
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Settings"].tap()
        
        let tablesQuery2 = app.tables
        let tablesQuery = tablesQuery2
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery2.cells["EmailCellAccessibilityID"].children(matching: .other).element(boundBy: 1).tap()
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.typeText("client@client.com\r")
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Password"]/*[[".cells.staticTexts[\"Password\"]",".staticTexts[\"Password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.secureTextFields["Enter your password"].typeText("123456\r")
        tabBarsQuery.buttons["Feed"].tap()
        
        
        app.tables.children(matching: .cell).element(boundBy: 0).staticTexts["Test Inc"].waitForExistence(timeout: 10)
        
        app.tables.children(matching: .cell).element(boundBy: 0).staticTexts["Test Inc"].tap()
        
        print(randomString)
        if(app.staticTexts[randomString].exists) {
            print(randomString)
            print("randomString exists")
        } else {
            print(randomString)
            print("randomstring does not exist")
        }
        
        XCTAssertTrue(app.staticTexts[randomString].exists)
        
    }




}

extension feedUITests {
    var isDisplayingFeed: Bool {
        
        if(app.navigationBars["Feed"].buttons["Post"].exists) {
            print("in feed")
        }
        
        return app.navigationBars["Feed"].buttons["Post"].exists
    }
    
    var isDisplayingLogin: Bool {
        
        if(app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists) {
            print("in login")
        }
        
        return app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.exists
    }
    
    func goToFeed() {
        app.tabBars.buttons["Feed"].tap()
    }
    
    func loginProviderUser() {
        if(self.isDisplayingFeed) {
            app.tabBars.buttons["Settings"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Enter your email"].typeText("provider@provider.com\r")
        tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.secureTextFields["Enter your password"].typeText("123456\r")
    }
    
    func loginClientUser() {
        if(self.isDisplayingFeed) {
            app.tabBars.buttons["Settings"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Sign Out"]/*[[".cells.staticTexts[\"Sign Out\"]",".staticTexts[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        
        app/*@START_MENU_TOKEN@*/.buttons["EmailButtonAccessibilityID"]/*[[".buttons[\"Sign in with email\"]",".buttons[\"EmailButtonAccessibilityID\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.textFields["Enter your email"]/*[[".cells[\"EmailCellAccessibilityID\"].textFields[\"Enter your email\"]",".textFields[\"Enter your email\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.textFields["Enter your email"].typeText("client@client.com\r")
        tablesQuery/*@START_MENU_TOKEN@*/.secureTextFields["Enter your password"]/*[[".cells.secureTextFields[\"Enter your password\"]",".secureTextFields[\"Enter your password\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        tablesQuery.secureTextFields["Enter your password"].typeText("123456\r")
    }
    
}

