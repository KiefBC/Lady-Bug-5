import SwiftUI

struct RowView: View {
    @Binding var ladybug: Ladybug

    var body: some View {
        HStack {
            if let image = ladybug.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } else {
                Image(systemName: "ladybug.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
            }

            TextField("Name", text: $ladybug.name)

            Spacer()
        }
    }
}
