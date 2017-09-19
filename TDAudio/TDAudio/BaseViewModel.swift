//
//  BaseViewModel.swift
//  Audio
//
//  Created by TH on 9/11/17.
//  Copyright © 2017 Essential Studio. All rights reserved.
//

import Foundation

protocol BaseViewDelegate : class {
    
}

protocol BaseViewModelInterface {
    associatedtype ViewDelegate
    
    var viewDelegate: ViewDelegate? {get set}
}
