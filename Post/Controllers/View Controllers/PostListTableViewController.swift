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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]

        cell.textLabel?.text = post.text
        
        let date = Date(timeIntervalSince1970: post.timestamp)
        cell.detailTextLabel?.text = "\(post.username) \(date.stringValue())"

        return cell
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
        }
    }
}

extension PostListTableViewController {
    func presentNewPostAlert() {
        let addAlert = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        addAlert.addTextField { (textfield) in
            textfield.placeholder = "Enter Username..."
        }
        addAlert.addTextField { (textfield) in
            textfield.placeholder = "Enter message here..."
        }
        addAlert.addAction(UIAlertAction(title: "Post", style: .default, handler: { [weak addAlert] (_) in
            guard let textField = addAlert?.textFields?[0], let usernameText = textField.text else {return}
            guard let textField2 = addAlert?.textFields?[1], let messageText = textField2.text else {return}
            PostController.sharedInstance.addNewPostWith(username: usernameText, text: messageText, completion: {
            })
        }))
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(addAlert, animated: true, completion: nil)
    }
}

extension PostListTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts {
                DispatchQueue.main.async {
                    tableView.reloadData()
                }
            }
        }
    }
}
