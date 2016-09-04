//
//  FirstViewController.swift
//  Charting Demo
//
//  Created by Nikhil Kalra on 12/5/14.
//  Copyright (c) 2014 Nikhil Kalra. All rights reserved.
//

import UIKit
import JBChart
import Foundation

class FirstViewController: UIViewController, JBBarChartViewDelegate, JBBarChartViewDataSource {

    @IBOutlet weak var barChart: JBBarChartView!
    @IBOutlet weak var informationLabel: UILabel!
    
    
    var chartLegend = [String]()
    var chartData = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let resultado = getIP()
        
        getParametros("2016/08/31", fechaFin: "2016/08/31")
        sleep(3)
        view.backgroundColor = UIColor.darkGrayColor()
        //chartSetup()
        
    }
    
    func chartSetup(){
        // bar chart setup
        barChart.backgroundColor = UIColor.darkGrayColor()
        barChart.delegate = self
        barChart.dataSource = self
        barChart.minimumValue = 0
        barChart.maximumValue = CGFloat(chartData.maxElement()!)
        
        
        barChart.reloadData()
        
        barChart.setState(.Collapsed, animated: false)

    }
    
    
    func grafic(){
        
        let footerView = UIView(frame: CGRectMake(0, 0, barChart.frame.width, 16))
        
        print("viewDidLoad: \(barChart.frame.width)")
        
        let footer1 = UILabel(frame: CGRectMake(0, 0, barChart.frame.width/2 - 8, 16))
        footer1.textColor = UIColor.whiteColor()
        footer1.text = "\(chartLegend[0])"
        
        let footer2 = UILabel(frame: CGRectMake(barChart.frame.width/2 - 8, 0, barChart.frame.width/2 - 8, 16))
        footer2.textColor = UIColor.whiteColor()
        footer2.text = "\(chartLegend[chartLegend.count - 1])"
        footer2.textAlignment = NSTextAlignment.Right
        
        footerView.addSubview(footer1)
        footerView.addSubview(footer2)
        
        let header = UILabel(frame: CGRectMake(0, 0, barChart.frame.width, 50))
        header.textColor = UIColor.whiteColor()
        header.font = UIFont.systemFontOfSize(24)
        header.text = "Grafica Chubidubi"
        header.textAlignment = NSTextAlignment.Center
        
        barChart.footerView = footerView
        barChart.headerView = header

    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        grafic()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // our code
        barChart.reloadData()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("showChart"), userInfo: nil, repeats: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        hideChart()
    }
    
    func hideChart() {
        barChart.setState(.Collapsed, animated: true)
    }
    
    func showChart() {
        barChart.setState(.Expanded, animated: true)
    }
    
    // MARK: JBBarChartView
    
    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(chartData.count)
    }
    
    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return CGFloat(chartData[Int(index)])
    }
    
    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return (index % 2 == 0) ? UIColor.lightGrayColor() : UIColor.whiteColor()
    }
    
    func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt) {
        let data = chartData[Int(index)]
        let key = chartLegend[Int(index)]
        
        informationLabel.text = "numRonal = \(key) total= \(data)"
    }
    
    func didDeselectBarChartView(barChartView: JBBarChartView!) {
        informationLabel.text = ""
    }
    
    
    
    func getIP() -> ([String],[Int])
    {
        let posEndpoint: String = "http://luinux.hol.es/obtener_alumnos.php"
        //let posEndpoint: String = "http://luinux.hol.es/obtener_alumno_por_id.php?fechaIni=2016/08/31&fechaFin=2016/08/31"
        let url = NSURL(string: posEndpoint)!
        var numRonal = [String]()
        var total = [Int]()
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(url,completionHandler:
            {(data:NSData?,response:NSURLResponse?,error:NSError?) -> Void in
                //Read de JSON
                do{
                    if let ipString = NSString(data:data!, encoding:NSUTF8StringEncoding){

                        
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                            
                            if let blogs = json["alumnos"] as? [[String: AnyObject]] {
                                for blog in blogs {
                                    if let num = blog["numRonal"] as? String {
                                        self.chartLegend.append(num)
                                        
                                    }
                                    if let tot = blog["total"] as? String {
                                        let myInt: Int? = Int(tot)
                                        self.chartData.append(myInt!)
                                    }
                                }
                            }
                        } catch {
                            print("error serializing JSON: \(error)")
                        }
                        
                        print(self.chartLegend)
                    }
                    
                    
                }catch{
                    print("bad thing happened")
                }
        }).resume()
        
        return (numRonal, total)
    }
    
    func getParametros(fechaIni: String, fechaFin: String){
        // Send HTTP GET Request
        
        // Define server side script URL
        let scriptUrl = "http://luinux.hol.es/obtener_alumno_por_id.php?fechaIni=\(fechaIni)&fechaFin=\(fechaFin)"
        // Add one parameter
        let urlWithParams = scriptUrl
        // Create NSURL Ibject
        let myUrl = NSURL(string: urlWithParams);
        
        // Creaste URL Request
        let request = NSMutableURLRequest(URL:myUrl!);
        
        // Set request HTTP method to GET. It could be POST as well
        request.HTTPMethod = "GET"
        
        // If needed you could add Authorization header value
        // Add Basic Authorization
        /*
         let username = "myUserName"
         let password = "myPassword"
         let loginString = NSString(format: "%@:%@", username, password)
         let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
         let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
         request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
         */
        
        // Or it could be a single Authorization Token value
        //request.addValue("Token token=884288bae150b9f2f68d8dc3a932071d", forHTTPHeaderField: "Authorization")
        
        // Excute HTTP Request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            // Check for error
            if error != nil
            {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("responseString = \(responseString)")
            
            
            // Convert server json response to NSDictionary
            do {
                let object = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if let dictionary = object as? [String: AnyObject] {
                    
                    self.readJSONObject(dictionary)
                    self.chartSetup()
                }
            } catch {
                // Handle Error
            }
            
        }
        task.resume()
    }
    
    func readJSONObject(object: [String: AnyObject]) {
        let users = object["alumno"] as? [[String: AnyObject]]
        for user in users! {
            let name = user["numRonal"] as? String
            let age = user["total"] as? String
            
            print(name)
            print(age)
            
            self.chartLegend.append(name!)
            let myInt: Int? = Int(age!)
            self.chartData.append(myInt!)
        }
        
        
    }
    
    
}

