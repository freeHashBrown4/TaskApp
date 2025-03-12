//
//  Task.swift
//  TaskApp
//
//  Created by Muhammad Choudhary on 2025-03-07.
//


import Foundation

struct Task: Codable, Identifiable {
    var id: String?
    var title: String
    var dueDate: String
    var description: String
    var priority: String
    var status: String
}


