//
//  PostListTableViewController.swift
//  Post
//
//  Created by Darin Marcus Armstrong on 6/24/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController {

    var postController = PostController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postController.fetchPosts {
            self.reloadTableView()
        }
        self.tableView.estimatedRowHeight = 45
        self.tableView.rowHeight = UITableView.automaticDimension
    }

    @IBAction func refreshPulled(_ sender: Any) {
        postController.fetchPosts {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            self.reloadTableView()
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]

        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(post.username) \(post.timestamp)"

        return cell
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
