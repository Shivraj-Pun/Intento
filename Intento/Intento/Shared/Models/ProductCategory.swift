import Foundation

enum ProductCategory: String, Codable, CaseIterable, Hashable, Sendable, Identifiable {
    case produce
    case dairy
    case meat
    case bakery
    case pantry
    case snacks
    case beverages
    case cleaning
    case partySupplies = "party_supplies"
    case baby
    case firstAid = "first_aid"
    case personalCare = "personal_care"
    case frozen
    case household

    nonisolated var id: String { rawValue }

    nonisolated var displayName: String {
        switch self {
        case .produce: "Fruits & Vegetables"
        case .dairy: "Dairy & Eggs"
        case .meat: "Meat & Seafood"
        case .bakery: "Bakery"
        case .pantry: "Pantry & Staples"
        case .snacks: "Snacks"
        case .beverages: "Beverages"
        case .cleaning: "Cleaning"
        case .partySupplies: "Party Supplies"
        case .baby: "Baby Care"
        case .firstAid: "First Aid"
        case .personalCare: "Personal Care"
        case .frozen: "Frozen"
        case .household: "Household"
        }
    }

    nonisolated var iconName: String {
        switch self {
        case .produce: "carrot.fill"
        case .dairy: "shippingbox.fill"
        case .meat: "fish.fill"
        case .bakery: "birthday.cake.fill"
        case .pantry: "bag.fill"
        case .snacks: "popcorn.fill"
        case .beverages: "cup.and.saucer.fill"
        case .cleaning: "bubbles.and.sparkles.fill"
        case .partySupplies: "party.popper.fill"
        case .baby: "figure.and.child.holdinghands"
        case .firstAid: "cross.case.fill"
        case .personalCare: "comb.fill"
        case .frozen: "snowflake"
        case .household: "house.fill"
        }
    }

    nonisolated var sortOrder: Int {
        ProductCategory.allCases.firstIndex(of: self) ?? 0
    }

    nonisolated var assetName: String? {
        switch self {
        case .baby: return "BabyCare"
        case .partySupplies: return "PartySupplies"
        case .personalCare: return "PersonalCare"
        case .frozen: return "Frozen"
        default: return nil
        }
    }

    nonisolated var imageURL: URL? {
        if assetName != nil { return nil }
        
        let urlString: String
        switch self {
        case .produce:
            urlString = "https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=600&q=80"
        case .dairy:
            urlString = "https://images.unsplash.com/photo-1628088062854-d1870b4553da?auto=format&fit=crop&w=600&q=80"
        case .meat:
            urlString = "https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?auto=format&fit=crop&w=600&q=80"
        case .bakery:
            urlString = "https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=600&q=80"
        case .pantry:
            urlString = "https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?auto=format&fit=crop&w=600&q=80"
        case .snacks:
            urlString = "https://images.unsplash.com/photo-1599490659213-e2b9527bd087?auto=format&fit=crop&w=600&q=80"
        case .beverages:
            urlString = "https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=600&q=80"
        case .cleaning:
            urlString = "https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?auto=format&fit=crop&w=600&q=80"
        case .partySupplies:
            urlString = "" // Handled by assetName
        case .baby:
            urlString = "" // Handled by assetName
        case .firstAid:
            urlString = "https://images.unsplash.com/photo-1603398938378-e54eab446dde?auto=format&fit=crop&w=600&q=80"
        case .personalCare:
            urlString = "" // Handled by assetName
        case .frozen:
            urlString = "" // Handled by assetName
        case .household:
            urlString = "https://images.unsplash.com/photo-1583947215259-38e31be8751f?auto=format&fit=crop&w=600&q=80"
        }
        return URL(string: urlString)
    }
}
