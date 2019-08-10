//
//  ViewController.swift
//  depthOfFieldCalculator
//
//  Created by Martin Bednar on 09/08/2019.
//  Copyright © 2019 Martin Bednar. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var cameraType: UIPickerView!
    @IBOutlet weak var apperture: UIPickerView!
    @IBOutlet weak var metric: UIPickerView!
    @IBOutlet weak var focalLength: UITextField!
    @IBOutlet weak var focusDistance: UITextField!
    @IBOutlet weak var furthestAcceptableSharpness: UILabel!
    @IBOutlet weak var totalDepthOfField: UILabel!
    @IBOutlet weak var nearestAcceptableSharpness: UILabel!
    @IBOutlet var viewBackground: UIView!
    
    @IBAction func calculateit(_ sender: UIButton) {
        furthestAcceptableSharpness.text = formatFurthestAcceptableSharpness()
        nearestAcceptableSharpness.text = formatNearestAcceptableSharpness()
        totalDepthOfField.text = formatTotalDepthOfField()
    }
    
    let cameras:[(name: String, value: Double)] = [("35 mm (Full Frame)", 0.03200), ("APSC", 0.02231)]
    let appertures:[(name: String, value: Double)] = [("f/1.2",1.2), ("f/1.4",1.4), ("f/1.8",1.8),("f/2",2.0),("f/2.8",2.8),("f/3.5",3.5),("f/4",4),("f/5.6", 5.6),("f/8",8.0),("f/11",11.0),("f/16", 16.0),("f/22", 22.0),("f/32", 32.0),("f/64", 64.0)]
    let metrics:[(name: String, value: Double)] = [("meters",1.0), ("cm",100), ("feets", 3.2808), ("inches", 39.37)]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var element : String = ""
        if(pickerView == apperture){
            element = appertures[row].name
        }
        if(pickerView == cameraType){
            element = cameras[row].name
        }
        if(pickerView == metric){
            element = metrics[row].name
        }
        return element;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var element : Int = 0
        if(pickerView == apperture){
            element = appertures.count
        }
        if(pickerView == cameraType){
            element = cameras.count
        }
        if(pickerView == metric){
            element = metrics.count
        }
        return element
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        furthestAcceptableSharpness.text = formatFurthestAcceptableSharpness()
        nearestAcceptableSharpness.text = formatNearestAcceptableSharpness()
        totalDepthOfField.text = formatTotalDepthOfField()
        viewBackground.backgroundColor = UIColor.systemBackground
        focalLength.textColor = UIColor.label
        focusDistance.textColor = UIColor.label
        // Do any additional setup after loading the view.
    }
    
    func countHyperFocal() -> Double{
        let cameraFormat = cameras [cameraType.selectedRow(inComponent: 0)].value
        let appertureType = appertures [apperture.selectedRow(inComponent: 0)].value
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        let focalLengthValue = Double(focalLength.text!) ?? 0.0
        
        let eyesight = 1.0
        let viewDistance = (25.0 / 100.0)
        let printSize = 10.0
        
        let CoC = cameraFormat * eyesight * (viewDistance / 0.25) * (10 / printSize);
        print("Coc")
        print(CoC)
        let hyperfocal = (focalLengthValue * focalLengthValue) / (appertureType * CoC);
        print("HyperFocal")
        print(hyperfocal)
        return hyperfocal
    }

    func formatNearestAcceptableSharpness() -> String {
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        let nearestAcceptableSharpness = countNearestAcceptableSharpness()
        print(nearestAcceptableSharpness)
        return String(format:"%.2f", nearestAcceptableSharpness * metricsType) + " " + metrics [metric.selectedRow(inComponent: 0)].name
    }
    
    func countNearestAcceptableSharpness() -> Double {
        
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        let focusDistanceValue = Double(focusDistance.text!) ?? 0.0
        let focusDistanceMm = (focusDistanceValue / metricsType )*1000
        let focalLengthValue = Double(focalLength.text!) ?? 0.0
        
        let hyperfocal = countHyperFocal()
        
        var nearestAcceptableSharpness = (hyperfocal * focusDistanceMm) / (hyperfocal + (focusDistanceMm - focalLengthValue));
        nearestAcceptableSharpness = nearestAcceptableSharpness / 1000
        return nearestAcceptableSharpness
    }
    
    func formatFurthestAcceptableSharpness() -> String{
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        var retVal = ""
        let furthestAcceptableSharpness = countFurthestAcceptableSharpness()
        if ( furthestAcceptableSharpness < 0 ) {
            retVal = "Infinity"
        }
        else {
            retVal = String(format:"%.2f",metricsType*furthestAcceptableSharpness ) + " " + metrics [metric.selectedRow(inComponent: 0)].name
        }
        
        return retVal
    }
    
    func countFurthestAcceptableSharpness() -> Double{
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        let focusDistanceValue = Double(focusDistance.text!) ?? 0.0
        let focalLengthValue = Double(focalLength.text!) ?? 0.0
        let focusDistanceMm = (focusDistanceValue / metricsType )*1000
        
        let hyperfocal = countHyperFocal()
        
        let furthestAcceptableSharpness = (hyperfocal * focusDistanceMm) / (hyperfocal - (focusDistanceMm - focalLengthValue));
        return furthestAcceptableSharpness/1000

    }
    
    func formatTotalDepthOfField() -> String{
        var retVal = ""
        let metricsType = metrics [metric.selectedRow(inComponent: 0)].value
        let furthest = countFurthestAcceptableSharpness()
        if(furthest < 0)
        {
            retVal = "Infinity"
        }
        else{
            let nearest = countNearestAcceptableSharpness()
            let total = furthest - nearest
            retVal = String(format:"%.2f",total*metricsType ) + " " + metrics [metric.selectedRow(inComponent: 0)].name
        }
        return retVal
    }
    
}

