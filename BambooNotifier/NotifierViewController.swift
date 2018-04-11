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
            let projectResource = BambooAPIRequest<BambooProjectResource>(basePath: newURL, resource: BambooProjectResource(projectKey: nil, expandPath: nil))
            projectResource.load(success: {projects in
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
    }
    
    private func configureBrowser(){
        bambooBrowser.backgroundColor = .clear
        bambooBrowser.autohidesScroller = true
        bambooBrowser.delegate = self
        bambooBrowser.action = #selector(browserItemSelected(_:))
        bambooBrowser.target = self
    }
    
    @objc func browserItemSelected(_ sender: Any?){
        guard bambooBrowser.selectedColumn != -1 else {
            return
        }
        let selectedRow = bambooBrowser.selectedRow(inColumn: bambooBrowser.selectedColumn)
        
        switch bambooBrowser.selectedColumn {
        case 0:
            doProjectColumnSelected(selectedRow: selectedRow)
        default:
            print("Selected row # \(selectedRow) from column # \(bambooBrowser.selectedColumn)")
        }
    }
    
    private func doProjectColumnSelected(selectedRow: Int) {
        guard let selectedProject = notifierModel?.projectList[selectedRow] else {
            return
        }
        
        if selectedProject.plans != nil {
            self.notifierModel?.selectedProject = selectedProject
            self.bambooBrowser.reloadColumn(1)
            return
        }
        
        let projectResource = BambooAPIRequest<BambooProjectResource>(basePath: notifierModel!.bambooInstanceRootURL!, resource: BambooProjectResource(projectKey: selectedProject.key, expandPath: "plans.plan.branches"))
        projectResource.load(success: {projects in
            guard let project = projects?.first else {
                return
            }
            self.notifierModel?.projectList[selectedRow] = project
            self.notifierModel?.selectedProject = project
            DispatchQueue.main.async {
                self.bambooBrowser.reloadColumn(1)
            }
        }, fail: {errString in
            print(errString)
        })
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        instanceURLField.stringValue = notifierModel?.bambooInstanceRootURL?.absoluteString ?? ""
        if instanceURLField.stringValue != ""{
            instanceURLField.refusesFirstResponder = true
        }
    }
    
//     MARK: Browser View Data Source
    func rootItem(for browser: NSBrowser) -> Any? {
        return notifierModel?.projectList
    }

    func browser(_ sender: NSBrowser, willDisplayCell cell: Any, atRow row: Int, column: Int) {
        let browserCell = cell as! NSBrowserCell
        guard let projectList = notifierModel?.projectList else {
            return
        }
        switch column {
        case 0:
            browserCell.title = projectList[row].name
        case 1:
            let selectedProject = notifierModel?.selectedProject
            browserCell.title = selectedProject?.plans?[row].buildName ?? ""
        default:
            browserCell.title = "Unknown"
        }
    }

    func browser(_ sender: NSBrowser, numberOfRowsInColumn column: Int) -> Int {
        guard let model = notifierModel else{
            return 0
        }
        switch column {
        case 0:
            return model.projectList.count
        case 1:
            return model.selectedProject?.plans?.count ?? 0
        default:
            return 0
        }
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

