//
//  AddToShelf.swift
//  Cosmetic-Planning-App
//

import SwiftUI

extension View {
    /** Asks "In rotation or Backup?" for a product, then adds it to the shelf */
    func addToShelfDialog(_ candidate: Binding<ShelfCandidate?>, viewModel: DiscoverViewModel) -> some View {
        confirmationDialog(
            "Add \(candidate.wrappedValue?.name ?? "this product") to your shelf?",
            isPresented: Binding(get: { candidate.wrappedValue != nil },
                                 set: { if !$0 { candidate.wrappedValue = nil } }),
            titleVisibility: .visible,
            presenting: candidate.wrappedValue
        ) { item in
            ForEach(Product.statuses.filter { $0 != "Finished" }, id: \.self) { status in
                Button("Add as \(status)") {
                    Task { await viewModel.addToShelf(item, status: status) }
                }
            }
        }
    }

    /** Small "Added to your shelf" message at the bottom that fades away */
    func shelfToast(_ viewModel: DiscoverViewModel) -> some View {
        overlay(alignment: .bottom) {
            if let message = viewModel.toastMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .font(.appSans(12, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColor.accent, in: Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: message) {
                        try? await Task.sleep(for: .seconds(2))
                        withAnimation { viewModel.toastMessage = nil }
                    }
            }
        }
        .animation(.spring(duration: 0.3), value: viewModel.toastMessage)
    }
}
