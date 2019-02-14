//
//  DiaryError.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import Foundation
enum DiaryError: Error {
    // Creation Errors
    case emptyDescription
    
    // Saving Errors
    case missingContextDuringSave

}
