//
// ViewAndEditBirthdaysView.swift
// basic birthday app
//
// notes:
//

import SwiftUI

struct ListView: View {
  @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
  @State private var selectedSortOption: SortOption = .birthday

  enum SortOption {
    case name
    case birthday
  }

  var body: some View {
    NavigationView {
      VStack {
        Picker("sort option", selection: $selectedSortOption) {
          Text("sort by birthday").tag(SortOption.birthday)
          Text("sort by name").tag(SortOption.name)
        }
        .pickerStyle(SegmentedPickerStyle()).padding()

        List(sortedFriends, id: \.id) { friend in
          NavigationLink(destination: AddFriendForm(editFriend: friend)) {
            HStack {
              Text(friend.name)
              Spacer()
              if let birthday = DateUtilities.getBirthdayString(for: friend) {
                Text(birthday)
              }
            }
          }
        }
        .listStyle(.plain)
      }
    }
  }

  private var sortedFriends: [Friend] {
    switch selectedSortOption {
    case .name:
      return viewModel.friends.sorted { $0.name.lowercased() < $1.name.lowercased() }
    case .birthday:
      return viewModel.friends.sorted { friend1, friend2 in
        guard let birthday1 = DateUtilities.getBirthdayDate(for: friend1),
          let birthday2 = DateUtilities.getBirthdayDate(for: friend2)
        else {
          return false
        }
        return birthday1 < birthday2
      }
    }
  }
}
