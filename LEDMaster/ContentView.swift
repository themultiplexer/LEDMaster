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
    @StateObject var bledevice = BluetoothController()
    @ObservedObject var tapper = TapController()

    @State private var isRed: Bool = false
    @State private var showing: Bool = false
    var effects = ["Hue", "Pump", "Pipe", "Pump Lit"]
    
    var sliderHeight:CGFloat = 200.0
    private var lasttime : Double = 0.0
    
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
                    Toggle(isOn: $bledevice.staticColor){}
                    ColorPicker(selection: $bledevice.bgColor){
                        Text("Color").frame(maxWidth: .infinity, alignment: .trailing)
                    }.padding()
                    Picker(selection: $bledevice.selectedEffect, label:Image(systemName: "wand.and.stars").font(.title)) {
                        Text("Hue").tag(0)
                        Text("Pump").tag(1)
                        Text("Tube").tag(2)
                        Text("Pump Limiter").tag(3)
                        Text("Duck").tag(4)
                    }.pickerStyle(MenuPickerStyle()).padding()
                    HStack{
                        Text("\(tapper.bpm) BPM")
                        ZStack{
                            Circle().fill(isRed ? Color.red : Color.black).frame(width:50, height:50).gesture(LongPressGesture().onChanged { _ in
                                tapper.tap()
                                self.isRed.toggle()
                            })
                            Text("Tap").foregroundColor(isRed ? Color.white : Color.white)
                        }
                    }
                    Spacer()
                }
                Picker(selection: $bledevice.selectedCoordinator, label: Text("OK")){
                    Text("Same").tag(0)
                    Text("Rotate").tag(1)
                    Text("Random").tag(2)
                    Text("Bands").tag(3)
                    Text("BPM").tag(4)
                }.pickerStyle(SegmentedPickerStyle()).padding()
                VStack {
                    HStack{
                        Image(systemName: "sun.min").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                        Slider(value: $bledevice.brightness, in: 0...255, onEditingChanged: { changed in
                            if(!changed){
                                self.bledevice.sendText(text: "brightness:" + String(Int(bledevice.brightness)))
                            }
                        }).accentColor(.yellow)
                        Image(systemName: "sun.max.fill").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                    }.padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    HStack{
                        Image(systemName: "tortoise.fill").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                        Slider(value: $bledevice.speed, in: 0...255, onEditingChanged: { changed in
                            if(!changed){
                                self.bledevice.sendText(text: "speed:" + String(Int(bledevice.speed)))
                                print("report:" + String(Int(bledevice.speed)))
                            }
                        })
                        Image(systemName: "hare.fill").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                    }.padding(.bottom, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    HStack{
                        Image(systemName: "dial.min").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                        Slider(value: $bledevice.sensitivity, in: 0...255, onEditingChanged: { changed in
                            if(!changed){
                                self.bledevice.sendText(text: "sensitivity:" + String(Int(bledevice.sensitivity)))
                            }
                        }).accentColor(.red)
                        Image(systemName: "dial.max.fill").resizable().scaledToFit().frame(width: 20.0, height: 20.0)
                    }
                }.padding()
                HStack {
                    ProgressBar(value: $bledevice.value[0], bledevice: self.bledevice, index:0).frame(width: 30)
                    ProgressBar(value: $bledevice.value[1], bledevice: self.bledevice, index:1).frame(width: 30)
                    ProgressBar(value: $bledevice.value[2], bledevice: self.bledevice, index:2).frame(width: 30)
                    ProgressBar(value: $bledevice.value[3], bledevice: self.bledevice, index:3).frame(width: 30)
                    ProgressBar(value: $bledevice.value[4], bledevice: self.bledevice, index:4).frame(width: 30)
                    ProgressBar(value: $bledevice.value[5], bledevice: self.bledevice, index:5).frame(width: 30)
                    ProgressBar(value: $bledevice.value[6], bledevice: self.bledevice, index:6).frame(width: 30)
                }.foregroundColor(.blue).frame(height:sliderHeight)
                Spacer()
                HStack{
                Spacer()
                    Toggle(isOn: $bledevice.report){
                        Text("Report Data").frame(maxWidth: .infinity, alignment: .trailing)
                    }.padding()
                Spacer()
                }
                Spacer()
                HStack{
                    Button("Start") {
                        self.bledevice.sendText(text: "start:1")
                    }.padding()
                    Button("Stop") {
                        self.bledevice.sendText(text: "start:0")
                    }.padding()
                }
            }.navigationTitle("LED Master").navigationBarTitleDisplayMode(.inline).navigationBarItems(leading:
                NavigationLink(destination: SecondView()) {
                        Image(systemName: "gearshape.2.fill").imageScale(.large)
                },
                trailing:
                    NavigationLink(destination: ProgrammerView(bledevice:bledevice)) {
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

