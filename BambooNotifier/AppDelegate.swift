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
//        addFeeds()
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
//        notifierStatusItem.menu = contextMenu
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "BambooNotifier")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }

}

