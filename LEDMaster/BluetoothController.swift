//
//  BluetoothController.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 17.05.21.
//

import CoreBluetooth


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
