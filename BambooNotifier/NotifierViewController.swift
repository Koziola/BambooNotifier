//
//  NotifierViewController
//  BambooNotifier
//
//  Created by Adam Koziol on 1/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Cocoa

class NotifierViewController: NSViewController {

    var notifierModel : NotifierModel? = nil
    
    @IBOutlet var instanceURLField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        instanceURLField.placeholderString = "None"
        instanceURLField.action = #selector(doInstanceURLChanged(_:))
    }
    
    @objc func doInstanceURLChanged(_ sender: Any?){
        if let newURL = createURLFromString(urlString: instanceURLField.stringValue){
            print ("New valid URL: \(newURL.absoluteString)")
            let api = BambooAPI(instanceBaseAddress: newURL)
            api.getListOfProjects(success: {projects in
                print(projects.count)
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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        instanceURLField.stringValue = notifierModel?.bambooInstanceRootURL.absoluteString ?? ""
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

extension NotifierViewController {
    // MARK: Storyboard instantiation
    static func freshController(model : NotifierModel?) -> NotifierViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "NotifierViewController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? NotifierViewController else {
            fatalError("Check Main.storyboard for NotifierViewController")
        }
        viewcontroller.notifierModel = model
        return viewcontroller
    }
}

