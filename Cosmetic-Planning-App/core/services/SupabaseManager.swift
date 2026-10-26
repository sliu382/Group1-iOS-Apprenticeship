//
//  SupabaseManager.swift
//  Cosmetic-Planning-App
//
//  Created by Siyu Liu on 10/25/26.
//

import Foundation
import Supabase

enum SupabaseManager {
    static let client: SupabaseClient = {
        guard
            let urlString = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_URL"
            ) as? String,
            let url = URL(string: urlString),
            let key = Bundle.main.object(
                forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY"
            ) as? String
        else {
            fatalError("Missing Supabase Configuration")
        }
        
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()
}
