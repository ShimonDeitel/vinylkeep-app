import Foundation
import StoreKit

@MainActor
final class PurchaseManager: ObservableObject {
    static let productID = "com.shimondeitel.vinylkeep.pro"

    @Published private(set) var isPurchased: Bool = false
    @Published private(set) var product: Product?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = Task { await self.listenForUpdates() }
        Task { await self.loadProduct(); await self.refreshEntitlement() }
    }

    deinit { updatesTask?.cancel() }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
        } catch {
            print("Failed to load product: \(error)")
        }
    }

    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    isPurchased = true
                }
            default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    func refreshEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result, transaction.productID == Self.productID {
                isPurchased = true
                return
            }
        }
        isPurchased = false
    }

    private func listenForUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await refreshEntitlement()
            }
        }
    }
}
