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
    
    private var savedProgram: CalculatorBrain.PropertyList?
    
    private var screenValue: Double? {
        get {
            return Double(self.screen.text!)
        }
        set (new){
            if let newValue = new {
                self.screen.text! = newValue.stringFromDouble
            } else {
                self.screen.text! = " "
            }
        }
    }
    @IBOutlet weak private var screen: UILabel!
    @IBOutlet weak private var historyScreen: UILabel!
    
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
            if self.historyScreen.text!.containsString("=") {
                self.historyScreen.text = " "
            }
            self.isInTheMiddleOfTyping = true
            self.screen.text! = sender.currentTitle!
        }
    }
    
    
    @IBAction private func performOperation(sender: UIButton) {
        if self.isInTheMiddleOfTyping {
            self.brain.setOperand(self.screenValue!)
            self.isInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            self.brain.performOperation(mathematicalSymbol)
            self.screenValue = self.brain.result
            if self.brain.isPartialResult {
                 self.historyScreen.text = self.brain.description + " ... "
            } else {
                if self.brain.description != " " {
                    self.historyScreen.text = self.brain.description + " = "
                } else {
                    self.historyScreen.text = " "
                }
            }
        }
    }
    
    @IBAction private func save() {
        savedProgram = brain.program
    }
    
    @IBAction private func restore() {
        if let backup = savedProgram {
            brain.program = backup
            screenValue = brain.result
        }
    }
    
    @IBAction private func clearMemory() {
        savedProgram = nil
    }
    
    @IBAction private func swipeLeft(sender: UISwipeGestureRecognizer) {
        if screen.text! != "0" {
            screen.text! = String(screen.text!.characters.dropLast())
        }
        if screen.text!.characters.isEmpty {
            screen.text! = "0"
            isInTheMiddleOfTyping = false
        }
    }
    
}

