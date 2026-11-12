//
//  ProfileViewModel.swift
//  Cosmetic-Planning-App
//

import Foundation
import Observation

@MainActor
@Observable
class ProfileViewModel {
    var profile: UserProfile?
    var routines: [Routine] = []
    var stepCounts: [UUID: Int] = [:]
    var routineCount: Int { routines.count }
    var products: [Product] = []
    var isLoading = false
    var errorMessage: String?

    private let service = ProfileService()
    private let routineService = RoutineService()
    private let stepService = RoutineStepService()
    private let productService = ProductService()

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            profile = try await service.fetchProfile()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // For the "At a glance" section and the Routines tab
    func loadStats() async {
        routines = (try? await routineService.fetchRoutines()) ?? []
        for routine in routines {
            stepCounts[routine.id] = (try? await stepService.fetchSteps(routineId: routine.id).count) ?? 0
        }
    }

    // For the Shelf tab
    func loadProducts() async {
        do {
            products = try await productService.fetchProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addProduct(_ draft: NewProductDraft) async {
        do {
            try await productService.addProduct(draft)
            await loadProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteProduct(_ product: Product) async {
        do {
            try await productService.deleteProduct(product)
            products.removeAll { $0.id == product.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(_ draft: ProfileDraft) async {
        do {
            try await service.updateProfile(draft)
            await loadProfile()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
