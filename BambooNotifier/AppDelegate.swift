//
//  AppDelegate.swift
//  BambooNotifier
//
//  Created by Adam Koziol on 1/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let notifierStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let notifierPopover = NSPopover()
    let notifierModel = NotifierModel()
    var refreshTimer : RefreshTimer = RefreshTimer()
    var feeds = [String: RSSSubscriber]()
    
    lazy var contextMenu : NSMenu = createContextMenu()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        notifierPopover.behavior = .transient
        ModelPersistence.loadModel(model: notifierModel)
        
        setStatusItemImage()
        setStatusItemAction()
        addModelObserver()
    }

    private func setStatusItemImage(){
        notifierStatusItem.image = NSImage(named: NSImage.Name("logoBambooPNG"))
    }
    
    private func setStatusItemAction(){
        notifierStatusItem.action = #selector(toggleNotifierPopover(_:))
        notifierStatusItem.sendAction(on: [NSEvent.EventTypeMask(rawValue: NSEvent.EventTypeMask.RawValue(UInt8(NSEvent.EventTypeMask.leftMouseUp.rawValue) | UInt8(NSEvent.EventTypeMask.rightMouseUp.rawValue)))])
    }
    
    private func addModelObserver(){
        let options : UInt = NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue | NSKeyValueObservingOptions.prior.rawValue
        notifierModel.addObserver(self, forKeyPath: #keyPath(NotifierModel.subscriptions), options: NSKeyValueObservingOptions.init(rawValue: options), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(NotifierModel.subscriptions):
            guard let changeKind = NSKeyValueChange(rawValue: change![NSKeyValueChangeKey.kindKey] as! UInt) else {
                debugPrint("Unable to determine kind of KVO change.")
                return
            }

            let prior = change![NSKeyValueChangeKey.notificationIsPriorKey] as? Bool
            
            switch changeKind {
                case NSKeyValueChange.insertion:
                    if prior != nil {
                        return
                    }
                    let changedIndex = (change![NSKeyValueChangeKey.indexesKey] as! NSIndexSet).firstIndex
                    let changedSub = notifierModel.subscriptions[changedIndex]
                    AddSubscriberFeed(subscribable: changedSub)
                    break
                case NSKeyValueChange.removal:
                    if prior == nil {
                        return
                    }
                    let changedIndex = (change![NSKeyValueChangeKey.indexesKey] as! NSIndexSet).firstIndex
                    let changedSub = notifierModel.subscriptions[changedIndex]
                    RemoveSubscriberFeed(subscribable: changedSub)
                    break
                default:
                    debugPrint("No responder for change kind: \(changeKind)")
            }
        default:
            break
        }
    }
    
    private func AddSubscriberFeed(subscribable : ISubscribable){
        guard let newRSSSubscriber = RSSSubscriber.createBambooSubscriber(subscribable: subscribable, refreshTimer: refreshTimer) else {
            return
        }
        feeds[subscribable.key] = newRSSSubscriber
        debugPrint("New subscriber added: \(subscribable.name)")
    }
    
    private func RemoveSubscriberFeed(subscribable: ISubscribable){
        var existingSub = feeds.removeValue(forKey: subscribable.key)
        if existingSub == nil {
            debugPrint("Unable to find existing subscriber for key \(subscribable.key)")
            return
        }
        existingSub = nil
         debugPrint("Subscriber successfully removed: \(subscribable)")
    }
    
    private func addFeeds(){
//        //for testing & debugging
//        let rssURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!
//        if let rssFeed = RSSSubscriber.createSubscriber(feedURL: rssURL, refreshTimer: refreshTimer) {
//            feeds.append(rssFeed)
//        }
    }
    
    @objc func toggleNotifierPopover(_ sender: Any?){
        let event = NSApp.currentEvent!
        
        switch event.type {
        case NSEvent.EventType.rightMouseUp:
            doStatusBarItemRightClick()
            break
        default:
            doStatusBarItemLeftClick()
            break
        }

    }
    
    private func doStatusBarItemRightClick(){
        if (notifierPopover.isShown){
            notifierPopover.close()
        }
        notifierStatusItem.popUpMenu(contextMenu)
    }
    
    private func createContextMenu() -> NSMenu{
        let menu = NSMenu()
        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit"
        quitMenuItem.action = #selector(quitPressed(_:))
        menu.addItem(quitMenuItem)
        return menu
    }
    
    @objc private func quitPressed(_ sender: Any?){
        NSApp.terminate(sender)
    }
    
    private func doStatusBarItemLeftClick(){
        if (notifierPopover.isShown){
            notifierPopover.close()
        } else if let button = notifierStatusItem.button {
            notifierPopover.contentViewController = NotifierViewController.freshController(model: notifierModel)
            notifierPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        ModelPersistence.saveModel(model: notifierModel)
    }
}

