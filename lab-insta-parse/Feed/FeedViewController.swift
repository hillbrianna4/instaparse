//
//  FeedViewController.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 11/1/22.
//

import UIKit
import ParseSwift

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private var posts = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(onPullToRefresh), for: .valueChanged)

       
        NotificationCenter.default.addObserver(
            forName: Notification.Name("login"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("Received login notification. Querying posts again.")
            self?.queryPosts()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //  Check if user exists before querying posts
        if User.current != nil {
            print("✅ User found: \(String(describing: User.current?.username))")
            queryPosts()
        } else {
            print(" User not available yet. Skipping query.")
        }
    }

    private func queryPosts(completion: (() -> Void)? = nil) {
        print("Querying posts. Current user: \(String(describing: User.current?.username))")

        let query = Post.query()
            .include("user")
            .order([.descending("createdAt")])

        query.find { [weak self] result in
            switch result {
            case .success(let posts):
                print("✅ Found \(posts.count) posts")
                self?.posts = posts
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }

            completion?()
        }
    }

    @IBAction func onLogOutTapped(_ sender: Any) {
        showConfirmLogoutAlert()
    }

    @objc private func onPullToRefresh() {
        refreshControl.beginRefreshing()
        queryPosts { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    private func showConfirmLogoutAlert() {
        let alertController = UIAlertController(
            title: "Log out of \(User.current?.username ?? "current account")?",
            message: nil,
            preferredStyle: .alert
        )

        let logOutAction = UIAlertAction(title: "Log out", style: .destructive) { _ in
            NotificationCenter.default.post(name: Notification.Name("logout"), object: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(logOutAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {}
