//
//  FavoriteViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

import Foundation
import SwiftUI

// ใช้ในการนำเข้า Combine framework สำหรับการจัดการข้อมูลแบบ asynchronous และ reactive ในแอปพลิเคชัน
import Combine

@MainActor

// เป็น class ที่ใช้สำหรับการจัดการข้อมูลของหน้า FavoriteView
final class FavoriteViewModel: ObservableObject {
    
    // MARK: ตัวแปร userFavoriteProducts ใช้เพื่อเก็บรายการ product ที่เป็นรายการโปรดของผู้ใช้
    // และเมื่อมีการเปลี่ยนแปลง userFavoriteProducts จะทำการ publish ให้ SwiftUI ทราบเพื่อทำการอัปเดตหน้าจอ
    @Published private(set) var userFavoriteProducts: [UserFavoriteProduct] = []
    
    // MARK: ตัวแปร cancellables เพื่อเก็บชุดของ AnyCancellable objects
    // ที่ใช้ในการยกเลิกการติดตาม (cancellations) ของ Combine publishers เมื่อ ViewModel ถูกทำลาย
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: ฟังก์ชัน addListenerForFavorites() เริ่มต้นการติดตามข้อมูลผลิตภัณฑ์โปรดของผู้ใช้
    // โดยใช้ UserManager.shared.addListenerForAllUserFavoriteProducts เพื่อรับข้อมูลผ่าน Combine publishers และเมื่อมีข้อมูลเข้ามาฟังก์ชันจะแก้ไขค่า userFavoriteProducts
    func addListenerForFavorites() {
        guard let authDataResult = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
        
//        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid) { [weak self] products in
//            self?.userFavoriteProducts = products
//        }
//    }
        
        UserManager.shared.addListenerForAllUserFavoriteProducts(userId: authDataResult.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] products in
                self?.userFavoriteProducts = products
            }
            .store(in: &cancellables)

    }
    
//    func getFavorites() {
//        Task {
//            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
//            self.userFavoriteProducts = try await UserManager.shared.getAllUserFavoriteProducts(userId: authDataResult.uid)
//        }
//    }
    
    // MARK: ฟังก์ชัน removeFromFavorites ใช้ในการลบผลิตภัณฑ์ออกจากรายการโปรดของผู้ใช้
    // โดยใช้ UserManager.shared.removeUserFavoriteProduct และมีการใช้ Task ในการทำงานแบบ asynchronous
    func removeFromFavorites(favoriteProductId: String) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.removeUserFavoriteProduct(userId: authDataResult.uid, favoriteProductId: favoriteProductId)
        }
    }
}
