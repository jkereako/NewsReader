//
//  AppCoordinator.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Alamofire
import Argo
import JSQCoreDataKit
import CoreData

final class AppCoordinator: NSObject {
  var subscribers = [AsyncOperationDelegate]()
  var coreDataStack: CoreDataStack? {
    didSet {
      for subscriber in subscribers {
        subscriber.coreDataStackDidFinish(context: coreDataStack!.mainContext)
      }
    }
  }

  // App settings. These are hardcoded because these are features.
  private let supportedSections: [Section] = [.Arts, .Business, .Politics, .Science, .Sports]
  private var topStories = [DecodedArticle]()
  private var communityKey: String!
  private var topStoriesKey: String!

  func start() {
    // Attempt to create the stack and immediately report halt execution if an error occurs.
    guard let stack = createCoreDataStack() else {
      assertionFailure("Expected the stack to have a value")
      return
    }

    coreDataStack = stack

    loadSecretsPropertyList()
    fetchTopStories(context: stack.mainContext) // Asynchronous
  }

  private func createCoreDataStack() -> CoreDataStack? {
    // Initialize the Core Data model, this class encapsulates the notion of a .xcdatamodeld file
    // The name passed here should be the name of an .xcdatamodeld file
    let model = CoreDataModel(name: "NewsReader", bundle: NSBundle.mainBundle())

    // Initialize a stack with a factory
    let factory = CoreDataStackFactory(model: model)

    switch factory.createStack() {
    case .Success(let stack):
      return stack

    case .Failure(let e):
      print("Error: \(e)")
      return nil
    }
  }

  private func loadSecretsPropertyList() {
    // Load the API Keys
    guard let path = NSBundle.mainBundle().pathForResource("Secrets", ofType: "plist"),
      let secrets = NSDictionary(contentsOfFile: path) else {
        assertionFailure("Unable to load `Secrets.plist`.")
        return
    }

    // Check if the keys are present
    guard let commKey = secrets["communityKey"] as? String where commKey.characters.count > 0,
      let topKey = secrets["topStoriesKey"] as? String where topKey.characters.count > 0 else {
        assertionFailure("Expected fields in `Secrets.plist` are missing or empty.")
        return
    }

    communityKey = commKey
    topStoriesKey = topKey
  }

  private func save(context context: NSManagedObjectContext) {
    // Save the objects to disk
    saveContext(context) { result in
      switch result {
      case .Success:
        assert(NSThread.isMainThread())

        for subscriber in self.subscribers {
          subscriber.contextDidSave(context: context)
        }

        print("Saved latest articles")

      case .Failure(let error):
        print("Save failed: \(error)")
      }
    }
  }

  /// Downloads the comments for a particular article
  private func fetchCommentsForArticle(article: Article) {
    Alamofire.request(Router.Comments(url: NSURL(string: article.url)!, apiKey: self.communityKey))
      .validate(contentType: ["application/json"])
      .responseJSON { response in

        switch response.result {
        case .Success:
          // REVIEW: I don't think this check ought to go here, but because of all the asynchronous
          // operations, this is the safest place to have this check.
          guard article.managedObjectContext != nil else {
            return
          }

          if let json = response.result.value as? JSONDictionary,
            let res = json["results"] as? JSONDictionary,
            let results = res["comments"] as? [AnyObject] {

            for result in results {
              if let j: AnyObject = result, let decoded: DecodedComment = decode(j) {
                // Place the comment in the managed object contxt
                Comment(
                  // Make sure that the article and the comment are using the same managed object
                  // context.
                  context: article.managedObjectContext!, decodedComment: decoded, article: article
                )
              }
            }
          }

        case .Failure(let error):
          // Error -6002 is a type mismatch between what's expected (JSON) and what was provided.
          // When we exceed the rate limit on the NYT API, an XML document is returned. Hence, the
          // type mismatch.
          if error.code == -6002 {
            print("You may have exceeded the rate limit of the Community API.")
          }
        }
    }
  }

  /// Downloads the top
  private func fetchTopStories(context context: NSManagedObjectContext) {
    // https://developer.apple.com/library/mac/documentation/Performance/Reference/GCD_libdispatch_Ref/index.html
    // Create a group for all of the asynchronous networking tasks handled by Alamofire. Each
    // asynchronous task is added to the group and popped off once it is complete. Then, when all
    // the tasks have been finished, we call `dispatch_group_notify` to tell the world we're done.
    let group = dispatch_group_create()

    for section in supportedSections {
      dispatch_group_enter(group)

      Alamofire.request(Router.TopStories(section: section, apiKey: topStoriesKey))
        .validate(contentType: ["text/json"])
        .responseJSON { response in

          dispatch_group_leave(group)

          switch response.result {
          case .Success:
            if let json = response.result.value as? JSONDictionary,
              let results = json["results"] as? [AnyObject] {

              for result in results {
                if let j: AnyObject = result, let decoded: DecodedArticle = decode(j) {
                  // Place the article in the managed object context
                  let article = Article(context: context, decodedArticle: decoded)

                  // download the comments
                  self.fetchCommentsForArticle(article)
                }
              }
            }

          case .Failure(let error):
            // Error -6002 is a type mismatch between what's expected (JSON) and what was provided.
            // When we exceed the rate limit on the NYT API, an XML document is returned. Hence, the
            // type mismatch.
            if error.code == -6002 {
              print("You may have exceeded the rate limit of the Top Stories API.")
            }
          }
      }
    }

    // Wait for all asynchronous tasks to finish and save the context to disk
    dispatch_group_notify(
      group, dispatch_get_main_queue(), {
        self.save(context: context)
      }
    )
  }
}
