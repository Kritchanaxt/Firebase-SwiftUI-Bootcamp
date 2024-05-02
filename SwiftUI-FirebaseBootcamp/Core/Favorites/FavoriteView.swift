//
//  FavoriteView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 13/5/2567 BE.
//

import SwiftUI

// FavoriteView เป็น view ที่ใช้สำหรับแสดงรายการผลิตภัณฑ์ที่ถูกเลือกเป็นรายการโปรดของผู้ใช้
struct FavoriteView: View {
    
    // ตัวแปร viewModel เพื่อเก็บ ViewModel สำหรับการจัดการข้อมูลของหน้านี้
    @StateObject private var viewModel = FavoriteViewModel()
    
    var body: some View {
        List {
            
            // ใช้ ForEach เพื่อวนลูป product แต่ละรายการและใช้ ProductCellViewBuilder เพื่อแสดงข้อมูลของ product แต่ละรายการ และให้ผู้ใช้สามารถลบรายการที่ไม่ต้องการออกจากรายการโปรดได้ผ่าน context menu
            ForEach(viewModel.userFavoriteProducts, id: \.id.self) { item in
                ProductCellViewBuilder(productId: String(item.productId))
                    .contextMenu {
                        Button("Remove from favorites") {
                            viewModel.removeFromFavorites(favoriteProductId: item.id)
                        }
                    }
            }
        }
        //ใช้ onFirstAppear modifier เพื่อเรียกใช้งาน viewModel.addListenerForFavorites() เมื่อหน้านี้ถูกแสดงครั้งแรก
        .navigationTitle("Favorites")
        .onFirstAppear {
            viewModel.addListenerForFavorites()
        }
    }
}

#Preview {
    NavigationStack {
        FavoriteView()
    }
}
