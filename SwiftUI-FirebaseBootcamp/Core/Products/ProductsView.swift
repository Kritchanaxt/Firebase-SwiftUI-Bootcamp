//
//  ProductsView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 10/5/2567 BE.
//

//
//  ProductsView.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/22/23.
//
import SwiftUI

struct ProductsView: View {
    
    // ใช้ @StateObject เพื่อจัดการสถานะของ ViewModel ตลอดอายุการใช้งานของ ProductsView
    @StateObject private var viewModel = ProductsViewModel()
    
    var body: some View {
        
        // ใช้ List เพื่อแสดงรายการผลิตภัณฑ์
        List {
            ForEach(viewModel.products) { product in
                
                // สำหรับแต่ละ product จะแสดง ProductCellView or แสดงข้อมูลของ product แต่ละตัว
                ProductCellView(product: product)
                
                    // เพิ่มเมนูคลิก(contextMenu) ให้กับแต่ละ product เพื่อให้ผู้ใช้สามารถเพิ่มผลิตภัณฑ์ลงในรายการโปรดได้
                    .contextMenu {
                        Button("Add to favorites") {
                            viewModel.addUserFavoriteProduct(productId: product.id)
                        }
                    }
                
                // ถ้า product นั้นเป็นรายการสุดท้ายใน viewModel.products จะแสดง ProgressView และโหลด product เพิ่มเติมเมื่อปรากฏ (onAppear)
                if product == viewModel.products.last {
                    ProgressView()
                        .onAppear {
                            viewModel.getProducts()
                        }
                }
            }
        }
        .navigationTitle("Products")
        
        // เพิ่ม Toolbar สองอัน: ที่จะใช้ในการกรองและจัดการหมวดหมู่
        .toolbar(content: {
            
            // อันแรกที่ด้านซ้ายแสดงเมนูสำหรับการกรอง (Filter)
            ToolbarItem(placement: .navigationBarLeading) {
                Menu("Filter: \(viewModel.selectedFilter?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.FilterOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.filterSelected(option: option)
                            }
                        }
                    }
                }
            }
            
            // อันที่สองที่ด้านขวาแสดงเมนูสำหรับหมวดหมู่ (Category)
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu("Category: \(viewModel.selectedCategory?.rawValue ?? "NONE")") {
                    ForEach(ProductsViewModel.CategoryOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            Task {
                                try? await viewModel.categorySelected(option: option)
                            }
                        }
                    }
                }
            }
        })
        
        // จะเรียกใช้ฟังก์ชัน getProducts ใน ViewModel เพื่อโหลดผลิตภัณฑ์
        .onAppear {
            viewModel.getProducts()
        }
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
