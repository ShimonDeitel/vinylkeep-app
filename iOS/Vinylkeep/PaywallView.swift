import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Theme.accent)
                    Text("Vinylkeep Pro")
                        .font(Theme.font(26, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    Text("Discogs-style value tracking and wantlist export")
                        .font(Theme.font(15))
                        .foregroundStyle(Theme.muted)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Text("You've reached the free limit of \(Store.freeLimit) entries.")
                        .font(Theme.font(13))
                        .foregroundStyle(Theme.muted)

                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text(purchases.product != nil ? "Unlock for \(purchases.product!.displayPrice)" : "Unlock Pro")
                            .font(Theme.font(17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cardCorner))
                    }
                    .accessibilityIdentifier("unlockProButton")
                    .padding(.horizontal, 32)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(Theme.font(14))
                    .foregroundStyle(Theme.muted)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityIdentifier("paywallCloseButton")
                }
            }
        }
    }
}
