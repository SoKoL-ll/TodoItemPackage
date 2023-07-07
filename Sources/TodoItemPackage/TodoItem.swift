//
//  File.swift
//
//
//  Created by Alexandr Sokolov on 01.07.2023.
//

import Foundation

public enum Importance: String, CodingKey {
    case low
    case important
    case basic
}

let separatorForCSV = ","

public struct TodoItem {
    public let id: String
    public let text: String
    public let importance: Importance
    public let deadline: Date?
    public let isDone: Bool
    public let creationDate: Date
    public let modifiedDate: Date?
    
    public init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, isDone: Bool, creationDate: Date, modifiedDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate
    }
}

extension TodoItem {
    public static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any] else { return nil }
        
        guard
            let id = json["id"] as? String,
            let text = json["text"] as? String,
            let stringCreationDate = json["creationDate"] as? String
        else {
            return nil
        }
        
        let creationDate = Date.toDate(from: stringCreationDate) ?? Date()
        let imortance = (json["importance"] as? String).flatMap(Importance.init(rawValue:)) ?? .basic
        let deadline = (json["deadline"] as? String).flatMap { stringDate in Date.toDate(from: stringDate) }
        let isDone = (json["isDone"] as? Bool) ?? false
        let modifiedDate = (json["modifiedDate"] as? String).flatMap{ stringDate in Date.toDate(from: stringDate) }
        
        return TodoItem(id: id, text: text, importance: imortance, deadline: deadline, isDone: isDone, creationDate: creationDate, modifiedDate: modifiedDate)
    }
    
    public var json: Any {
        var data = [String: Any]()
        
        data["id"] = self.id
        data["text"] = self.text
        data["isDone"] = self.isDone
        data["creationDate"] = self.creationDate.toString()
        
        if self.importance != .basic {
            data["importance"] = self.importance.rawValue
        }
        
        if let deadline = self.deadline {
            data["deadline"] = deadline.toString()
        }
        
        if let modifiedDate = self.modifiedDate {
            data["modifiedDate"] = modifiedDate.toString()
        }

        return data
    }
}

extension TodoItem {
    public static func parse(csv: String) -> TodoItem? {
        let elements = csv.components(separatedBy: separatorForCSV)
        
        if elements.count < 6 {
            return nil
        }
        
        let id = elements[0]
        let text = elements[1]
        var importance: Importance = .basic
        var deadline: Date?
        var isDone: Bool
        var creationDate: Date
        var modifiedDate: Date?
        
        if elements[2] == Importance.low.rawValue || elements[2] == Importance.important.rawValue {
            importance = Importance.init(rawValue: elements[2]) ?? .basic
        }
        
        deadline = elements[3] != "" ? Date.toDate(from: elements[3]) : nil
        isDone = Bool(elements[4]) ?? false
        creationDate = Date.toDate(from: elements[5]) ?? Date()
        modifiedDate = elements[6] != "" ? Date.toDate(from: elements[6]) : nil
        
        return TodoItem(id: id, text: text, importance: importance, deadline: deadline, isDone: isDone, creationDate: creationDate, modifiedDate: modifiedDate)
    }
    
    public var csv: String {
        var csvToString = String()
        
        csvToString += "\(id)\(separatorForCSV)\(text)\(separatorForCSV)"
        csvToString += importance == .basic ? separatorForCSV : "\(importance.rawValue)\(separatorForCSV)"
        
        if let deadline = deadline {
            csvToString += "\(deadline.toString())\(separatorForCSV)"
        } else {
            csvToString += separatorForCSV
        }
        
        csvToString += "\(isDone)\(separatorForCSV)"
        csvToString += "\(creationDate.toString())\(separatorForCSV)"
        
        if let modifiedDate = modifiedDate {
            csvToString += "\(modifiedDate.toString())"
        }
        
        return csvToString
    }
}
