import Foundation

class ViewAndEditBirthdaysViewModel: ObservableObject {
    @Published var friends: [Friend] = []
    
    func loadFriends() {
        FirebaseService.shared.getUserFriends { [weak self] friends in
            DispatchQueue.main.async {
                self?.friends = friends
            }
        }
    }
    
    func addOrUpdateFriend(friendID: String? = nil, name: String, year: Int?, month: Int, day: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        
        FirebaseService.shared.addOrUpdateFriend(friendID: friendID, name: name, year: year, month: month, day: day, completion: completion)
    }
    
    func deleteFriend(friendID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        FirebaseService.shared.deleteFriend(friendID: friendID, completion: completion)
    }
    
    func getBirthdayDate(for friend: Friend) -> Date? {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = friend.month
        components.day = friend.day
        
//        if let year = friend.year {
//            components.year = year
//        }
        
        return calendar.date(from: components)
    }

    
    func getBirthdayString(for friend: Friend) -> String? {
        let day = friend.day
        let month = friend.month

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = month
        components.day = day
        
        if let year = friend.year {
            components.year = year
        }
        
        if let date = calendar.date(from: components) {
            let dateString = dateFormatter.string(from: date)
            return dateString.lowercased()
            
        } else {
            print("viewandeditviewmodel: Failed to create date from components: \(components)")
            return nil
        }
    }

    
    // Other ViewAndEditBirthdaysViewModel methods...
}
