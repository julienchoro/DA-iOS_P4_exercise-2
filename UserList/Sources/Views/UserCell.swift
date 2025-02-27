import SwiftUI

// MARK: - UserCell
/// Displays user information in either grid or list format
struct UserCell: View {
    let user: User
    let isGridMode: Bool
    
    var body: some View {
        if isGridMode {
            gridCell
        } else {
            listCell
        }
    }
    
    // MARK: - Grid Cell
    /// Layout for grid display mode
    private var gridCell: some View {
        VStack {
            UserImageView(url: user.picture.medium, size: 150)
            
            Text("\(user.name.first) \(user.name.last)")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - List Cell
    /// Layout for list display mode
    private var listCell: some View {
        HStack {
            UserImageView(url: user.picture.thumbnail, size: 50)
            
            VStack(alignment: .leading) {
                Text("\(user.name.first) \(user.name.last)")
                    .font(.headline)
                Text("\(user.dob.date)")
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - UserImageView
/// Displays user profile images with loading placeholder
struct UserImageView: View {
    let url: String
    let size: CGFloat
    
    var body: some View {
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
}