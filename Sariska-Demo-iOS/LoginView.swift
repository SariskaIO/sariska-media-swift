//
//  LoginView.swift
//  Sariska-Demo-iOS
//
//  Created by Dipak Sisodiya on 14/07/23.
//

import Foundation

import SwiftUI

struct LoginView: View {
    @State private var roomName: String = ""
    @State private var userName: String = ""
    @State private var isNavigated: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack{
                
                Image("Image") // Replace "logo" with the name of your image asset
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 70)
                    .padding(.top, 50)
                
                TextField("Room Name", text: $roomName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("User Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !roomName.isEmpty && !userName.isEmpty {
                        isNavigated = true
                    }
                }) {
                    Text("Start Call")
                        .foregroundColor(.white)
                        .padding()
                        .background(roomName.isEmpty || userName.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(roomName.isEmpty || userName.isEmpty)
                .navigationDestination(isPresented: $isNavigated) {
                    ContentView(roomName: $roomName)
                }
            }.padding()
            
        }
    }
    
}
