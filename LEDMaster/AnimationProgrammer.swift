//
//  AnimationProgrammer.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 23.05.21.
//
import SwiftUI

struct ProgrammerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bledevice = BluetoothController()
    @State private var state: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 1001)
    
    var body: some View {
        VStack {
            ZStack{
                LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: .topLeading, endPoint: .bottom)
                Group {
                    Spacer()
                    HStack {
                        Text("Program Animations").colorInvert().padding()
                        Button("X"){
                            print("fin")
                            presentationMode.wrappedValue.dismiss()
                        }.foregroundColor(.white).padding()
                    }
                }
            }.ignoresSafeArea().frame(height: 30)
            Spacer()
            ScrollView {
                LazyVStack(alignment: .center) {
                ForEach(1...1000, id: \.self) { count in
                    
                    HStack(){
                        Text("\(count)")
                        Spacer()
                        LEDBlob(value: $state[count][0]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][1]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][2]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][3]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][4]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][5]).frame(width: 30, height: 30)
                    }.padding(5).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    
                }
                }.padding()
        }
        }
    }
}

struct AnimationProgrammer_Previews: PreviewProvider {
    static var previews: some View {
        ProgrammerView()
    }
}
