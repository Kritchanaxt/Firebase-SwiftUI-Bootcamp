//
//  RootView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

// Import ไลบรารี SwiftUI เพื่อสร้างและจัดการกับอินเทอร์เฟซของ SwiftUI
 import SwiftUI

struct RootView: View {
    
    // ประกาศคุณสมบัติ showSignInView ในรูปแบบของ State variable ซึ่งจะเก็บค่าสถานะในแอปพลิเคชัน และเมื่อมีการเปลี่ยนแปลงค่า จะทำให้ UI ที่ใช้คุณสมบัตินี้เปลี่ยนแปลงไปตามด้วย
    @State private var showSignInView: Bool = false
    
    // body เป็น computed property ที่คืนค่าของ View
    var body: some View {
        
        //  ใช้เพื่อวางเลย์เอาต์ของวิวในลักษณะซ้อนกัน
        ZStack {
            
            // เงื่อนไขที่ตรวจสอบว่า showSignInView มีค่าเป็น false หรือไม่
            if !showSignInView {
                ZStack {
                    
                    // หาก showSignInView เป็น false จะทำการแสดง TabbarView และส่งค่า showSignInView ไปยัง TabbarView ผ่านการใช้ $showSignInView ซึ่งเป็นการผูกข้อมูล (binding)
                    if !showSignInView {
                        TabbarView(showSignInView: $showSignInView)
                    }
                }
            }
        }
        
        // ใช้ในการตรวจสอบการลงชื่อเข้าใช้ผู้ใช้ที่ได้ทำการระบบการลงชื่อเข้าใช้
        .onAppear{
            
            // ใช้ AuthenticationManager เพื่อทำการเข้ารหัสผู้ใช้ที่ยืนยันตัวตน โดยใช้เมท็อด getAuthenticatedUser() และเก็บผลลัพธ์ไว้ที่ authUser
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            
            // กำหนดค่าของ showSignInView โดยตรวจสอบว่าผู้ใช้ได้ทำการเข้าระบบหรือไม่ ถ้าไม่ได้เข้าระบบ (authUser == nil) จะกำหนดค่า showSignInView เป็น true เพื่อแสดงหน้า AuthenticationView
            self.showSignInView = authUser == nil
        }
        
        // แสดง View ที่ปกคลุมหน้าจอทั้งหมด เมื่อค่า showSignInView เป็น true
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack {
                
                // ใช้ในการลงชื่อเข้าใช้ และส่งค่า showSignInView เพื่อให้ AuthenticationView สามารถเปลี่ยนค่า showSignInView ได้โดยตรง
                AuthenticationView(showSignInView:  $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
