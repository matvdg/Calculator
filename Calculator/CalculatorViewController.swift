//
//  ViewController.swift
//  Calculator
//
//  Created by Mathieu Vandeginste on 02/05/2016.
//  Copyright © 2016 Mathieu Vandeginste. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    private var isInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
    private var screenValue: Double {
        get {
            return Double(self.screen.text!)!
        }
        set {
            self.screen.text! = String(newValue)
        }
    }
    
    @IBOutlet weak private var screen: UILabel!
    @IBOutlet weak var historyScreen: UILabel!
    
    @IBAction private func touchDigit(sender: UIButton) {
        if self.isInTheMiddleOfTyping {
            if sender.currentTitle! == "." {
                if !self.screen.text!.containsString(".") {
                    self.screen.text! += sender.currentTitle!
                }
            } else {
                self.screen.text! += sender.currentTitle!
            }
        } else {
            self.isInTheMiddleOfTyping = true
            self.historyScreen.text! = " "
            self.screen.text! = sender.currentTitle!
        }
    }
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if self.isInTheMiddleOfTyping {
            self.brain.setOperand(self.screenValue)
            self.isInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            self.brain.performOperation(mathematicalSymbol)
            self.screenValue = self.brain.result
            self.historyScreen.text = self.brain.history
        }
    }
    
    
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if let backup = savedProgram {
            brain.program = backup
            screenValue = brain.result
        }
    }
    
    @IBAction func clearMemory() {
        savedProgram = nil
    }
    
    
}

