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

  // I do not believe this is used anywhere at current
  func signOut() throws {
    try auth.signOut()
  }

  func getCurrentUserID() -> String? {
    return Auth.auth().currentUser?.uid
  }

  // This takes the device token and just sets it in a `deviceToken` key within the user's
  // userID object in firebase
  func setDeviceToken(token: String) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      print("Failed to set device token because user wasn't logged in, weirdly")
      return
    }

    let usersRef = db.child("users")
    let userRef = usersRef.child(user.uid)

    userRef.child("deviceToken").setValue(token) { error, _ in
      if let error = error {
        print("Failed to set device token: \(error.localizedDescription)")
      } else {
        print("Device token set successfully for user: \(token)")
      }
    }
  }

  func setNotificationEnabled(isEnabled: Bool, completion: @escaping (Bool) -> Void) {
    guard let user = Auth.auth().currentUser else {
      // User is not logged in
      print("Failed to set notifications because user wasn't logged in, weirdly")
      return
    }

    let usersRef = db.child("users")
    let userRef = usersRef.child(user.uid)

    userRef.child("notificationEnabled").setValue(isEnabled) { error, _ in
      if let error = error {
        print("Failed to set notificationEnabled value: \(error.localizedDescription)")
        completion(false)
      } else {
        print("notificationEnabled value set successfully for user: \(user.uid)")
        completion(true)
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

  func getMonthName(month: Int) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter.monthSymbols[month - 1].lowercased()
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
