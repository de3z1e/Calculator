//
//  ViewController.swift
//  Calculator
//
//  Created by Dimitry Zadorozny on 5/6/17.
//  Copyright © 2017 Dimitry Zadorozny. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var operationSequence: UILabel!

    override func viewDidLoad() {
        display.layer.borderWidth = 0.5
        display.layer.borderColor = UIColor.black.cgColor
        buttons.forEach({button in
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.black.cgColor
        })
    }
    
    var userIsInTheMiddleOfTyping = false
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            if newValue.remainder(dividingBy: 1) == 0 {
                display.text = String(Int(newValue))
            } else {
                display.text = String(newValue)
            }
            
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + (digit == "." && textCurrentlyInDisplay.contains(".") ? "" : digit)
        } else {
            display.text = (digit == "." ? "0." : digit)
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        operationSequence.text = brain.description
    }


}

