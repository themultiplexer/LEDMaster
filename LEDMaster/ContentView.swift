//
//  ContentView.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 12.04.21.
//

import SwiftUI
import CoreBluetooth

struct ProgressBar: View {
    @Binding var value: UInt8
    
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
            }.cornerRadius(45.0)
        }
    }
}

struct LEDBlob: View {
    @Binding var value: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Text("\(value)").frame(width: geometry.size.width , height: geometry.size.height).multilineTextAlignment(.center)
            }.cornerRadius(45.0).gesture(
                TapGesture()
                    .onEnded { _ in
                        value = value < 3 ? value+1 : 0
                    }
            )
        }
    }
}

struct ContentView: View {
    @ObservedObject var bledevice = BluetoothController()
    @State private var brightness: Double = 0
    @State private var state: [Int] = [0,0,0]
    
    var body: some View {
        VStack {
            Text("LED MASTER").font(Font.system(size: 50.0).weight(.bold)).padding()
            Spacer()
            HStack{
                Button("Connect") {
                    print("Button tapped!")
                    self.bledevice.connect()
                }.font(Font.system(size: 20.0).weight(.bold)).padding()
                Text("State:  \(bledevice.currentState)").padding()
            }
            Slider(value: $brightness, in: 0...100).padding().accentColor(.red).overlay(RoundedRectangle(cornerRadius: 15.0).stroke(lineWidth: 2.0).foregroundColor(.red)).padding()
            HStack {
                ProgressBar(value: $bledevice.value[0]).frame(width: 20)
                ProgressBar(value: $bledevice.value[1]).frame(width: 20)
                ProgressBar(value: $bledevice.value[2]).frame(width: 20)
                ProgressBar(value: $bledevice.value[3]).frame(width: 20)
                ProgressBar(value: $bledevice.value[4]).frame(width: 20)
                ProgressBar(value: $bledevice.value[5]).frame(width: 20)
                ProgressBar(value: $bledevice.value[6]).frame(width: 20)
            }.frame(height:200)
            HStack{
                LEDBlob(value: $state[0]).frame(width: 30, height: 30)
                LEDBlob(value: $state[1]).frame(width: 30, height: 30)
                LEDBlob(value: $state[2]).frame(width: 30, height: 30)
            }
            HStack{
                Button("LEDs ON") {
                    self.bledevice.sendText(text: "ON")
                }.padding()
                Button("LEDs OFF") {
                    self.bledevice.sendText(text: "OFF")
                }.padding()
            }
            Spacer()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    class BluetoothController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
      
        @Published var currentState: String
        @Published var value: [UInt8]
        
        var myPeripheal:CBPeripheral?
        var myCharacteristic:CBCharacteristic?
        var manager:CBCentralManager?

        let serviceUUID = CBUUID(string: "04ea24fa-a8da-46a9-aef9-fbb78dbfda3d")
        let periphealUUID = CBUUID(string: "73756622-8710-E2AB-9432-BE1F8B95C3F0")

        override init() {
            self.currentState = "Idle"
            self.value = [0,0,0,0,0,0,0]
            super.init()
            manager = CBCentralManager(delegate: self, queue: nil)
        }
        
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            print("Discovered: \(peripheral.identifier.uuidString)")
            if peripheral.identifier.uuidString == periphealUUID.uuidString {
                self.currentState = "Connecting"
                myPeripheal = peripheral
                myPeripheal?.delegate = self
                manager?.connect(myPeripheal!, options: nil)
                manager?.stopScan()
            }
        }
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            peripheral.discoverServices([serviceUUID])
            print("Connected to " +  peripheral.name!)
            self.currentState = "Connected"
        }
        
        func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
            print("Disconnected from " +  peripheral.name!)
            self.currentState = "Disconnected"
            myPeripheal = nil
            myCharacteristic = nil
        }
        
        func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
            print(error!)
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
            case .poweredOff:
                print("Bluetooth is switched off")
                self.currentState = "Bluetooth is off"
            case .poweredOn:
                print("Bluetooth is switched on")
            case .unsupported:
                print("Bluetooth is not supported")
            default:
                print("Unknown state")
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                print("Discovered")
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            guard let characteristics = service.characteristics else { return }
            myCharacteristic = characteristics[0]
            myPeripheal?.delegate = self
            myPeripheal?.setNotifyValue(true, for: characteristics[0])
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            let received: [UInt8] = Array(characteristic.value!)
            //print(received)
            if received.count == 7 {
                self.value = received
            }
        }
        
        func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
            print("Did write value")
        }
        
        func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            if (error != nil) {
                print("Error changing notification state: %@", error?.localizedDescription);
            }

            // Notification has started
            if (characteristic.isNotifying) {
                print("Notification began on %@", characteristic);
            }
        }
        
        func sendText(text: String) {
            if (myPeripheal != nil && myCharacteristic != nil) {
                let data = text.data(using: .utf8)
                myPeripheal!.writeValue(data!,  for: myCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            }
        }
        
        func connect() {
            self.currentState = "Scanning"
            manager?.stopScan()
            manager?.scanForPeripherals(withServices:[serviceUUID], options: nil)
        }
    }
}


