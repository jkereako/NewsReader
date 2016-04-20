//
//  NewsReaderTests.swift
//  NewsReaderTests
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import XCTest
@testable import NewsReader

class RouterTests: XCTestCase {

  func testTopStoriesRoute() {
    let expectation = "http://api.nytimes.com/svc/topstories/v1/technology.json?api-key=mashedpotatoes"
    let route = Router.TopStories(section: .Technology, apiKey: "mashedpotatoes")

    XCTAssertEqual(expectation, route.URLRequest.URLString)
  }

  func testCommentsRoute() {
    let expectation = "http://api.nytimes.com/svc/community/v3/user-content/url.json?api-key=212u2shud324hire32me&url=http%3A//www.nytimes.com/2016/03/27/your-money/forget-the-new-iphone-for-apple-its-all-about-the-dollar.html"

    let route = Router.Comments(
      url: NSURL(
        string: "http://www.nytimes.com/2016/03/27/your-money/forget-the-new-iphone-for-apple-its-all-about-the-dollar.html"
        )!,
      apiKey: "212u2shud324hire32me"
    )

    XCTAssertEqual(expectation, route.URLRequest.URLString)
  }
}
