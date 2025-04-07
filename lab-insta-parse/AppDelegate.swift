//
//  AppDelegate.swift
//  lab-insta-parse
//
//  Created by Charlie Hieger on 10/29/22.
//

import UIKit
import ParseSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Parse SDK
        ParseSwift.initialize(applicationId: "Mymf4QIG47UoKDhpe8MEHvZ2oTJ7G09pZE7bOPQp",
                              clientKey: "YDonZLoK4CiVoRdc4nvJ4Fv84JZcwpU9Yl9gon07",
                              serverURL: URL(string: "https://parseapi.back4app.com")!) // Make sure it's a full URL
        
        // Create and save a GameScore object
        var score = GameScore()
        score.playerName = "Kingsley"
        score.points = 13
        
        score.save { result in
            switch result {
            case .success(let savedScore):
                print("✅ Saved! Player: \(savedScore.playerName ?? ""), Score: \(savedScore.points ?? 0)")
            case .failure(let error):
                print("❌ Error saving: \(error)")
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

// MARK: - GameScore Parse Object
struct GameScore: ParseObject {
    // Required by ParseObject
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?

    // Custom fields
    var playerName: String?
    var points: Int?
}

// Optional: Add a convenience initializer in an extension
extension GameScore {
    init(playerName: String, points: Int) {
        self.playerName = playerName
        self.points = points
    }
}
