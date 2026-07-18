import SwiftUI

struct AppHomeView: View {
    let container: AppContainer
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var searchResults: [Product] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?

    let columns = [
        GridItem(.flexible(), spacing: AppSpacing.md),
        GridItem(.flexible(), spacing: AppSpacing.md)
    ]

    private var isShowingSearch: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                MissionInputBar(text: $searchText, placeholder: "Search items...")
                    .padding(.horizontal, Theme.screenPadding)
                    .padding(.top, AppSpacing.sm)

                if isShowingSearch {
                    searchResultsView
                } else {
                    categoriesView
                }
            }
            .padding(.bottom, AppSpacing.lg)
        }
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .navigationTitle("Intento")
        .onChange(of: searchText) { _, newValue in
            performSearch(query: newValue)
        }
    }

    // MARK: - Search Results

    @ViewBuilder
    private var searchResultsView: some View {
        if isSearching {
            HStack {
                Spacer()
                ProgressView()
                    .padding(.top, AppSpacing.xl)
                Spacer()
            }
        } else if searchResults.isEmpty {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(AppColor.Semantic.textTertiary)
                Text("No results for \"\(searchText)\"")
                    .textStyle(.bodyMRegular)
                    .foregroundColor(AppColor.Semantic.textSecondary)
            }
            .padding(.top, AppSpacing.xxl)
        } else {
            LazyVStack(spacing: 0) {
                ForEach(searchResults) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        HStack(spacing: AppSpacing.md) {
                            ProductThumbnail(category: product.category, size: 44)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.displayTitle)
                                    .textStyle(.bodyMMedium)
                                    .foregroundColor(AppColor.Semantic.textPrimary)
                                    .lineLimit(1)
                                Text(product.packSize.displayLabel)
                                    .textStyle(.caption)
                                    .foregroundColor(AppColor.Semantic.textTertiary)
                            }
                            Spacer()
                            Text(product.price.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                                .textStyle(.bodyMMedium)
                                .foregroundColor(AppColor.Semantic.textPrimary)
                        }
                        .padding(.vertical, AppSpacing.sm)
                        .padding(.horizontal, Theme.screenPadding)
                    }
                    Divider()
                        .padding(.leading, Theme.screenPadding + 44 + AppSpacing.md)
                }
            }
        }
    }

    // MARK: - Categories

    private var categoriesView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Shop by Category")
                .font(.title2.bold())
                .foregroundColor(AppColor.Semantic.textPrimary)
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, AppSpacing.sm)
            
            // Categories
            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(ProductCategory.allCases) { category in
                    NavigationLink(destination: CategoryItemsView(container: container, category: category)) {
                        ZStack(alignment: .bottom) {
                            // Background Image
                            if let assetName = category.assetName {
                                Image(assetName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else if let url = category.imageURL {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.3))
                                }
                            } else {
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                            
                            // Gradient overlay for text readability
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            
                            // Category Title
                            Text(category.displayName)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(AppSpacing.md)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .appShadow(AppShadow.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.screenPadding)
        }
    }

    // MARK: - Search Logic

    private func performSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            searchResults = []
            isSearching = false
            return
        }

        isSearching = true
        searchTask = Task {
            // Debounce: wait a short moment before searching
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            let results = (try? await container.catalog.search(trimmed)) ?? []
            guard !Task.isCancelled else { return }

            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        }
    }
}
