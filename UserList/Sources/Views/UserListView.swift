import SwiftUI

// MARK: - UserListView
/// Main view that displays a list of users in grid or list format
struct UserListView: View {
    
    @ObservedObject var model: Model
    
    init(model: Model) {
        self.model = model
    }
    
    var body: some View {
        NavigationView {
            Group {
                if !model.isGridView {
                    listView
                } else {
                    gridView
                }
            }
            .navigationTitle("Users")
            .toolbar {
                toolbarContent
            }
        }
        .onAppear {
            Task {
                await model.fetchUsers()
            }
        }
    }
    
    // MARK: - Grid View
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(model.users) { user in
                    userNavigationLink(for: user) {
                        UserCell(user: user, isGridMode: true)
                    }
                    .onAppear {
                        checkAndLoadMoreData(for: user)
                    }
                }
            }
        }
    }
    
    // MARK: - List View
    private var listView: some View {
        List(model.users) { user in
            userNavigationLink(for: user) {
                UserCell(user: user, isGridMode: false)
            }
            .task {
                checkAndLoadMoreData(for: user)
            }
        }
    }
    
    // MARK: - Navigation Link
    private func userNavigationLink<Content: View>(for user: User, @ViewBuilder contentView: () -> Content) -> some View {
        NavigationLink(destination: UserDetailView(user: user)) {
            contentView()
        }
    }
    
    // MARK: - Data Loading
    /// Checks if more data should be loaded and triggers the fetch if necessary
    private func checkAndLoadMoreData(for user: User) {
        if model.shouldLoadMoreData(currentItem: user) {
            Task {
                await model.fetchUsers()
            }
        }
    }
    
    // MARK: - UI Components
    private var viewModePicker: some View {
        Picker(selection: $model.isGridView, label: Text("Display")) {
            Image(systemName: "rectangle.grid.1x2.fill")
                .tag(true)
                .accessibilityLabel(Text("Grid view"))
            Image(systemName: "list.bullet")
                .tag(false)
                .accessibilityLabel(Text("List view"))
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private var reloadButton: some View {
        Button {
            Task {
                await model.reloadUsers()
            }
        } label: {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                viewModePicker
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                reloadButton
            }
        }
    }
}

// MARK: - Previews
struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(model: Model())
    }
}


