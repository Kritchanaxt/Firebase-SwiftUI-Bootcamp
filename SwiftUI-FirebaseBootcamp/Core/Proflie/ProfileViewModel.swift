//
//  ProfileViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // เก็บข้อมูลผู้ใช้
    @Published private(set) var user: DBUser? = nil
    
    // MARK: ฟังก์ชั่นโหลดผู้ใช้ปัจจุบัน
    func loadCurrentUser() async throws {
        
        // ดึงข้อมูลผู้ใช้ที่เข้าสู่ระบบ
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        
        // โหลดข้อมูลผู้ใช้จากฐานข้อมูล
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    // MARK: ฟังก์ชั่นสลับสถานะพรีเมี่ยม
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            
            // สลับสถานะพรีเมียมของผู้ใช้
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            
            // รีเฟรชข้อมูลผู้ใช้
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: ฟังก์ชั่นเพิ่มการตั้งค่าผู้ใช้
    func addUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            
            // เพิ่ม preference ให้ผู้ใช้
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            
            // รีเฟรชข้อมูลผู้ใช้
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: ฟังก์ชั่นลบการตั้งค่าผู้ใช้
    func removeUserPreference(text: String) {
        guard let user else { return }
        
        Task {
            
            // ลบ preference ของผู้ใช้
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            
            // รีเฟรชข้อมูลผู้ใช้
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: ฟังก์ชั่นเพิ่มภาพยนตร์เรื่องโปรด
    func addFavoriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            
            // เพิ่มหนังโปรดให้ผู้ใช้
            try await UserManager.shared.addFavoriteMovie(userId: user.userId, movie: movie)
            
            // รีเฟรชข้อมูลผู้ใช้
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: ฟังก์ชั่นลบภาพยนตร์เรื่องโปรด
    func removeFavoriteMovie() {
        guard let user else { return }

        Task {
            
            // ลบหนังโปรดของผู้ใช้
            try await UserManager.shared.removeFavoriteMovie(userId: user.userId)
            
            // รีเฟรชข้อมูลผู้ใช้
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // MARK: ฟังก์ชั่นบันทึกภาพโปรไฟล์
    func saveProfileImage(item: PhotosPickerItem) {
        guard let user else { return }

        Task {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            
            // บันทึกภาพโปรไฟล์
            let (path, name) = try await StorageManager.shared.saveImage(data: data, userId: user.userId)
            print("SUCCESS!")
            print(path)
            print(name)
            
            // ดึง URL ของภาพโปรไฟล์
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            
            // อัปเดตข้อมูลภาพโปรไฟล์ในฐานข้อมูลผู้ใช้
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: path, url: url.absoluteString)
        }
    }
    
    // MARK: ฟังก์ชั่นลบภาพโปรไฟล์
    func deleteProfileImage() {
        guard let user, let path = user.profileImagePath else { return }

        Task {
            
            // ลบภาพโปรไฟล์จากที่เก็บ
            try await StorageManager.shared.deleteImage(path: path)
            
            // อัปเดตข้อมูลผู้ใช้เพื่อลบเส้นทางภาพโปรไฟล์
            try await UserManager.shared.updateUserProfileImagePath(userId: user.userId, path: nil, url: nil)
        }
    }
    
}
