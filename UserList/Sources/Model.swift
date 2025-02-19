//
//  Model.swift
//  UserList
//
//  Created by Julien Choromanski on 19/02/25.
//

import Foundation

class Model: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var isGridView = false
    
    private let repository: UserListRepository
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    init(repository: UserListRepository = UserListRepository()) {
        self.repository = repository
        print("initialisation du model")
    }

    @MainActor
    func fetchUsers() async {
        guard !isLoading else { return }
        
        isLoading = true
        do {
            let newUsers = try await repository.fetchUsers(quantity: 20)
            self.users.append(contentsOf: newUsers)
            self.isLoading = false
        } catch {
            self.isLoading = false
            print("Error fetching users: \(error.localizedDescription)")
        }
    }

    func shouldLoadMoreData(currentItem item: User) -> Bool {
        guard let lastItem = users.last else { return false }
        return !isLoading && item.id == lastItem.id
    }

    @MainActor
    func reloadUsers() async {
        users.removeAll()
        await fetchUsers()
    }
    
    func formatDate(_ dateString: String) -> String {
        guard let date = ISO8601DateFormatter().date(from: dateString) else {
            return dateString
        }
        return dateFormatter.string(from: date)
    }
}
