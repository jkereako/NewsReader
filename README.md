# What is this?
This app is a technical assessment which I was asked to complete prior to an
interview. I'm not in violation of a contract as I did not sign an NDA nor is
there anything in this project which is particular to the organization.

I spent around 15 hours on this project because I wanted to impress the
interviewers. Interview day comes and I learn that no one has seen the app. I
was asked to "walk through the code". As you can see, there's a shitload of
files in this project so I had no idea where to start and where to end. I
fumbled, communicated poorly and, of course, was rejected.

Everything from **Description** on down was in a README which I included in the
project. No one looked at that, either.

### Heed my warning
If you are asked to complete a project to assess your skill and you estimate
that project will take longer than 1 hour, **demand upfront, market-rate
compensation** or **don't fucking do it**. If you complete the project for free,
not only are you liable to completely waste your time, you also send the message
that you're a doormat.

# Description
Displays a searchable list of the most recent top stories from the NY Times. You
can read the article **as text** inside the app... no ads! You may also view a
list of comments for each article that has comments.

> NOTE: This app interfaces with the NY Times REST API. It requires API keys for
> both the Top Stories API and Communities (i.e. comments) API. Add the keys to
> the file `Resources/Secrets.example.plist` and rename it to `Secrets.plist`.

### Features
- Persistent storage of content
- Searchable article titles
- Articles display as text, not as a web view
- Support for article comments

# Requirements
This project has several dependencies managed by Carthage. If you do not have
Carthage, then install it with Homebrew and run `carthage update` in the root
directory of this project.

```sh
% brew install Carthage
% carthage update
```

# Libraries used
- [Alamofire]: Network operations
- [JSQCoreDataKit]: Handles basic Core Data operations
- [Argo]: Decodes dictionaries of type `[String: AnyObject]` into structs
- [Curry]: Defines curried functions which take up to 26 arguments
- [Fuzi]: A Swift interface for libxml2 used to scrape article content
- [TimeAgo]: Prints NSDate objects in a relative date format

# Challenges
The greatest challenge was to decide how I was to present the article content so
it reflected the UI design. Since the content is not part of the API, I had to
download the HTML document and extract the article content. I used the [Fuzi]
framework to extract the content as text and save it in Core Data.

The second challenge was to keep track of all of the asynchronous network
operations. Before this challenge, I never had to manage multiple asynchronous
tasks, so it was not clear how to solve this issue. I then learned about GCD's
dispatch groups. This solved the issue in few lines of code.

# Design
### Type-safe routes
The routes and available news categories for the API are represented with Swift
enums. Since enums are types in Swift, the compiler will alert us if we made a
mistake. Additionally, the code is easier to read.

```swift
Router.TopStories(section: section, apiKey: topStoriesKey)
```

### Coordinators
Coordinators manage tasks unrelated to view management such as networking. It is
another way to mitigate "massive view controller". In the context of this app, I
use 2 coordinators: the app coordinator which handles task common to the entire
app (i.e. network and storage operations), and an article coordinator for tasks
which only relate to articles (i.e. the HTML parse operation).

The original idea of app coordinators was proposed by [Saroush
Khanlou][coordinators]. To take full advantage of coordinators requires the
developer to abandon Storyboards and instead rely on the old-fashioned method;
load Nibs from their corresponding controllers.

### JSON decoders
Before we operate on the data retrieved from the API, we first ought to validate
it. The best method to validate JSON is to parse the JSON into structs with
non-optional types. The framework [Argo] does just that does just that.

When given a dictionary of type `[String: AnyObject]`, Argo will attempt to
decode that dictionary into a struct.

The code below looks for the keys "title", "byline", "updated_date", "section"
and "url" and attempts to convert each value into it's corresponding type. If
even 1 of the conversions fail, then the object is deemed invalid. This strict
behavior keeps the code bullet-proof.

```swift
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
```

The catch to Argo is the steep learning curve. Argo relies on functional
programming concepts, such as currying. However, for basic JSON decoding, Argo
is easy to use. I learned how to use Argo a month ago and now use it in all iOS
projects which consume JSON data.

### Persistent storage
Why did I bother to store the articles persistently when it was not a
requirement? The real reason is because I wanted to try [JSQCoreDataKit], but
the other, more practical reason, is because I could delegate the table view
data source management to a fetched results controller.

Over the last couple years I have learned that a majority of Core Data code is
boilerplate and that includes the fetched results controller. Since I have
worked with Core Data several times in the past, most of the logic to handle
persistent storage had already been written and it was generic enough for me to
apply to this project. So, in short, it was actually easier for me to
persistently store the objects rather than manage them myself.


[Alamofire]: ttps://github.com/Alamofire/Alamofire
[JSQCoreDataKit]: https://github.com/jessesquires/JSQCoreDataKit
[Argo]: https://github.com/thoughtbot/Argo
[Curry]: https://github.com/thoughtbot/Curry
[Fuzi]: https://github.com/cezheng/Fuzi
[TimeAgo]: https://github.com/hyperoslo/TimeAgo
[coordinators]: http://khanlou.com/2015/10/coordinators-redux/
