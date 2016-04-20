//
//  DecodedComment.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/28/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Argo
import Curry

struct DecodedComment {
  let authorName: String
  let authorLocation: String
  let publishDate: NSDate
  let content: String
}

extension DecodedComment: Decodable {
  static func decode(j: JSON) -> Decoded<DecodedComment> {
    // https://github.com/thoughtbot/Argo/issues/272
    let f = curry(self.init)

    return f
      <^> j <| "userDisplayName"
      <*> j <| "userLocation"
      <*> (j <| "updateDate" >>- fromTimestampToDate )
      <*> j <| "commentBody"
  }
}
