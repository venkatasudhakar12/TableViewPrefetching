//
//  ViewController.swift
//  TableViewPrefetching
//
//  Created by Sudhakar on 27/01/20.
//  Copyright © 2020 Sudhakar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
        lazy var dataStore = PreviewDataSource()
        lazy var loadingQueue = OperationQueue()
        lazy var loadingOperations = [IndexPath : PreviewOperation]()
       @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        // Do any additional setup after loading the view.
        
    }
}
    extension ViewController: UITableViewDelegate {
        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let cell = cell as? PreviewTableViewCell else { return }
            
            // How should the operation update the cell once the data has been loaded?
            let updateCellClosure: (UIImage?) -> () = { [unowned self] (image) in
                cell.updateAppearanceFor(image)
                self.loadingOperations.removeValue(forKey: indexPath)
            }
            
            // Try to find an existing data loader
            if let dataLoader = loadingOperations[indexPath] {
                // Has the data already been loaded?
                if let image = dataLoader.image {
                    cell.updateAppearanceFor(image)
                    loadingOperations.removeValue(forKey: indexPath)
                } else {
                    // No data loaded yet, so add the completion closure to update the cell once the data arrives
                    dataLoader.loadingCompletionHandle = updateCellClosure
                }
            } else {
                // Need to create a data loaded for this index path
                if let dataLoader = dataStore.loadPreview(at: indexPath.row) {
                    // Provide the completion closure, and kick off the loading operation
                    dataLoader.loadingCompletionHandle = updateCellClosure
                    loadingQueue.addOperation(dataLoader)
                    loadingOperations[indexPath] = dataLoader
                }
            }
        }
        
        public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            // If there's a data loader for this index path we don't need it any more. Cancel and dispose
            if let dataLoader = loadingOperations[indexPath] {
                dataLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }

    // MARK:- TableView Datasource
    extension ViewController: UITableViewDataSource {
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataStore.numberOfPrevies
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell") as? PreviewTableViewCell else {
                fatalError("Sorry, could not load cell")
            }
            cell.updateAppearanceFor(.none)
            return cell
        }
    }

    // MARK:- TableView Prefetching DataSource
    extension ViewController: UITableViewDataSourcePrefetching {
        public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
            for indexPath in indexPaths {
                if let _ = loadingOperations[indexPath] { return }
                if let dataLoader = dataStore.loadPreview(at: indexPath.row) {
                    loadingQueue.addOperation(dataLoader)
                    loadingOperations[indexPath] = dataLoader
                }
            }
        }
        
        public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
            for indexPath in indexPaths {
                if let dataLoader = loadingOperations[indexPath] {
                    dataLoader.cancel()
                    loadingOperations.removeValue(forKey: indexPath)
                }
            }
        }
    }



