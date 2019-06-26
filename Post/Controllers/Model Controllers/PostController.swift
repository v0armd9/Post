//
//  PostController.swift
//  Post
//
//  Created by Darin Marcus Armstrong on 6/24/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

class PostController {
    
    static let sharedInstance = PostController()
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.timestamp ?? Date().timeIntervalSince1970
        guard let url = baseURL else {completion(); return}
        let urlParameters = [ "orderBy": "\"timestamp\"", "endAt": "\(queryEndInterval)", "limitToLast": "15", ]
        var urlCompenents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        urlCompenents?.queryItems = queryItems
        guard let newUrl = urlCompenents?.url else {completion(); return}
        let getterEndpoint = newUrl.appendingPathExtension("json")
        var urlRequest = URLRequest(url: getterEndpoint)
        urlRequest.httpBody = nil
        urlRequest.httpMethod = "GET"
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            do {
                guard let data = data else {completion(); return}
                let jsDecoder = JSONDecoder()
                let postsDictionary = try jsDecoder.decode([String:Post].self, from: data)
                var posts = postsDictionary.compactMap({$0.value})
                posts.sort(by: {$0.timestamp > $1.timestamp})
                if reset {
                    self.posts = posts
                } else {
                    self.posts.append(posts[0])
                }
                completion(); return
            } catch {
                print(error)
                completion(); return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username:String, text: String, completion: @escaping() -> Void) {
        let post = Post(text: text, username: username)
        var postData: Data
        let jsEncoder = JSONEncoder()
        do{
            let encodedData = try jsEncoder.encode(post)
            postData = encodedData
            if let baseURL = baseURL {
                let postEndpoint = baseURL.appendingPathExtension("json")
                var urlRequest = URLRequest(url: postEndpoint)
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = postData
                let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
                    if let error = error {
                        print(error)
                        completion(); return
                    }
                    if let data = data {
                        print(String(data: data, encoding: .utf8)!)
                        self.fetchPosts {
                            completion(); return
                        }
                    }
                }
                dataTask.resume()
            }
        } catch {
            print(error)
            completion(); return
        }
    }
}
