//
//  OnFirstAppear.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 14/5/2567 BE.
//

//
//  OnFirstAppearViewModifier.swift
//  SwiftfulFirebaseBootcamp
//
//  Created by Nick Sarno on 1/22/23.
//

import Foundation
import SwiftUI

// เป็น ViewModifier ที่ใช้เพื่อเรียกใช้งานฟังก์ชันที่กำหนดเมื่อ view ปรากฏครั้งแรก
struct OnFirstAppearViewModifier: ViewModifier {
    
    // มีตัวแปร didAppear เพื่อเก็บสถานะว่า view ได้ปรากฏครั้งแรกแล้วหรือยัง
    @State private var didAppear: Bool = false
    
    // คอนสตรักเตอร์รับค่า perform ฟังก์ชันที่ต้องการให้ทำงานเมื่อ view ปรากฏครั้งแรก
    let perform: (() -> Void)?
    
    // ฟังก์ชัน body
    func body(content: Content) -> some View {
        content
        
            // เรียกใช้งาน onAppearตรวจสอบว่า view ได้ปรากฏครั้งแรกหรือยัง
            .onAppear {

                // และถ้ายังไม่ได้ปรากฏครั้งแรกจะเรียกใช้ฟังก์ชัน perform และเซ็ต didAppear เป็น true
                if !didAppear {
                    perform?()
                    didAppear = true
                }
            }
    }
}

extension View {
    
    //ประกาศฟังก์ชัน onFirstAppear เพื่อให้สามารถเรียกใช้งาน modifier OnFirstAppearViewModifier ได้
    func onFirstAppear(perform: (() -> Void)?) -> some View {
        modifier(OnFirstAppearViewModifier(perform: perform))
    }
}
