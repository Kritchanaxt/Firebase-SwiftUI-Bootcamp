//
//  ProductsViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

import Foundation
import SwiftUI
import FirebaseFirestore

// ประกาศคลาส ProductsViewModel ให้เป็น Main Actor ซึ่งหมายความว่าตัวอินสแตนซ์ของคลาสนี้จะทำงานบนเธรดหลักของแอปพลิเคชัน.
@MainActor

// ประกาศคลาสให้เป็นคลาสสุดท้ายและสืบทอดจาก ObservableObject เพื่อให้สามารถเผยแพร่การเปลี่ยนแปลงของข้อมูลไปยัง SwiftUI views ที่ใช้งาน.
final class ProductsViewModel: ObservableObject {
    
    // ประกาศตัวแปร products เป็น @Published เพื่อให้ SwiftUI views สามารถติดตามการเปลี่ยนแปลงของข้อมูลได้ โดยเฉพาะเมื่อมีการเพิ่มสินค้าเข้าไปในรายการ.
    @Published private(set) var products: [Product] = []
    
    // ประกาศตัวแปร selectedFilter และ selectedCategory เพื่อเก็บค่าที่ผู้ใช้เลือกเป็นตัวกรองและหมวดหมู่ของ product และใช้ @Published เพื่อเผยแพร่การเปลี่ยนแปลงของค่านี้.
    @Published var selectedFilter: FilterOption? = nil
    @Published var selectedCategory: CategoryOption? = nil
    
    // ประกาศตัวแปร lastDocument เพื่อเก็บเอกสารล่าสุดที่โหลดมาจาก Firestore.
    private var lastDocument: DocumentSnapshot? = nil
    
// MARK: Filter
    
    // ประกาศ enum FilterOption เพื่อเก็บตัวกรองที่ผู้ใช้เลือก เช่น ไม่มีการกรอง, ราคาสูง, ราคาต่ำ.
    enum FilterOption: String, CaseIterable {
        case noFilter
        case priceHigh
        case priceLow
        
        var priceDescending: Bool? {
            switch self {
            case .noFilter: return nil
            case .priceHigh: return true
            case .priceLow: return false
            }
        }
    }
    // ฟังก์ชัน filterSelected เป็น asynchronous และใช้ async throws เนื่องจากมีการเรียกใช้ Task ภายในฟังก์ชัน
    // เมื่อผู้ใช้เลือกตัวกรองสินค้า ฟังก์ชันนี้จะเซ็ตค่า selectedFilter และเรียก getProducts เพื่อโหลดข้อมูลสินค้าใหม่.
    func filterSelected(option: FilterOption) async throws {
        self.selectedFilter = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
    }
    
// MARK: Category
    
    // ประกาศ enum CategoryOption เพื่อเก็บหมวดหมู่ที่ผู้ใช้เลือก เช่น ไม่มีหมวดหมู่, สมาร์ทโฟน, แล็ปท็อป, น้ำหอม.
    enum CategoryOption: String, CaseIterable {
        case noCategory
        case smartphones
        case laptops
        case fragrances
        
        var categoryKey: String? {
            if self == .noCategory {
                return nil
            }
            return self.rawValue
        }
    }
    // ฟังก์ชัน categorySelected เป็น asynchronous และใช้ async throws เนื่องจากมีการเรียกใช้ Task ภายในฟังก์ชัน
    // เมื่อผู้ใช้เลือกหมวดหมู่สินค้า ฟังก์ชันนี้จะเซ็ตค่า selectedCategory และเรียก getProducts เพื่อโหลดข้อมูลสินค้าใหม่.
    func categorySelected(option: CategoryOption) async throws {
        self.selectedCategory = option
        self.products = []
        self.lastDocument = nil
        self.getProducts()
    }
    
    // ฟังก์ชัน getProducts เป็น asynchronous และใช้ Task เพื่อโหลดข้อมูลสินค้าจาก Firestore
    // โดยใช้เงื่อนไขตัวกรองและหมวดหมู่ที่ผู้ใช้เลือก ข้อมูลสินค้าจะถูกเผยแพร่ไปยัง SwiftUI views เพื่อแสดงผล.
    func getProducts() {
        Task {
            let (newProducts, lastDocument) = try await ProductsManager.shared.getAllProducts(priceDescending: selectedFilter?.priceDescending, forCategory: selectedCategory?.categoryKey, count: 10, lastDocument: lastDocument)
            
            self.products.append(contentsOf: newProducts)
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }
    
    // เพิ่ม product เข้าในรายการโปรดของผู้ใช้ โดยใช้ข้อมูลการเข้าสู่ระบบและจัดการผู้ใช้
    // โดยไม่บล็อกการทำงานของแอป และไม่เกิดข้อผิดพลาดหากมีปัญหาในการเพิ่มผลิตภัณฑ์ในรายการโปรด
    func addUserFavoriteProduct(productId: Int) {
        Task {
            let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
            try? await UserManager.shared.addUserFavoriteProduct(userId: authDataResult.uid, productId: productId)
        }
    }
    
    
// MARK: Count & Rating
    
//    func getProductsCount() {
//        Task {
//            let count = try await ProductsManager.shared.getAllProductsCount()
//            print("ALL PRODUCT COUNT: \(count)")
//        }
//    }
    
//    func getProductsByRating() {
//        Task {
////            let newProducts = try await ProductsManager.shared.getProductsByRating(count: 3, lastRating: self.products.last?.rating)
//
//            let (newProducts, lastDocument) = try await ProductsManager.shared.getProductsByRating(count: 3, lastDocument: lastDocument)
//            self.products.append(contentsOf: newProducts)
//            self.lastDocument = lastDocument
//        }
//    }
}
