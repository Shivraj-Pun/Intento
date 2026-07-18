import SwiftUI

struct AppHomeView: View {
    let container: AppContainer
    @Binding var selectedTab: Int
    @State private var searchText = ""

    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
            
                // Search Bar
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColor.Semantic.textSecondary)
                    TextField("Search items...", text: $searchText)
                        .textStyle(.bodyMRegular)
                        .foregroundColor(AppColor.Semantic.textPrimary)
                    
                    Button {
                        // Mic action placeholder
                    } label: {
                        Image(systemName: "mic.fill")
                            .font(.title3)
                            .foregroundColor(AppColor.Semantic.brandStrong)
                    }
                    .buttonStyle(.plain)
                }
                .padding(AppSpacing.md)
                .background(AppColor.Semantic.surface)
                .cornerRadius(25)
                .appShadow(AppShadow.xs)
                .padding(.horizontal, Theme.screenPadding)

                
                Button {
                    selectedTab = 0
                } label: {
                    HStack {
                        Text("Have a goal instead? Ask Intento")
                        Image(systemName: "arrow.right")
                    }
                    .textStyle(.bodySMedium)
                    .foregroundColor(AppColor.Semantic.brandStrong)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(AppColor.Semantic.brandStrong.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(.top, AppSpacing.sm)
                // Categories
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(ProductCategory.allCases) { category in
                        NavigationLink(destination: CategoryItemsView(container: container, category: category)) {
                            VStack(spacing: AppSpacing.sm) {
                                Image(systemName: category.iconName)
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColor.Semantic.brandStrong)
                                Text(category.displayName)
                                    .textStyle(.bodySMedium)
                                    .foregroundColor(AppColor.Semantic.textPrimary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(AppColor.Semantic.surface)
                            .cornerRadius(25)
                            .appShadow(AppShadow.xs)
                        }
                    }
                }
                .padding(.horizontal, Theme.screenPadding)
            }
            .padding(.bottom, AppSpacing.lg)
        }
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .navigationTitle("Intento")
    }
}
