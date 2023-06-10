//
//  ViewAndEditBirthdaysView.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
    @State private var selectedSortOption: SortOption = .name

    
    enum SortOption {
        case name
        case birthday
    }
    
    var body: some View {
            NavigationView {
                VStack {
                    Picker("sort option", selection: $selectedSortOption) {
                        Text("sort by name").tag(SortOption.name)
                        Text("sort by birthday").tag(SortOption.birthday)
                    }
                    .pickerStyle(SegmentedPickerStyle()).padding()

                    List(sortedFriends, id: \.id) { friend in
                        NavigationLink(destination: AddFriendForm(editFriend: friend)) {
                            HStack {
                                Text(friend.name)
                                Spacer()
                                if let birthday = viewModel.getBirthdayString(for: friend) {
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
            return viewModel.friends.sorted { $0.name < $1.name }
        case .birthday:
            return viewModel.friends.sorted { friend1, friend2 in
                guard let birthday1 = viewModel.getBirthdayDate(for: friend1),
                      let birthday2 = viewModel.getBirthdayDate(for: friend2) else {
                    return false
                }
                return birthday1 < birthday2
            }
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
            .environmentObject(ViewAndEditBirthdaysViewModel())
    }
}

