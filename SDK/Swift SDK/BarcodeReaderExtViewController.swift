//
//  BarcodeReaderExtViewController.swift
//  Swift SDK
//
//  Created by Yuji on 2015/**/**.
//  Copyright © 2015年 Star Micronics. All rights reserved.
//

import UIKit

class BarcodeReaderExtViewController: CommonViewController, StarIoExtManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    enum CellParamIndex: Int {
        case barcodeData = 0
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    var cellArray: NSMutableArray!
    
    var starIoExtManager: StarIoExtManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.commentLabel.text = ""
        
        self.commentLabel.adjustsFontSizeToFitWidth = true
        
        self.appendRefreshButton(#selector(BarcodeReaderExtViewController.refreshBarcodeReader))
        
        self.cellArray = NSMutableArray()
        
        self.starIoExtManager = StarIoExtManager(type: StarIoExtManagerType.onlyBarcodeReader,
                                             portName: AppDelegate.getPortName(),
                                         portSettings: AppDelegate.getPortSettings(),
                                      ioTimeoutMillis: 10000)                                      // 10000mS!!!
        
        self.starIoExtManager.cashDrawerOpenActiveHigh = AppDelegate.getCashDrawerOpenActiveHigh()
        
        self.starIoExtManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BarcodeReaderExtViewController.applicationWillResignActive), name: NSNotification.Name(rawValue: "UIApplicationWillResignActiveNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BarcodeReaderExtViewController.applicationDidBecomeActive),  name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),  object: nil)
        
        GlobalQueueManager.shared.serialQueue.async {
            DispatchQueue.main.async {
//              self.refreshBarcodeReader()
                
                self.blind = true
                
                defer {
                    self.blind = false
                }
                
                self.starIoExtManager.disconnect()
                
                if self.starIoExtManager.connect() == false {
                    self.showSimpleAlert(title: "Communication Result",
                                         message: "Fail to openPort",
                                         buttonTitle: "OK",
                                         buttonStyle: .default,
                                         completion: { _ in
                                            self.commentLabel.text = """
                                            Check the device. (Power and Bluetooth pairing)
                                            Then touch up the Refresh button.
                                            """
                                            
                                            self.commentLabel.textColor = UIColor.red
                                            
                                            self.beginAnimationCommantLabel()
                    })
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        GlobalQueueManager.shared.serialQueue.async {
            self.starIoExtManager.disconnect()
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIApplicationWillResignActiveNotification"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UIApplicationDidBecomeActiveNotification"),  object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        self.beginAnimationCommantLabel()
        
        GlobalQueueManager.shared.serialQueue.async {
            DispatchQueue.main.async {
                self.refreshBarcodeReader()
            }
        }
    }
    
    @objc func applicationWillResignActive() {
        GlobalQueueManager.shared.serialQueue.async {
            self.starIoExtManager.disconnect()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellParam: [String] = self.cellArray[indexPath.row] as! [String]
        
        let cellIdentifier: String = "UITableViewCellStyleValue1"
        
//      var cell: UITableViewCell! = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var cell: UITableViewCell! = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: cellIdentifier)
        }
        
        if cell != nil {
            cell      .textLabel!.text = cellParam[CellParamIndex.barcodeData.rawValue]
            cell.detailTextLabel!.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Contents"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func refreshBarcodeReader() {
        self.blind = true
        
        defer {
            self.blind = false
        }
        
        self.cellArray.removeAllObjects()
        
        self.starIoExtManager.disconnect()
        
        if self.starIoExtManager.connect() == false {
            self.showSimpleAlert(title: "Communication Result",
                                 message: "Fail to openPort",
                                 buttonTitle: "OK",
                                 buttonStyle: .default,
                                 completion: { _ in
                                    self.commentLabel.text = """
                                    Check the device. (Power and Bluetooth pairing)
                                    Then touch up the Refresh button.
                                    """
                                    
                                    self.commentLabel.textColor = UIColor.red
                                    
                                    self.beginAnimationCommantLabel()
            })
        }
        
        self.tableView.reloadData()
    }
    
    func didBarcodeDataReceive(_ manager: StarIoExtManager!, data: Data!) {
        NSLog("%@", MakePrettyFunction())
        
        guard let str = String(data: data, encoding: .ascii) else {
            return
        }
        
        var lines = [String]()
        
        str.enumerateLines { (line, stop) -> () in
            lines.append(line)
        }
        
        for bcrStr in lines {
            if self.cellArray.count > 30 {     // Max.30Line
                self.cellArray.removeObject(at: 0)
                
                self.tableView.reloadData()
            }
            
            self.cellArray.add([bcrStr])
        }
        
        self.tableView.reloadData()
        
        let indexPath: IndexPath = IndexPath(row: self.cellArray.count - 1, section: 0)
        
        self.tableView.selectRow(at: indexPath, animated:true, scrollPosition: UITableView.ScrollPosition.bottom)
        
        self.tableView.deselectRow(at: indexPath, animated:true)
    }
    
    func didBarcodeReaderImpossible(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Barcode Reader Impossible."
        
        self.commentLabel.textColor = UIColor.red
        
        self.beginAnimationCommantLabel()
    }
    
    func didBarcodeReaderConnect(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Barcode Reader Connect."
        
        self.commentLabel.textColor = UIColor.blue
        
        self.beginAnimationCommantLabel()
    }
    
    func didBarcodeReaderDisconnect(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Barcode Reader Disconnect."
        
        self.commentLabel.textColor = UIColor.red
        
        self.beginAnimationCommantLabel()
    }
    
    func didAccessoryConnectSuccess(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Accessory Connect Success."
        
        self.commentLabel.textColor = UIColor.blue
        
        self.beginAnimationCommantLabel()
    }
    
    func didAccessoryConnectFailure(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Accessory Connect Failure."
        
        self.commentLabel.textColor = UIColor.red
        
        self.beginAnimationCommantLabel()
    }
    
    func didAccessoryDisconnect(_ manager: StarIoExtManager!) {
        NSLog("%@", MakePrettyFunction())
        
        self.commentLabel.text = "Accessory Disconnect."
        
        self.commentLabel.textColor = UIColor.red
        
        self.beginAnimationCommantLabel()
    }
    
    func didStatusUpdate(_ manager: StarIoExtManager!, status: String!) {
        NSLog("%@", MakePrettyFunction())
        
//      self.commentLabel.text = status
//
//      self.commentLabel.textColor = UIColor.green
//
//      self.beginAnimationCommantLabel()
    }
    
    fileprivate func beginAnimationCommantLabel() {
        UIView.beginAnimations(nil, context: nil)
        
        self.commentLabel.alpha = 0.0
        
        UIView.setAnimationDelay             (0.0)                             // 0mS!!!
        UIView.setAnimationDuration          (0.6)                             // 600mS!!!
        UIView.setAnimationRepeatCount       (Float(UINT32_MAX))
        UIView.setAnimationRepeatAutoreverses(true)
        UIView.setAnimationCurve             (UIView.AnimationCurve.easeIn)
        
        self.commentLabel.alpha = 1.0
        
        UIView.commitAnimations()
    }
}
