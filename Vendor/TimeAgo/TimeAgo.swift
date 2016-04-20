//
//  TimeAgo.swift
//  NewsReader
//
//  Created by Hyper on 6/1/15.
//  Copyright © 2016 Hyper
//
//  The MIT License (MIT)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

func NSDateTimeAgoLocalizedStrings(key: String) -> String {
  let bundlePath = NSBundle.mainBundle().bundlePath
    + "/Frameworks/TimeAgo.framework/NSDateTimeAgo.bundle"
  guard let bundle = NSBundle(path: bundlePath) else { return NSLocalizedString(key, comment: "") }

  return NSLocalizedString(key, tableName: "NSDateTimeAgo", bundle: bundle, comment: "")
}

func isInTheFuture(date: NSDate) -> Bool {
  if (date.compare(NSDate()) == NSComparisonResult.OrderedDescending) {
    return true
  }
  return false
}

public extension NSDate {
  var timeAgo: String {

    if isInTheFuture(self) {
      return NSDateTimeAgoLocalizedStrings("Just now")
    }

    let now = NSDate()
    let seconds = Int(fabs(timeIntervalSinceDate(now)))
    let minutes = Int(round(Float(seconds) / 60.0))
    let hours = Int(round(Float(minutes) / 60.0))

    if seconds < 5 {
      return NSDateTimeAgoLocalizedStrings("Just now")
    } else if seconds < 60 {
      return stringFromFormat("%%d %@seconds ago", withValue: seconds)
    } else if seconds < 120 {
      return NSDateTimeAgoLocalizedStrings("A minute ago")
    } else if minutes < 60 {
      return stringFromFormat("%%d %@minutes ago", withValue: minutes)
    } else if minutes < 120 {
      return NSDateTimeAgoLocalizedStrings("An hour ago")
    } else if hours < 24 {
      return stringFromFormat("%%d %@hours ago", withValue: hours)
    } else if hours < 24 * 7 {
      let formatter = NSDateFormatter()

      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      return formatter.stringFromDate(self)
    } else {
      let formatter = NSDateFormatter()

      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      return formatter.stringFromDate(self)
    }
  }

  var timeSince: String {

    if isInTheFuture(self) {
      return NSDateTimeAgoLocalizedStrings("Now")
    }

    let now = NSDate()
    let seconds = Int(fabs(timeIntervalSinceDate(now)))
    let minutes = Int(round(Float(seconds) / 60.0))
    let hours = Int(round(Float(minutes) / 60.0))

    if seconds < 5 {
      return NSDateTimeAgoLocalizedStrings("Now")
    } else if seconds < 60 {
      return stringFromFormat("%%d %@sec", withValue: seconds)
    } else if minutes < 60 {
      return stringFromFormat("%%d %@min", withValue: minutes)
    } else if hours < 24 {
      return stringFromFormat("%%d %@h", withValue: hours)
    } else if hours < 24 * 7 {
      let formatter = NSDateFormatter()

      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      return formatter.stringFromDate(self)
    } else {
      let formatter = NSDateFormatter()

      formatter.dateStyle = .ShortStyle
      formatter.timeStyle = .ShortStyle
      return formatter.stringFromDate(self)
    }
  }

  func stringFromFormat(format: String, withValue value: Int) -> String {
    let localeFormat = String(
      format: format,
      getLocaleFormatUnderscoresWithValue(Double(value)))

    return String(format: NSDateTimeAgoLocalizedStrings(localeFormat), value)
  }

  func getLocaleFormatUnderscoresWithValue(value: Double) -> String {
    let localeCode = NSLocale.preferredLanguages().first!

    if localeCode == "ru" {
      let XY = Int(floor(value)) % 100
      let Y = Int(floor(value)) % 10

      if Y == 0 || Y > 4 || (XY > 10 && XY < 15) {
        return ""
      }

      if Y > 1 && Y < 5 && (XY < 10 || XY > 20) {
        return "_"
      }

      if Y == 1 && XY != 11 {
        return "__"
      }
    }
    
    return ""
  }
}
