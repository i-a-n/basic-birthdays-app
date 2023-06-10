//
//  ViewAndEditBirthdaysView.swift
//  dead simple birthdays
//
//  Created by ian on 6/3/23.
//

import SwiftUI

struct ViewAndEditBirthdaysView: View {
    @EnvironmentObject var viewModel: ViewAndEditBirthdaysViewModel
    @State private var selectedSortOption: SortOption = .name

    
    enum SortOption {
        case name
        case birthday
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Sort Option", selection: $selectedSortOption) {
                    Text("Sort by Name").tag(SortOption.name)
                    Text("Sort by Birthday").tag(SortOption.birthday)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                
                List(viewModel.friends, id: \.id) { friend in
                    HStack {
                        Text(friend.name)
                        
                        Spacer()
                        
                        if let birthday = viewModel.getBirthdayString(for: friend) {
                            Text(birthday)
                        }
                    }
                }
            }
            .navigationTitle("Friends")
        }
        .onAppear {
            viewModel.loadFriends()
        }
    }
}

struct ViewAndEditBirthdaysView_Previews: PreviewProvider {
    static var previews: some View {
        ViewAndEditBirthdaysView()
            .environmentObject(ViewAndEditBirthdaysViewModel())
    }
}

