//
//  FirebaseService.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let db = Database.database().reference()

    // Implement your Firebase-related methods here
    private let auth = Auth.auth()

    
    func signIn(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signUp(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        auth.createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    

    func addOrUpdateFriend(friendID: String? = nil, name: String, year: Int?, month: Int, day: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // User is not logged in
            completion(.failure(NSError(domain: "", code: 401, userInfo: nil)))
            return
        }
        
        let friendsRef = Database.database().reference().child("users").child(user.uid).child("friends")
        
        var friendData: [String: Any] = [
            "name": name,
            "month": month,
            "day": day
        ]
        
        if let year = year {
            friendData["year"] = year
        }
        
        if let friendID = friendID {
            let friendRef = friendsRef.child(friendID)
            friendRef.updateChildValues(friendData) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            let newFriendRef = friendsRef.childByAutoId()
            newFriendRef.setValue(friendData) { error, _ in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    
    func deleteFriend(friendID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // User is not logged in
            completion(.failure(NSError(domain: "", code: 401, userInfo: nil)))
            return
        }
        
        let friendsRef = Database.database().reference().child("users").child(user.uid).child("friends")
        let friendRef = friendsRef.child(friendID)
        
        friendRef.removeValue { error, _ in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }


    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    

    func getUserFriends(completion: @escaping ([Friend]) -> Void) {
        guard let userID = FirebaseService.shared.getCurrentUserID() else {
            completion([])
            return
        }
        
        let friendsRef = db.child("users").child(userID).child("friends")
        
        friendsRef.observe(.value) { (snapshot) in
            var friends: [Friend] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let friendDict = childSnapshot.value as? [String: Any],
                   let name = friendDict["name"] as? String {
                    
                    let day = friendDict["day"] as? Int
                    let month = friendDict["month"] as? Int
                    let id = childSnapshot.key
                    
                    print("friend \(friendDict)")
                    
                    if friendDict["year"] == nil {
                        friends.append(Friend(name: name, year: 0, day: day ?? 0, month: month ?? 0, fbId: id))
                    } else {
                        friends.append(Friend(name: name, year: friendDict["year"] as? Int, day: day ?? 0, month: month ?? 0, fbId: id))
                    }
                }
            }
            
            print("Successfully retrieved \(friends.count) friends.")
            completion(friends)
        }

    }

    
    // Add more methods for interacting with the Realtime Database as needed
    
    // Add more methods for working with Firebase Authentication as needed

}
