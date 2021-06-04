//
//  AnimationProgrammer.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 23.05.21.
//
import SwiftUI
import MediaPlayer

struct Timeline :View {
    @Binding var state: [[Int]]
    @Binding var scrollTarget: Int
    
    var body: some View {
        ZStack {
            ScrollView {
            ScrollViewReader { proxy in
                LazyVStack(alignment: .center) {
                ForEach(0...999, id: \.self) { count in
                    HStack(){
                        Text("\(count)")
                        Spacer()
                        LEDBlob(value: $state[count][0]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][1]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][2]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][3]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][4]).frame(width: 30, height: 30)
                        LEDBlob(value: $state[count][5]).frame(width: 30, height: 30)
                    }.padding(5).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).id(count)
                }
                }.padding(EdgeInsets(top: 300, leading: 0, bottom: 0, trailing: 0)).onChange(of: scrollTarget) { target in
                    if target != 0 {
                        withAnimation (.linear(duration: 1)) {
                            proxy.scrollTo(target, anchor: .center)
                        }
                    }else{
                        proxy.scrollTo(target, anchor: .center)
                    }
                    }
                }
            }
            Rectangle().frame(height:20)
        }
    }
}

struct ProgrammerView: View {
    @ObservedObject var bledevice = BluetoothController()
    @State var state: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 1000)
    @State private var selectedEffect = 0
    @ObservedObject var musicPlayer = MusicManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Timeline(state:$state, scrollTarget:$musicPlayer.time)
            }.navigationTitle("Animation Programmer").navigationBarTitleDisplayMode(.inline).navigationBarItems(
                leading:
                    Picker("BPM", selection: $selectedEffect) {
                         ForEach(Array(stride(from: 100, to: 200, by: 5)), id: \.self) {
                            Text(String($0)) //.tag($0)
                         }
                    }.pickerStyle(MenuPickerStyle()),
                trailing:
                    HStack {
                        NavigationLink(destination: SecondView()) {
                                Image(systemName: "gearshape.2.fill").imageScale(.large)
                        }
                        Button(action: {
                        }) {
                            Image(systemName: "speedometer").imageScale(.large)
                        }
                    }
            )
        }.navigationBarItems(trailing: Button("Save"){
            print(state)
        }).toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    
                }) { Text("---") }
                Spacer()
                Button(action: {musicPlayer.play()}) {Image(systemName: "play.fill")}
                Spacer()
                Button(action: {
                    musicPlayer.pause()
                }) {
                    Image(systemName: "pause.fill")
                }
                Spacer()
                Button(action: {
                    musicPlayer.beginning()
                }) {
                    Image(systemName: "arrow.left.to.line.alt")
                }
                Spacer()
                Button(action: {
                    musicPlayer.next()
                }) {
                    Image(systemName: "chevron.right.2")
                }
            }
        }
    }
}

struct AnimationProgrammer_Previews: PreviewProvider {
    static var previews: some View {
        ProgrammerView()
    }
}
