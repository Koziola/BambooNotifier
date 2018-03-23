//
//  NotifierViewController
//  BambooNotifier
//
//  Created by Adam Koziol on 1/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Cocoa

class NotifierViewController: NSViewController, NSBrowserDelegate {

    var notifierModel : NotifierModel? = nil
    
    @IBOutlet var instanceURLField: NSTextField!
    @IBOutlet var bambooBrowser: NSBrowser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureInstanceURLField()

        configureBrowser()
    }
    
    @objc func doInstanceURLChanged(_ sender: Any?){
        if let newURL = createURLFromString(urlString: instanceURLField.stringValue){
            print ("New valid URL: \(newURL.absoluteString)")
            notifierModel!.bambooInstanceRootURL = newURL
            let projectResource = BambooAPIRequest<BambooProjectResource>(basePath: newURL, resource: BambooProjectResource())
            projectResource.load(success: {projects in
                print(projects?.count)
                self.notifierModel?.projectList = projects!
                DispatchQueue.main.async {
                    self.bambooBrowser.reloadColumn(0)
                }
            }, fail: {errString in
                print(errString)
            })
        }
    }
    
    private func createURLFromString(urlString : String?) -> URL? {
        if let urlString = urlString{
            if let url = URL(string: urlString){
                return url
            }
        }
        return nil
    }
    
    private func configureInstanceURLField() {
        instanceURLField.placeholderString = "None"
        instanceURLField.action = #selector(doInstanceURLChanged(_:))
//        instanceURLField.backgroundColor = .controlBackgroundColor
    }
    
    private func configureBrowser(){
        bambooBrowser.backgroundColor = .clear
        bambooBrowser.autohidesScroller = true
        bambooBrowser.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        instanceURLField.stringValue = notifierModel?.bambooInstanceRootURL?.absoluteString ?? ""
        if instanceURLField.stringValue != ""{
            instanceURLField.refusesFirstResponder = true
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
//     MARK: Browser View Data Source
    func rootItem(for browser: NSBrowser) -> Any? {
        return notifierModel?.projectList
    }

    func browser(_ sender: NSBrowser, willDisplayCell cell: Any, atRow row: Int, column: Int) {
        //dunno what to do here
        (cell as! NSBrowserCell).title = notifierModel!.projectList[row].name
    }

    func browser(_ sender: NSBrowser, numberOfRowsInColumn column: Int) -> Int {
        return notifierModel!.projectList.count
    }
}

extension NotifierViewController {
    // MARK: Storyboard instantiation
    static func freshController(model : NotifierModel) -> NotifierViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "NotifierViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NotifierViewController else {
            fatalError("Check Main.storyboard for NotifierViewController")
        }
        viewcontroller.notifierModel = model
        return viewcontroller
    }
}

