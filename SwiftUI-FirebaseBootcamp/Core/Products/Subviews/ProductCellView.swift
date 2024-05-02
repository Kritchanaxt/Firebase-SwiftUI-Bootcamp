//
//  ProductCellView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 10/5/2567 BE.
//


// สรุปสั้น ๆ ใช้ในการแสดงข้อมูลของผลิตภัณฑ์ โดยมีรูปภาพตัวอย่างและรายละเอียดอื่น ๆ เช่น ชื่อ, ราคา, คะแนน, หมวดหมู่, และแบรนด์ ซึ่งสามารถนำไปใช้ในแอปพลิเคชัน SwiftUI ได้โดยง่าย

import SwiftUI

struct ProductCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 75, height: 75)
                    .cornerRadius(10)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 75, height: 75)
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text((product.title ?? "n/a"))
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Price: $" + String(product.price ?? 0))
                Text("Rating: $" + String(product.rating ?? 0))
                Text("Category: $" + String(product.category ?? "n/a"))
                Text("Brand: $" + String(product.brand ?? "n/a"))
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProductCellView(product: Product(id: 1, title: "Test", description: "test", price: 435, discountPercentage: 1345245, rating: 65231, stock: 1324, brand: "asdfasdf", category: "asdfafsd", thumbnail: "asdfafds", images: []))
}
