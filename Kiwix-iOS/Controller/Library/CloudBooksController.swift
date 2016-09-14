//
//  CloudBooksController.swift
//  Kiwix
//
//  Created by Chris Li on 8/17/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import CoreData

class CloudBooksController: UITableViewController, NSFetchedResultsControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        tabBarItem.title = "Cloud"
        tabBarItem.image = UIImage(named: "Cloud")
        tabBarItem.selectedImage = UIImage(named: "CloudFilled")
        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add)
        clearsSelectionOnViewWillAppear = true
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else {return}
        switch identifier {
        case "ShowBookDetail":
            guard let navController = segue.destinationViewController as? UINavigationController,
                let bookDetailController = navController.topViewController as? BookDetailController,
                let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPathForCell(cell),
                let book = fetchedResultController.objectAtIndexPath(indexPath) as? Book else {return}
            bookDetailController.book = book
        default:
            break
        }
    }
    
    // MARK: - TableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultController.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let book = fetchedResultController.objectAtIndexPath(indexPath) as? Book else {return}
        guard let cell = cell as? BasicBookCell else {return}
        
        cell.titleLabel.text = book.title
        cell.hasPic = book.hasPic
        cell.hasIndex = false
        cell.favIcon.image = UIImage(data: book.favIcon ?? NSData())
        cell.subtitleLabel.text = book.detailedDescription
    }
    
    // MARK: Other Data Source
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard tableView.numberOfSections > 1 else {return nil}
        guard let languageName = fetchedResultController.sections?[section].name else {return nil}
        return languageName
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let sectionIndexTitles = fetchedResultController.sectionIndexTitles
        guard sectionIndexTitles.count > 2 else {return nil}
        return sectionIndexTitles
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultController.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView.numberOfSections > 1 else {return 0.0}
        guard let headerText = self.tableView(tableView, titleForHeaderInSection: section) else {return 0.0}
        guard headerText != "" else {return 0.0}
        return 20.0
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.font = UIFont.boldSystemFontOfSize(14)
    }
    
    // MARK: - Fetched Results Controller
    
    let managedObjectContext = UIApplication.appDelegate.managedObjectContext
    lazy var fetchedResultController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Book")
        let langDescriptor = NSSortDescriptor(key: "language.name", ascending: true)
        let titleDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [langDescriptor, titleDescriptor]
        fetchRequest.predicate = self.onlineCompoundPredicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "language.name", cacheName: "OnlineFRC")
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(deleteCache: false)
        return fetchedResultsController
    }()
    
    func refreshFetchedResultController() {
        fetchedResultController.fetchRequest.predicate = onlineCompoundPredicate
        fetchedResultController.performFetch(deleteCache: true)
        tableView.reloadData()
//        configureMessage()
    }
    
    private var langPredicate: NSPredicate {
        let displayedLanguages = Language.fetch(displayed: true, context: managedObjectContext)
        if displayedLanguages.count > 0 {
            return NSPredicate(format: "language IN %@", displayedLanguages)
        } else {
            return NSPredicate(format: "language.name != nil")
        }
    }
    
    private var onlineCompoundPredicate: NSCompoundPredicate {
        let isCloudPredicate = NSPredicate(format: "isLocal == false")
        return NSCompoundPredicate(andPredicateWithSubpredicates: [langPredicate, isCloudPredicate])
    }
    
    // MARK: - Fetched Result Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        case .Delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Update:
            guard let indexPath = indexPath, let cell = tableView.cellForRowAtIndexPath(indexPath) else {return}
            configureCell(cell, atIndexPath: indexPath)
        case .Move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else {return}
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
//        configureMessage()
    }
}
