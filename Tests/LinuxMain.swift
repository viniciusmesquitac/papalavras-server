//
//  LinuxMain.swift
//  
//
//  Created by Vinicius Mesquita on 05/10/20.
//

import XCTest
import AppTests

var tests = [XCTestCaseEntry]()
tests += AppTests.__allTests()

XCTMain(tests)
