import Foundation

struct QuantityScalingEngine: QuantityScaling {

    let rules: [ProductCategory: ScalingRule]

    init(rules: [ProductCategory: ScalingRule] = QuantityScalingEngine.defaultRules) {
        self.rules = rules
    }

    func recommendedQuantity(for product: Product, intent: ShoppingIntent) -> Int {
        let people = max(1, intent.peopleCount ?? 1)
        let rule = rules[product.category] ?? QuantityScalingEngine.fallbackRule

        let durationDays = max(1, intent.durationDays ?? 1)
        let durationFactor = 1.0 + (Double(durationDays - 1) * rule.perDayMultiplier)

        let servingsNeeded = Double(people) * rule.servingsPerPerson * durationFactor
        let servingsPerPack = max(1.0, product.servingsPerPack ?? rule.servingsPerPerson)

        let rawPacks = servingsNeeded / servingsPerPack
        return rule.rounding.apply(to: rawPacks)
    }

    static let fallbackRule = ScalingRule(category: .pantry, servingsPerPerson: 1.0, perDayMultiplier: 0.0, rounding: .up)

    static let defaultRules: [ProductCategory: ScalingRule] = [
        .produce: ScalingRule(category: .produce, servingsPerPerson: 1.0, perDayMultiplier: 0.4, rounding: .up),
        .dairy: ScalingRule(category: .dairy, servingsPerPerson: 1.0, perDayMultiplier: 0.5, rounding: .up),
        .meat: ScalingRule(category: .meat, servingsPerPerson: 1.0, perDayMultiplier: 0.2, rounding: .up),
        .bakery: ScalingRule(category: .bakery, servingsPerPerson: 1.0, perDayMultiplier: 0.5, rounding: .up),
        .pantry: ScalingRule(category: .pantry, servingsPerPerson: 0.5, perDayMultiplier: 0.1, rounding: .up),
        .snacks: ScalingRule(category: .snacks, servingsPerPerson: 1.2, perDayMultiplier: 0.0, rounding: .up),
        .beverages: ScalingRule(category: .beverages, servingsPerPerson: 1.5, perDayMultiplier: 0.0, rounding: .up),
        .cleaning: ScalingRule(category: .cleaning, servingsPerPerson: 0.2, perDayMultiplier: 0.0, rounding: .up),
        .partySupplies: ScalingRule(category: .partySupplies, servingsPerPerson: 1.0, perDayMultiplier: 0.0, rounding: .up),
        .baby: ScalingRule(category: .baby, servingsPerPerson: 1.0, perDayMultiplier: 0.3, rounding: .up),
        .firstAid: ScalingRule(category: .firstAid, servingsPerPerson: 0.3, perDayMultiplier: 0.0, rounding: .up),
        .personalCare: ScalingRule(category: .personalCare, servingsPerPerson: 0.3, perDayMultiplier: 0.0, rounding: .up),
        .frozen: ScalingRule(category: .frozen, servingsPerPerson: 1.0, perDayMultiplier: 0.2, rounding: .up),
        .household: ScalingRule(category: .household, servingsPerPerson: 0.3, perDayMultiplier: 0.0, rounding: .up)
    ]
}
