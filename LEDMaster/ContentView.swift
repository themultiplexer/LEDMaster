//
//  ContentView.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 12.04.21.
//

import SwiftUI
import CoreBluetooth

struct SecondView: View {
    var body: some View {
        Text("This is the detail view")
    }
}

struct ProgressBar: View {
    @Binding var value: UInt8
    var bledevice:BluetoothController
    var index = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                Spacer()
                Rectangle().frame(width: geometry.size.width, height: min(CGFloat((Float)(self.value) / 255.0)*geometry.size.height, geometry.size.height))
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.easeIn)
            }.cornerRadius(45.0).gesture(
                TapGesture()
                    .onEnded { _ in
                        self.bledevice.sendText(text: "band:" + String(index))
                        print("band:" + String(index))
                    }
            )
        }
    }
}

struct LEDBlob: View {
    @Binding var value: Int
    var colors = [UIColor.red, UIColor.green, UIColor.yellow, UIColor.systemTeal]
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(colors[value]))
                
                Text("\(value)").frame(width: geometry.size.width , height: geometry.size.height).multilineTextAlignment(.center)
            }.cornerRadius(45.0).gesture(
                TapGesture()
                    .onEnded { _ in
                        value = value < 3 ? value + 1 : 0
                    }
            )
        }
    }
}

struct ContentView: View {
    @ObservedObject var bledevice = BluetoothController()
    @State private var brightness: Double = 0
    @State private var speed: Double = 0
    @State private var showing: Bool = false
    var effects = ["Hue", "Pump", "Pipe", "Pump Lit"]
    @State private var selectedEffect = 0

    @State private var bgColor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2)
    
    var body: some View {
        NavigationView{
            VStack {
                HStack{
                    Button("Connect") {
                        print("Button tapped!")
                        self.bledevice.connect()
                    }.font(Font.system(size: 20.0).weight(.bold)).padding()
                    Text("State:  \(bledevice.currentState)").padding()
                }
                HStack {
                    Spacer()
                    ColorPicker("Alignment Guides", selection: $bgColor).padding()
                    Spacer()
                }
                VStack{
                    Slider(value: $brightness, in: 0...255, onEditingChanged: { changed in
                        if(!changed){
                            self.bledevice.sendText(text: "brightness:" + String(Int(brightness)))
                        }
                    }).padding()
                    Slider(value: $speed, in: 0...255, onEditingChanged: { changed in
                        if(!changed){
                            self.bledevice.sendText(text: "speed:" + String(Int(speed)))
                        }
                    }).padding()
                }.accentColor(.red).overlay(RoundedRectangle(cornerRadius: 15.0).stroke(lineWidth: 2.0).foregroundColor(.red)).padding()
                HStack {
                    ProgressBar(value: $bledevice.value[0], bledevice: self.bledevice, index:0).frame(width: 20)
                    ProgressBar(value: $bledevice.value[1], bledevice: self.bledevice, index:1).frame(width: 20)
                    ProgressBar(value: $bledevice.value[2], bledevice: self.bledevice, index:2).frame(width: 20)
                    ProgressBar(value: $bledevice.value[3], bledevice: self.bledevice, index:3).frame(width: 20)
                    ProgressBar(value: $bledevice.value[4], bledevice: self.bledevice, index:4).frame(width: 20)
                    ProgressBar(value: $bledevice.value[5], bledevice: self.bledevice, index:5).frame(width: 20)
                    ProgressBar(value: $bledevice.value[6], bledevice: self.bledevice, index:6).frame(width: 20)
                }.foregroundColor(.blue).frame(height:150)
                Picker("Please choose a color", selection: $selectedEffect) {
                    Text("Hue").tag(0)
                    Text("Pump").tag(1)
                    Text("Tube").tag(2)
                    Text("Pump Limiter").tag(3)
                    /*
                     ForEach((0...effects.count-1), id: \.self) {
                     Text(effects[$0]).tag($0)
                     }
                     */
                }.onChange(of: selectedEffect, perform : { (value) in
                    self.bledevice.sendText(text: "mode:" + String(value))
                    print("mode:" + String(value))
                }).pickerStyle(MenuPickerStyle())
                HStack{
                    Button("LEDs ON") {
                        self.bledevice.sendText(text: "switch:1")
                    }.padding()
                    Button("LEDs OFF") {
                        self.bledevice.sendText(text: "switch:0")
                    }.padding()
                }
            }.navigationTitle("LED Master").navigationBarTitleDisplayMode(.inline).navigationBarItems(leading:
                NavigationLink(destination: SecondView()) {
                        Image(systemName: "gearshape.2.fill").imageScale(.large)
                },
                trailing:
                    NavigationLink(destination: ProgrammerView()) {
                        Image(systemName: "chart.bar.xaxis").imageScale(.large)
                    }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

