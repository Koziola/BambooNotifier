//
//  RSSSubscriber.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/22/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Foundation
import FeedKit

class RSSSubscriber {
    let feedURL : URL
    let rssParser : FeedParser?
    let refreshTimer : RefreshTimer?
    var mostRecentRSSEntry : RSSFeedItem?
    
    private init(feedURL : URL, refreshTimer : RefreshTimer){
        self.feedURL = feedURL
        self.refreshTimer = refreshTimer
        self.rssParser = FeedParser(URL: feedURL)
        self.mostRecentRSSEntry = nil
        parseFromFeed()
        subscribeToRefresh()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: Notification.Name(RefreshTimer.REFRESH_TIMER_NOTIFICATION), object: refreshTimer)
    }
    
    private func parseFromFeed(){
        rssParser?.parseAsync(queue: .global(), result: { (result) in
            self.interpretResults(result: result)
        })
    }
    
    private func interpretResults(result : Result) {
        if (result.isFailure && result.error != nil) {
            debugPrint("Failed to parse RSS feed.  Error:")
            debugPrint(result.error!.description)
            return
        }
        
        let rssFeed = result.rssFeed!
        debugPrint("RSS INFO FOR TIME: \(Date.init())")
        debugPrint("Last content change timestamp: \(String(describing: rssFeed.lastBuildDate))")
        debugPrint("Count of items: \(String(describing: rssFeed.items?.count))")
        
        if let feedItems = rssFeed.items{
            if feedItems.count > 0 {
                noteMostRecentItem(feedItem: feedItems.first!)
            }
        }
    }
    
    private func noteMostRecentItem(feedItem : RSSFeedItem){
        if (mostRecentRSSEntry?.pubDate!.compare(feedItem.pubDate!) == ComparisonResult.orderedDescending){
            debugPrint("New entry encountered.  Firing notification")
        } else{
            debugPrint("No existing entry.  Adding new entry as existing.")
        }
        mostRecentRSSEntry = feedItem
    }
    
    private func subscribeToRefresh(){
        NotificationCenter.default.addObserver(self, selector: #selector(doRefresh(_:)), name: Notification.Name(RefreshTimer.REFRESH_TIMER_NOTIFICATION), object: refreshTimer)
    }
    
    @objc func doRefresh(_ sender: Any?){
        parseFromFeed()
    }
    
    static func createSubscriber(feedURL : URL, refreshTimer : RefreshTimer) -> RSSSubscriber? {
        let subscriber = RSSSubscriber(feedURL: feedURL, refreshTimer: refreshTimer)
        if subscriber.rssParser == nil{
            return nil
        }
        return subscriber
    }
}
