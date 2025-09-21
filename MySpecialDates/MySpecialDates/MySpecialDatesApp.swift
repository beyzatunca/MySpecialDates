//
//  MySpecialDatesApp.swift
//  MySpecialDates
//
//  Created by Beyza Erdemli on 07.08.25.
//

import SwiftUI

@main
struct MySpecialDatesApp: App {
    
    init() {
        // Firebase yapılandırması - şimdi aktif
        // FirebaseConfiguration.shared.configure()
        print("🔥 Firebase yapılandırması başlatılıyor...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
