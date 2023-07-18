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
                
                Image("SariskaLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding(.top, 50)
                    .padding(.bottom, 40)
                
                Text("Sariska Meet")
                    .bold()

                TextField("Room Name", text: $roomName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(10)
                    .border(Color.gray, width: 1)
                    .frame(height: 40)
                    .padding()
                
                TextField("User Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .cornerRadius(10)
                    .border(Color.gray, width: 1)
                    .frame(height: 40)
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
                    ContentView(roomName: $roomName, userName: $userName)
                }
            }
            .padding()
            
        }
    }
}
