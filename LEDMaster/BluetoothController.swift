//
//  BluetoothController.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 17.05.21.
//

import CoreBluetooth
import SwiftUI

class BluetoothController: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var firstcolor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2) {
        didSet {
            let hue = rgbtohue(color: firstcolor)
            self.sendText(text: "color1:" + String(Int(hue*255.0)))
        }
    }
    @Published var secondcolor = Color(.sRGB, red: 0.98, green: 0.9, blue: 0.2) {
        didSet {
            let hue = rgbtohue(color: secondcolor)
            self.sendText(text: "color2:" + String(Int(hue*255.0)))
        }
    }
    @Published var currentState: String
    @Published var value: [UInt8]
    @Published var brightness: Double = 0
    @Published var speed: Double = 0 {
        didSet {
            print(speed)
        }
    }
    @Published var report: Bool = false {
        didSet {
            self.sendText(text: "report:" + String(report ? 1 : 0))
            print("report:" + String(report ? 1 : 0))
        }
    }
    @Published var staticColor: Bool = false {
        didSet {
            self.sendText(text: "static:" + String(staticColor ? 1 : 0))
            print("static:" + String(staticColor ? 1 : 0))
        }
    }
    @Published var sensitivity: Double = 0
    @Published var selectedEffect = 0 {
        didSet {
            self.sendText(text: "mode:" + String(selectedEffect))
            print("mode:" + String(selectedEffect))
        }
    }
    @Published var selectedCoordinator = 0 {
        didSet {
            self.sendText(text: "coordinatormode:" + String(selectedCoordinator))
            print("coordinator:" + String(selectedCoordinator))
        }
    }
    
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
    
    func rgbtohue(color: Color) -> CGFloat {
        var hue : CGFloat = 0.0
        var saturation : CGFloat = 0.0
        var brightness : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        UIColor(color).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return hue
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
        case .unsupported:
            print("Bluetooth is not supported")
        default:
            print("Unknown state")
            self.currentState = "Unknown"
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
        self.sendText(text: "request")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let received: [UInt8] = Array(characteristic.value!)
        //print(received)
        if received.count == 7 {
            self.value = received
        } else if received.count == 8 {
            brightness = Double(received[0])
            sensitivity = Double(received[1])
            speed = Double(received[2])
            selectedEffect = Int(received[3])
            selectedCoordinator = Int(received[5])
            report = received[6] != 0
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Did write value")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error changing notification state: %@", error?.localizedDescription ?? "unknown error");
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
