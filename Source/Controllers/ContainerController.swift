//
//  ContainerController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit
import Alamofire

let dismissSearchBarNotification = NSBundle.mainBundle().bundleIdentifier! + ".dismissSearchBar"

final class ContainerController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!

  private var constraintConstants = (searchBar: CGFloat(1.0), container: CGFloat(1.0))
  private let appCoordinator = AppCoordinator()
  private var navBarBackgroundColor: UIColor!
  private var navBarTintColor: UIColor!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Cache the bar tint color so we can change backt to it later.
    navBarBackgroundColor = navigationController?.navigationBar.barTintColor
    navBarTintColor = navigationController?.navigationBar.tintColor

    appCoordinator.start()

    constraintConstants.searchBar = -CGRectGetHeight(searchBar.frame)
    constraintConstants.container = 0

    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(stopButtonAction), name: dismissSearchBarNotification, object: nil
    )
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    // Animate the color change of the navigation bar.
    // see: https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewControllerTransitionCoordinator_Protocol/index.html
    transitionCoordinator()?.animateAlongsideTransition(
      { [unowned self] (context: UIViewControllerTransitionCoordinatorContext) in
        let navBar = self.navigationController!.navigationBar

        navBar.setBackgroundImage(
          nil, forBarMetrics: .Default
        )
        
        navBar.barTintColor = self.navBarBackgroundColor
        navBar.tintColor = self.navBarTintColor
      },
      completion: nil
    )
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard segue.identifier == "embedHeadlines", let toVC = segue.destinationViewController as?
      HeadlinesViewController else {
        assertionFailure("Expected a `HeadlinesViewController`.")
        return
    }

    // Notify the view controller when the core data stack is ready.
    appCoordinator.subscribers.append(toVC)

    toVC.appCoordinator = appCoordinator
    searchBar.delegate = toVC
  }

  override func updateViewConstraints() {
    searchBarTopConstraint.constant = constraintConstants.searchBar
    containerTopConstraint.constant = constraintConstants.container

    super.updateViewConstraints()
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension ContainerController {
  func displaySearchBar() {

    constraintConstants.searchBar = 0
    constraintConstants.container = CGRectGetHeight(searchBar.frame)

    view.layoutIfNeeded()
    view.setNeedsUpdateConstraints()
    view.updateConstraintsIfNeeded()

    UIView.animateWithDuration(
      0.25,
      animations: { [unowned self] in
        self.view.layoutIfNeeded()
      }
    )
  }

  func dismissSearchBar() {

    constraintConstants.searchBar = -CGRectGetHeight(searchBar.frame)
    constraintConstants.container = 0

    // Ensures that all pending layout operations have been completed
    view.layoutIfNeeded()
    view.setNeedsUpdateConstraints()
    view.updateConstraintsIfNeeded()

    UIView.animateWithDuration(
      0.25,
      animations: { [unowned self] in

        self.view.endEditing(false)
        self.view.layoutIfNeeded()
      }
    )
  }

  @IBAction func searchButtonAction(sender: UIBarButtonItem) {
    let barButton = UIBarButtonItem(
      barButtonSystemItem: .Stop, target: self, action: #selector(stopButtonAction)
    )
    navigationItem.setRightBarButtonItem(barButton, animated: true)

    displaySearchBar()
  }

  @IBAction func stopButtonAction(sender: UIBarButtonItem) {
    let barButton = UIBarButtonItem(
      barButtonSystemItem: .Search, target: self, action: #selector(searchButtonAction)
    )
    navigationItem.setRightBarButtonItem(barButton, animated: true)

    dismissSearchBar()
  }
}
