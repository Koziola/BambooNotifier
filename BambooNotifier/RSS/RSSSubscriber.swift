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
    private(set) var rssParser : FeedParser
    let refreshTimer : RefreshTimer?
    let subscribable : ISubscribable
    var mostRecentRSSEntry : RSSFeedItem?
    
    private init(feedURL : URL, refreshTimer : RefreshTimer, subscribable : ISubscribable){
        self.feedURL = feedURL
        self.refreshTimer = refreshTimer
        self.rssParser = FeedParser(URL: feedURL)!
        self.mostRecentRSSEntry = nil
        self.subscribable = subscribable
        parseFromFeed()
        subscribeToRefresh()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: Notification.Name(RefreshTimer.REFRESH_TIMER_NOTIFICATION), object: refreshTimer)
        debugPrint("RSSSubscriber refresh timer observer removed.")
    }
    
    private func parseFromFeed(){
        debugPrint("Parsing new entries for url: \(feedURL)")
        rssParser = FeedParser(URL: feedURL)!
        rssParser.parseAsync(result: { (result) in
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
        debugPrint("Count of items: \(String(describing: rssFeed.items?.count))")
        
        if let feedItems = rssFeed.items{
            if feedItems.count > 0 {
                noteMostRecentItem(feedItem: feedItems.first!)
            }
        }
    }
    
    private func noteMostRecentItem(feedItem : RSSFeedItem){
        guard let mostRecentEntryDate = mostRecentRSSEntry?.pubDate else{
            debugPrint("Most recent entry does not have a publication date.")
            mostRecentRSSEntry = feedItem
            return
        }
        guard let newFeedItemPubDate = feedItem.pubDate else{
            debugPrint("New item does not have a publication date.  Unable to compare.")
            return
        }
        debugPrint("New feed item pub date: \(newFeedItemPubDate)")
        debugPrint("most recent entry pub date: \(newFeedItemPubDate)")
        if (newFeedItemPubDate > mostRecentEntryDate){
            debugPrint("New entry encountered.  Firing notification...")
            fireUserNotification(feedItem: feedItem)
        } else {
            debugPrint("No new entry encountered.  Doing nothing.")
        }
        mostRecentRSSEntry = feedItem
    }
    
    private func fireUserNotification(feedItem : RSSFeedItem){
        let notification = NSUserNotification()
        notification.title = subscribable.name
        notification.informativeText = feedItem.title
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func subscribeToRefresh(){
        NotificationCenter.default.addObserver(self, selector: #selector(doRefresh(_:)), name: Notification.Name(RefreshTimer.REFRESH_TIMER_NOTIFICATION), object: refreshTimer)
    }
    
    @objc func doRefresh(_ sender: Any?){
        parseFromFeed()
    }
    
    static func createBambooSubscriber(subscribable : ISubscribable, refreshTimer : RefreshTimer) -> RSSSubscriber?{
        let urlString = "http://havokbamboo/rss/createAllBuildsRssFeed.action?feedType=rssAll&buildKey=\(subscribable.key)"
        guard let url = URL(string: urlString) else{
            print("Error creating bamboo RSS subscriber URL.")
            return nil
        }
        let subscriber = RSSSubscriber(feedURL: url, refreshTimer: refreshTimer, subscribable: subscribable)
        return subscriber
    }
}
