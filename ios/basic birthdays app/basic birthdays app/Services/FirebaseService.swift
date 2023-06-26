//
// FirebaseService.swift
// basic birthday app
//
// notes: this file was suggested to me somewhere along the way and it's grown into the only
// place in the app where we talk to firebase. however, the
// ../ViewModels/ViewAndEditBirthdaysViewModel.swift file seemingly calls most of these and
// sometimes adds nearly nothing, so you might argue that the architecture of how we call
// firebase is not optimal in this app. sorry.
//

import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseMessaging
import Foundation

class FirebaseService: ObservableObject {
  static let shared = FirebaseService()  // this is used in other files I think
  private let db = Database.database().reference()

  // a few auth methods, these were all copied and pasted from firebase documentation
  private let auth = Auth.auth()

  func signIn(
    email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void
  ) {
    auth.signIn(withEmail: email, password: password, completion: completion)
  }

  func signUp(
    email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void
  ) {
    auth.createUser(withEmail: email, password: password, completion: completion)
  }

  func signOut() throws {
    try auth.signOut()
  }


  func deleteUser(completion: @escaping (Result<Void, Error>) -> Void) {
      deleteAllUserData { result in
          switch result {
          case .success:
              Auth.auth().currentUser?.delete { error in
                  if let error = error {
                      completion(.failure(error))
                  } else {
                      completion(.success(()))
                  }
              }
          case .failure(let error):
              completion(.failure(error))
          }
      }
  }

  
  func getCurrentUserID() -> String? {
    return Auth.auth().currentUser?.uid
  }

  // given a deviceToken, this function will search the user's firebase object for the
  // same token. if it's found, it will refresh the timestamp there. if it's not found,
  // it'll make a new object for this token. we should prune old tokens periodically.
  func setDeviceToken(token: String) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      print("Failed to set device token because user wasn't logged in, weirdly")
      return
    }

    let usersRef = db.child("users")
    let userRef = usersRef.child(user.uid)

    let timestamp = Date().timeIntervalSince1970

    let deviceTokensRef = userRef.child("deviceTokens")

    // Check if the token already exists
    deviceTokensRef.queryOrdered(byChild: "token").queryEqual(toValue: token).observeSingleEvent(
      of: .value
    ) { snapshot in
      if snapshot.exists() {
        for case let tokenSnapshot as DataSnapshot in snapshot.children {
          let tokenRef = deviceTokensRef.child(tokenSnapshot.key)
          tokenRef.child("timestamp").setValue(timestamp)
        }
      } else {
        let newTokenRef = deviceTokensRef.childByAutoId()
        let tokenData: [String: Any] = [
          "token": token,
          "timestamp": timestamp,
        ]
        newTokenRef.setValue(tokenData)
      }
    }
  }

  // this will set `notificationEnabled` for the user's device, either `true` or `false`.
  // it will fail if it can't find the current `deviceToken` within the user's deviceTokens.
  func setNotificationEnabled(isEnabled: Bool, completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      print("Failed to set notifications because user wasn't logged in, weirdly")
      return
    }

    // note that we get the deviceToken via `Messaging.messaging().fcmToken`, which is a
    // poorly-documented method that I found myself. it seems to work but if we start
    // seeing buginess around setting `notificationEnabled`, this is one potential source of
    // concern.
    guard let deviceToken = Messaging.messaging().fcmToken else {
      // Device token is not available
      print("Failed to set notifications because device token is not available")
      return
    }

    let usersRef = db.child("users")
    let userRef = usersRef.child(user.uid)
    let deviceTokensRef = userRef.child("deviceTokens")

    deviceTokensRef.queryOrdered(byChild: "token")
      .queryEqual(toValue: deviceToken)
      .observeSingleEvent(of: .value) { snapshot in
        if let deviceTokenSnapshot = snapshot.children.allObjects.first as? DataSnapshot {
          // Found the matching device token
          let deviceTokenId = deviceTokenSnapshot.key
          let deviceTokenRef = deviceTokensRef.child(deviceTokenId)
          deviceTokenRef.child("notificationEnabled").setValue(isEnabled) { error, _ in
            if let error = error {
              print("Failed to set notificationEnabled value: \(error.localizedDescription)")
              completion(false)
            } else {
              print("notificationEnabled value set successfully for device token: \(deviceTokenId)")
              completion(true)
            }
          }
        } else {
          // Device token not found
          print("Failed to find device token in the database")
          completion(false)
        }
      }
  }

  func addOrUpdateFriend(
    friendID: String? = nil, name: String, year: Int?, month: Int, day: Int,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      completion(.failure(NSError(domain: "", code: 401, userInfo: nil)))
      return
    }

    let friendsRef = db.child("users").child(user.uid).child("friends")

    var friendData: [String: Any] = [
      "name": name,
      "month": month,
      "day": day,
    ]

    if let year = year {
      friendData["year"] = year
    }

    // whether friendID was passed in determines whether we're updating or creating
    if let friendID = friendID {
      // update existing friend
      let friendRef = friendsRef.child(friendID)
      friendRef.updateChildValues(friendData) { error, _ in
        if let error = error {
          completion(.failure(error))
        } else {
          completion(.success(()))
        }
      }
    } else {
      // create new friend
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
  
  func deleteAllUserData(completion: @escaping (Result<Void, Error>) -> Void) {
      guard let user = Auth.auth().currentUser else {
          // User is not logged in
          completion(.failure(NSError(domain: "", code: 401, userInfo: nil)))
          return
      }

      let userRef = db.child("users").child(user.uid)
      
      userRef.observeSingleEvent(of: .value) { snapshot in
          guard snapshot.exists() else {
              // User object doesn't exist
              completion(.failure(NSError(domain: "", code: 404, userInfo: nil)))
              return
          }
          
          let children = snapshot.children.allObjects
          
          for child in children {
              if let childSnapshot = child as? DataSnapshot {
                  let childRef = userRef.child(childSnapshot.key)
                  childRef.removeValue()
              }
          }
          
          completion(.success(()))
      }
  }


  func deleteFriend(friendID: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      completion(.failure(NSError(domain: "", code: 401, userInfo: nil)))
      return
    }

    let friendsRef = db.child("users").child(user.uid).child("friends")
    let friendRef = friendsRef.child(friendID)

    friendRef.removeValue { error, _ in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(()))
      }
    }
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
          let name = friendDict["name"] as? String
        {

          let day = friendDict["day"] as? Int
          let month = friendDict["month"] as? Int
          let id = childSnapshot.key

          let year = friendDict["year"] as? Int ?? 0
          friends.append(Friend(name: name, year: year, day: day ?? 0, month: month ?? 0, fbId: id))

        }
      }

      completion(friends)
    }

  }

}
