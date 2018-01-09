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
        
        app = XCUIApplication()
        XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        sleep(3)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLoginProviderUser() {
       // app.launch()
        
        loginProviderUser()
        
        app.tabBars.buttons["Feed"].waitForExistence(timeout: 10)
        
        XCTAssertTrue(app.tabBars.buttons["Feed"].exists)
        
    }
    
    func testCreateClientRequestSaves() {
        //app.launch()

        // button tap not going into handler unless login process is done
        // weird, but i couldnt find a solution, so this does the login and
        // navigaet to feed
        loginClientUser()
        goToFeed()
        
        // if you figure out the button issue, comment the above out and
        // comment the below in
        /*
        // in case not on feed
        if(!isDisplayingFeed) {
            if(isDisplayingLogin) {
                loginTokyoUser()
            } else {
                // if not displaying login, we navigate to feed
                goToFeed()
            }
        }
        */
        
        app.navigationBars["Feed"].buttons["Post"].tap()
        
        let textView = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .textView).element
        textView.tap()
        textView.typeText("Test")
        
        /*
        let submitButton = app.buttons["Submit"]
        //submitButton.tap()
        submitButton.forceTapElement()
         */
        
        if(app.staticTexts["Getting city location... Please wait"].exists) {
            // could not recreate this part if coditinal. might fail
            let predicate = NSPredicate(format: "exists == 0")
            let query = app.staticTexts["Getting city location... Please wait"]
            expectation(for: predicate, evaluatedWith: query, handler: nil)
            waitForExpectations(timeout: 10, handler: nil)
            
            // after dely
            let submitButton = app.buttons["Submit"].tap()
            
            app.staticTexts["saved!"].waitForExistence(timeout: 10)
            
            XCTAssert(app.staticTexts["saved!"].exists)
        } else {
            app.buttons["Submit"].tap()
            
            app.staticTexts["saved!"].waitForExistence(timeout: 10)

            XCTAssert(app.staticTexts["saved!"].exists)
        }
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

extension servicelyUITests {
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

extension XCUIElement {
    func forceTapElement() {
        if self.isHittable {
            self.tap()
        }
        else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx:0.0, dy:0.0))
            coordinate.tap()
        }
    }
}
