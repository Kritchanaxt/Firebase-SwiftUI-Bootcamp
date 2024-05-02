//
//  ProductCellViewBuilder.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

import SwiftUI

// ProductCellViewBuilder เป็น view ที่ใช้สำหรับสร้าง ProductCellView โดยรับค่า productId เป็นรหัสของผลิตภัณฑ์ที่ต้องการแสดง
struct ProductCellViewBuilder: View {
    let productId: String
    
        // เพื่อเก็บข้อมูลของผลิตภัณฑ์ที่โหลดมาจาก Firestore
        @State private var product: Product? = nil
        
        var body: some View {
            ZStack {
                
                // โดยใช้ if let ในการตรวจสอบว่าข้อมูลผลิตภัณฑ์ถูกโหลดแล้วหรือยัง และเมื่อข้อมูลถูกโหลดแล้วจะแสดง ProductCellView ด้วยข้อมูลผลิตภัณฑ์ที่ได้รับ
                if let product {
                    ProductCellView(product: product)
                }
            }
            
            // ใช้งาน task เพื่อโหลดข้อมูลผลิตภัณฑ์โดยใช้ ProductsManager โดยส่ง productId เข้าไป และเก็บผลลัพธ์ไว้ใน product
            .task {
                self.product = try? await ProductsManager.shared.getProduct(productId: productId)
            }
        }
}

#Preview {
    ProductCellViewBuilder(productId: "1")
}
