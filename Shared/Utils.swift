//
//  Utils.swift
//  CRAttributesDemo
//
//  Created by Mateusz Lapsa-Malawski on 28/12/2021.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()
