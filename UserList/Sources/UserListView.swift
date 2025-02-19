import SwiftUI

struct UserListView: View {
    
    @EnvironmentObject var model: Model
    
    var body: some View {
        NavigationView {
            if !model.isGridView {
                listView
                .navigationTitle("Users")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        viewModePicker
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        reloadButton
                    }
                }
            } else {
                gridView
                .navigationTitle("Users")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        viewModePicker
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        reloadButton
                    }
                }
            }
        }
        .onAppear {
            Task {
                await model.fetchUsers()
            }
        }
    }
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(model.users) { user in
                    NavigationLink(destination: UserDetailView(user: user)) {
                        VStack {
                            userImage(url: user.picture.medium, size: 150)

                            Text("\(user.name.first) \(user.name.last)")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .onAppear {
                        if model.shouldLoadMoreData(currentItem: user) {
                            Task {
                                await model.fetchUsers()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var listView: some View {
        List(model.users) { user in
            NavigationLink(destination: UserDetailView(user: user)) {
                HStack {
                    userImage(url: user.picture.thumbnail, size: 50)
                    
                    VStack(alignment: .leading) {
                        Text("\(user.name.first) \(user.name.last)")
                            .font(.headline)
                        Text("\(user.dob.date)")
                            .font(.subheadline)
                    }
                }
            }
            .task {
                if model.shouldLoadMoreData(currentItem: user) {
                    await model.fetchUsers()
                }
            }
        }
    }
    
    private func userImage(url: String, size: CGFloat) -> some View {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            ProgressView()
                .frame(width: size, height: size)
                .clipShape(Circle())
        }
    }
    
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
    
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
            .environmentObject(Model())
    }
}


