//
//  Article.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Argo
import Curry

struct DecodedArticle {
  let title: String
  let byline: String
  let publishDate: NSDate
  let section: Section
  let url: NSURL
}

extension DecodedArticle: Decodable {
  static func decode(j: JSON) -> Decoded<DecodedArticle> {
    // https://github.com/thoughtbot/Argo/issues/272
    let f = curry(self.init)

    return f
      <^> j <| "title"
      <*> j <| "byline"

      // `published_date` is only a date whereas `updated_date` is a date-time.
      <*> (j <| "updated_date" >>- toDate)
      <*> (j <| "section" >>- toSection)
      <*> j <|  "url"
  }
}
