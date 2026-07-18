import Foundation

enum IntentHeuristics {

    static let numberWords: [String: Int] = [
        "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
        "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
        "eleven": 11, "twelve": 12, "a couple": 2, "couple": 2,
        "few": 3, "dozen": 12
    ]

    static let occasionKeywords: [(keywords: [String], occasion: Occasion)] = [
        (["movie night", "movie", "film night", "netflix"], .movieNight),
        (["weekly restock", "restock", "grocery run", "monthly groceries", "weekly groceries"], .weeklyRestock),
        (["breakfast", "brunch"], .breakfast),
        (["dinner party", "dinner for", "house party", "get together", "get-together"], .dinnerParty),
        (["birthday", "bday"], .birthday),
        (["festival", "diwali", "holi", "christmas", "eid", "new year"], .festival),
        (["guests", "guests over", "visitors", "company coming"], .guestsOver),
        (["baby", "infant", "newborn", "diaper"], .babyCare),
        (["sick", "fever", "cold", "flu", "not feeling well", "unwell", "illness"], .illness),
        (["picnic", "outing", "trip"], .picnic),
        (["cleaning", "clean the house", "deep clean"], .cleaning)
    ]
    static let dietaryKeywords: [(keywords: [String], constraint: DietaryConstraint)] = [
        (["vegan"], .vegan),
        (["vegetarian", "veg only", "no meat", "veggie"], .vegetarian),
        (["non vegetarian", "non-vegetarian", "non veg", "meat", "chicken", "beef", "pork"], .nonVegetarian),
        (["eggetarian", "egg only"], .eggetarian)
    ]

    static func detectPeopleCount(in text: String) -> Int? {
        let lower = text.lowercased()
        let patterns = ["for ", "serves ", "party of ", "feed "]
        for pattern in patterns {
            var searchRange = lower.startIndex..<lower.endIndex
            while let range = lower.range(of: pattern, range: searchRange) {
                let tail = lower[range.upperBound...]
                if let count = leadingCount(in: String(tail)) {
                    return count
                }
                searchRange = range.upperBound..<lower.endIndex
            }
        }
        if let people = regexInt(in: lower, pattern: #"(\d+)\s*(?:people|persons|ppl|pax|guests|adults)"#) {
            return people
        }
        return nil
    }

    static func detectBudget(in text: String) -> Int? {
        let lower = text.lowercased()
        let patterns = [
            #"(?:under|below|within|max|budget of|budget|around|about|upto|up to)\s*(?:rs\.?|inr|₹)?\s*(\d[\d,]*)"#,
            #"(?:rs\.?|inr|₹)\s*(\d[\d,]*)"#,
            #"(\d[\d,]*)\s*(?:rs\.?|rupees|inr|bucks)"#
        ]
        for pattern in patterns {
            if let value = regexInt(in: lower, pattern: pattern) {
                return value
            }
        }
        return nil
    }

    static func detectDurationDays(in text: String) -> Int? {
        let lower = text.lowercased()
        if lower.contains("month") { return 30 }
        if lower.contains("fortnight") || lower.contains("two weeks") { return 14 }
        if lower.contains("week") { return 7 }
        if let days = regexInt(in: lower, pattern: #"(\d+)\s*days?"#) { return days }
        if let weeks = regexInt(in: lower, pattern: #"(\d+)\s*weeks?"#) { return weeks * 7 }
        return nil
    }

    static func detectOccasion(in text: String) -> Occasion? {
        let lower = text.lowercased()
        for entry in occasionKeywords where entry.keywords.contains(where: { lower.contains($0) }) {
            return entry.occasion
        }
        return nil
    }

    static func detectDietary(in text: String) -> [DietaryConstraint] {
        let lower = text.lowercased()
        var found: [DietaryConstraint] = []
        for entry in dietaryKeywords where entry.keywords.contains(where: { lower.contains($0) }) {
            if !found.contains(entry.constraint) { found.append(entry.constraint) }
        }
        return found
    }

    static func detectExistingItems(in text: String) -> [String] {
        let lower = text.lowercased()
        let markers = ["i already have", "already have", "i have", "we have", "got", "excluding"]
        for marker in markers {
            guard let range = lower.range(of: marker) else { continue }
            var clause = String(lower[range.upperBound...])
            for stopword in [". ", ", and ", " but ", " so ", " please", "\n"] {
                if let stop = clause.range(of: stopword) {
                    clause = String(clause[..<stop.lowerBound])
                }
            }
            let items = clause
                .replacingOccurrences(of: " and ", with: ",")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { $0.count > 1 && $0.count < 30 }
            if !items.isEmpty { return Array(items.prefix(6)) }
        }
        return []
    }

    static func splitSubIntents(in text: String) -> [String] {
        let separators = [" + ", " plus ", " and also ", " also ", ";"]
        var fragments = [text]
        for separator in separators {
            fragments = fragments.flatMap { $0.components(separatedBy: separator) }
        }
        let cleaned = fragments
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return cleaned.count > 1 ? cleaned : [text]
    }

    private static func leadingCount(in text: String) -> Int? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if let match = trimmed.prefix(while: { $0.isNumber }).isEmpty ? nil : Int(trimmed.prefix(while: { $0.isNumber })) {
            return match
        }
        for (word, value) in numberWords where trimmed.hasPrefix(word) {
            return value
        }
        return nil
    }

    private static func regexInt(in text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range), match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text) else { return nil }
        let digits = text[captureRange].filter { $0.isNumber }
        return Int(digits)
    }
}
