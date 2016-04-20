//
//  ArticleCoordinator.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/27/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit
import Alamofire
import JSQCoreDataKit
import CoreData

struct ArticleCoordinator {
  let viewController: ArticleController
  let article: Article
  let context: NSManagedObjectContext

  func fetchArticle() {
    Alamofire.request(.GET, article.url)
      .validate(contentType: ["text/html"])
      .responseString { response in
        switch response.result {
        case .Success:
          let htmlContent = self.parseContent(response.result.value!)
          self.viewController.content = htmlContent

          // Save the objects to disk
          saveContext(self.context) { result in
            switch result {
            case .Success:
              print("Saved article content")

            case .Failure(let error):
              print("Save failed: \(error)")
            }
          }
          
        case .Failure(let error):
          print(error)
        }
    }
  }

  private func parseContent(content: String) -> String {
    let parser = HTMLParser(
      xPathQuery: "//div[contains(concat(\" \", normalize-space(@class), \" \"), \" story-body \")]/p",
      html: content
    )
    
    if let results = parser.parse() {
      return results.joinWithSeparator("\n\n")
    }

    return "Unable to load content"
  }
}