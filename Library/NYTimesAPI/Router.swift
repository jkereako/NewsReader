//
//  Router.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Alamofire

// https://github.com/Alamofire/Alamofire#api-parameter-abstraction
enum Router: URLRequestConvertible {
  static let baseURLString = "http://api.nytimes.com/svc"

  case TopStories(section: Section, apiKey: String)
  case Comments(url: NSURL, apiKey: String)

  // MARK: - URLRequestConvertible
  var URLRequest: NSMutableURLRequest {
    let result: (path: String, parameters: [String: AnyObject]) = {
      switch self {
      case .TopStories(let section, let apiKey):
        return ("/topstories/v1/\(section.rawValue.lowercaseString).json", ["api-key": apiKey])

      case .Comments(let url, let apiKey):
        return ("/community/v3/user-content/url.json", ["url": url.absoluteString, "api-key": apiKey])
      }
    }()

    let url = NSURL(string: Router.baseURLString)!
    let urlRequest = NSURLRequest(URL: url.URLByAppendingPathComponent(result.path))
    let encoding = Alamofire.ParameterEncoding.URL

    return encoding.encode(urlRequest, parameters: result.parameters).0
  }
}
