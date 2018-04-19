//
//  NotifierViewController
//  BambooNotifier
//
//  Created by Adam Koziol on 1/18/18.
//  Copyright © 2018 Adam Koziol. All rights reserved.
//

import Cocoa

class NotifierViewController: NSViewController, NSBrowserDelegate {
    private let subscribeText = "Subscribe"
    private let unsubscribeText = "Unsubscribe"
    
    var notifierModel : NotifierModel? = nil
    
    @IBOutlet var instanceURLField: NSTextField!
    @IBOutlet var bambooBrowser: NSBrowser!
    @IBOutlet var subscribeButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureInstanceURLField()
        configureBrowser()
        bindToSelectedBranch()
        configureSubscribeButton()
    }
    
    override func viewWillDisappear() {
        notifierModel?.removeObserver(self, forKeyPath: #keyPath(NotifierModel.selectedPlanBranch))
        notifierModel?.removeObserver(self, forKeyPath: #keyPath(NotifierModel.selectedPlan))
    }
    
    @objc func doInstanceURLChanged(_ sender: Any?){
        if let newURL = createURLFromString(urlString: instanceURLField.stringValue){
            if (notifierModel!.bambooInstanceRootURL != newURL){
                notifierModel!.bambooInstanceRootURL = newURL
            }
            
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
    
    private func bindToSelectedBranch() {
        notifierModel?.addObserver(self, forKeyPath: #keyPath(NotifierModel.selectedPlanBranch), options: .new, context: nil)
        notifierModel?.addObserver(self, forKeyPath: #keyPath(NotifierModel.selectedPlan), options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(NotifierModel.selectedPlanBranch):
            handleSelectedPlanChanged()
        case #keyPath(NotifierModel.selectedPlan):
            handleSelectedPlanChanged()
        default:
            return
        }
    }
    
    private func handleSelectedPlanChanged(){
        guard let model = notifierModel else {
            return
        }
        
        var hidden = false
        var subscribed = false
        
        if let currentSubscribable = model.currentlySelectedSubscribable{
            subscribed = IsAlreadySubscribed(model: model, subscribable: currentSubscribable)
        } else{
            hidden = true
        }
        
//        if let selectedBranch = model.selectedPlanBranch{
//            subscribed = IsAlreadySubscribed(model: model, subscribable: selectedBranch)
//        } else if let selectedPlan = model.selectedPlan {
//            subscribed = IsAlreadySubscribed(model: model, subscribable: selectedPlan)
//        } else {
//            hidden = true
//        }
        print("subscribe button is hidden: \(hidden)")
        DispatchQueue.main.async {
            if (subscribed){
                self.subscribeButton.title = self.unsubscribeText
            } else {
                self.subscribeButton.title = self.subscribeText
            }
            self.subscribeButton.isHidden = hidden
            
        }
    }
    
    private func IsAlreadySubscribed(model: NotifierModel, subscribable : ISubscribable) -> Bool {
        return model.subscriptions.contains(where: {
            subscription in
            if subscription == subscribable.key {
                return true
            }
            return false
        })
    }
    
    private func configureSubscribeButton() {
        subscribeButton.isHidden = true
        subscribeButton.action = #selector(subscribeButtonPressed(_:))
    }
    
    @objc func subscribeButtonPressed(_ sender: Any?){
        guard let selectedSubscribable = notifierModel?.currentlySelectedSubscribable else {
            return
        }
        if (subscribeButton.title == self.subscribeText){
            notifierModel?.addSubscription(subscribable: selectedSubscribable)
            print("now subscribing to \(selectedSubscribable.key)")
        } else {
            notifierModel?.removeSubscription(subscribable: selectedSubscribable)
            print("unsubscribed to \(selectedSubscribable.key)")
        }
        handleSelectedPlanChanged()
    }
    
    @objc func browserItemSelected(_ sender: Any?){
        guard bambooBrowser.selectedColumn != -1 else {
            return
        }
        
        let selectedRow = bambooBrowser.selectedRow(inColumn: bambooBrowser.selectedColumn)
        switch bambooBrowser.selectedColumn {
        case 0:
            doProjectColumnSelected(selectedRow: selectedRow)
        case 1:
            doPlanColumnSelected(selectedRow: selectedRow)
        case 2:
            doBranchColumnSelected(selectedRow: selectedRow)
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
        
        let projectResource = BambooAPIRequest<BambooProjectResource>(basePath: notifierModel!.bambooInstanceRootURL!, resource: BambooProjectResource(projectKey: selectedProject.key, expandPath: "plans.plan.branches.branch"))
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
    
    private func doPlanColumnSelected(selectedRow: Int){
        guard let selectedPlan = notifierModel?.selectedProject?.plans?[selectedRow] else{
            return
        }
        
        if selectedPlan.branches != nil {
            self.notifierModel?.selectedPlan = selectedPlan
            self.bambooBrowser.reloadColumn(2)
            return
        }
    }
    
    private func doBranchColumnSelected(selectedRow: Int){
        guard let selectedBranch = notifierModel?.selectedPlan?.branches?[selectedRow] else{
            return
        }
        notifierModel?.selectedPlanBranch = selectedBranch
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
        guard let model = notifierModel else {
            return
        }
        guard let projectList = notifierModel?.projectList else {
            return
        }
        switch column {
        case 0:
            let modelItem = projectList[row]
            browserCell.title = modelItem.name
        case 1:
            let selectedProject = model.selectedProject
            let modelItem = selectedProject?.plans?[row]
            browserCell.title = modelItem?.buildName ?? "No plan name"
            browserCell.isLeaf = (modelItem?.branches?.count ?? 0) == 0
        case 2:
            let selectedPlan = model.selectedPlan
            browserCell.title = selectedPlan?.branches?[row].shortName ?? "No branch name"
            browserCell.isLeaf = true
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
        case 2:
            return model.selectedPlan?.branches?.count ?? 0
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

