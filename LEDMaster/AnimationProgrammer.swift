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
    @State var peak = 4.0
    
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
                        }.padding(7).border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/).id(count).onTapGesture {
                            print("Rectangle onTapGesture")
                          }
                    }
                    }.padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 14)).onChange(of: scrollTarget) { target in
                        if target % 10 == 0 {
                            proxy.scrollTo(target, anchor: .top)
                        }
                    }
                }
            }.padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
            VStack {
                Rectangle().stroke(Color.green, lineWidth: CGFloat(peak)).frame(height:48).offset(y:CGFloat(scrollTarget % 10 * 52)) .animation(Animation.default.speed(1)).padding(12).onChange(of: scrollTarget) { target in
                    if state[target][0] == 1 {
                        peak=6.0
                    } else {
                        peak=4.0
                    }
                }
                Spacer()
            }
        }
    }
}

struct ProgrammerView: View {
    @ObservedObject var bledevice : BluetoothController
    @State var state: [[Int]] = Array(repeating: Array(repeating: 0, count: 6), count: 1000)
    @State private var bpm = 0
    @ObservedObject var musicPlayer = MusicManager(bpm:128,timestep:1)
    
    var body: some View {
        NavigationView {
            VStack {
                Timeline(state:$state, scrollTarget:$musicPlayer.time)
            }.navigationTitle("Animation Programmer").navigationBarTitleDisplayMode(.inline).navigationBarItems(
                leading:
                    Picker("BPM", selection: $bpm) {
                         ForEach(Array(stride(from: 100, to: 200, by: 5)), id: \.self) {
                            Text(String($0))
                         }
                    }.pickerStyle(MenuPickerStyle()).onChange(of: bpm) { bpm2 in
                        print("Changed", bpm, bpm2)
                        musicPlayer.setBPM(bpm:bpm)
                    },
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
                Button(action: {  }) { Text(musicPlayer.trackName) }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    musicPlayer.play()
                    self.bledevice.sendText(text: "start:1")
                }) {Image(systemName: "play.fill") }
                Spacer()
                Button(action: {
                    musicPlayer.pause()
                    self.bledevice.sendText(text: "start:1")
                }) { Image(systemName: "pause.fill") }
                Spacer()
                Button(action: { musicPlayer.beginning() }) { Image(systemName: "arrow.left.to.line.alt") }
                Spacer()
                Button(action: { musicPlayer.next() }) { Image(systemName: "chevron.right.2") }
            }
        }
    }
}

struct AnimationProgrammer_Previews: PreviewProvider {
    static var previews: some View {
        ProgrammerView(bledevice: BluetoothController())
    }
}
