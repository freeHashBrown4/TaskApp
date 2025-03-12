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
    
    enum CodingKeys: String, CodingKey {
        case id = "_id" // Map Swift 'id' to MongoDB '_id'
        case title
        case dueDate
        case description
        case priority
        case status
    }
}


