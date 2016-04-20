//
//  Helpers.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Argo

let fromTimestampToDate: String -> Decoded<NSDate> = {
  pure(NSDate(timeIntervalSince1970: NSTimeInterval($0)!))
}

/// Convert a String to a Date
let toDate: String -> Decoded<NSDate> = {
  .fromOptional(
    jsonParserDateFormatter.dateFromString(
      // The NYT's timezone offset format is one that, of course, isn't supported by
      // `NSDateFormatter`. We have to remove the colon
      $0.stringByReplacingOccurrencesOfString(
        "-5:00", withString: "-500", options: .LiteralSearch, range: nil
      )
    )
  )
}

/// Convert a String to a Section
let toSection: String -> Decoded<Section> = {
  .fromOptional(Section(rawValue: $0))
}

let jsonParserDateFormatter: NSDateFormatter = {
  let dateFormatter = NSDateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZ"
  return dateFormatter
}()
