//
//  ViewController.swift
//  AblyMacTest
//
//  Created by Ricardo Pereira on 08/11/2018.
//  Copyright © 2018 Whitesmith. All rights reserved.
//

import Cocoa
import Ably

class ViewController: NSViewController {

    let dataAdapter1 = MessagesDataAdapter()
    let dataAdapter2 = MessagesDataAdapter()

    var realtime1: ARTRealtime!
    var channel1: ARTRealtimeChannel!

    var realtime2: ARTRealtime!
    var channel2: ARTRealtimeChannel!

    let channelName = "mac"
    let appKey = <key>

    @IBOutlet weak var tableView1: NSTableView!
    @IBOutlet weak var textField1: NSTextField!
    @IBOutlet weak var sendButton1: NSButton!

    @IBOutlet weak var tableView2: NSTableView!
    @IBOutlet weak var textField2: NSTextField!
    @IBOutlet weak var sendButton2: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let options = ARTClientOptions(key: appKey)
        options.logLevel = .debug

        realtime1 = ARTRealtime(options: options)
        realtime2 = ARTRealtime(options: options)

        channel1 = realtime1.channels.get(channelName)
        channel2 = realtime2.channels.get(channelName)

        tableView1.delegate = dataAdapter1
        tableView1.dataSource = dataAdapter1

        tableView2.delegate = dataAdapter2
        tableView2.dataSource = dataAdapter2

        textField1.stringValue = ""
        textField1.placeholderString = "data"

        textField2.stringValue = ""
        textField2.placeholderString = "data"

        channel1.subscribe("client1") { [weak self] message in
            self?.dataAdapter1.messages.append(message.data as! String)
            self?.tableView1.reloadData()
        }

        channel1.subscribe("client2") { [weak self] message in
            self?.dataAdapter2.messages.append(message.data as! String)
            self?.tableView2.reloadData()
        }
    }

    @IBAction func handleSend1(_ sender: Any) {
        let message = textField1.stringValue
        textField1.stringValue = ""
        channel1.publish("client2", data: message) { error in
            print("Publish", error ?? "nil")
        }
    }

    @IBAction func handleSend2(_ sender: Any) {
        let message = textField2.stringValue
        textField2.stringValue = ""
        channel2.publish("client1", data: message) { error in
            print("Publish", error ?? "nil")
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}

class MessagesDataAdapter: NSObject, NSTableViewDataSource, NSTableViewDelegate {

    var messages: [String] = []

    func numberOfRows(in tableView: NSTableView) -> Int {
        return messages.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: nil) as? NSTableCellView else {
            return nil
        }
        cell.textField?.stringValue = messages[row]
        return cell
    }

}
