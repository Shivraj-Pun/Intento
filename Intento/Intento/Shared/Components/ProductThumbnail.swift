import SwiftUI

struct ProductThumbnail: View {
    let category: ProductCategory
    var size: CGFloat = 46

    var body: some View {
        RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
            .fill(AppColor.Primary.s100)
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: category.iconName)
                    .font(.system(size: size * 0.42))
                    .foregroundStyle(AppColor.Primary.s700)
            )
    }
}
