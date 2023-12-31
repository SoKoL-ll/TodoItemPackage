import Foundation

@available(iOS 16.0, *)
public class FileCache {
    let headOfCSVFile = "id,text,importance,deadline,isDone,creationDate,modifiedDate\n"
    
    public var todoItems = [String: TodoItem]()
    
    public init() {}
    
    public func appendNewItem(item: TodoItem) {
        todoItems[item.id] = item
    }
    
    public func removeItem(id: String) -> TodoItem? {
        todoItems.removeValue(forKey: id)
    }
    
    public func saveTodoItemsToJsonFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: file)
            var items = [[String: Any]]()
            
            for todoItem in todoItems {
                if let json = todoItem.value.json as? [String: Any] {
                    items.append(json)
                }
            }

            let jsonData = try JSONSerialization.data(withJSONObject: items, options: [])
            
            try jsonData.write(to: pathForFile)
        } catch {
            print("Error when saving tasks to a JSON file \(error)")
        }
    }
    
    public func loadTodoItemsFromJsonFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!.appending(path: file)
            let jsonData = try Data(contentsOf: pathForFile)
            
            print(jsonData)
            
            if let jsonItems = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [Any] {
                for jsonItem in jsonItems {
                    if let item = TodoItem.parse(json: jsonItem) {
                        todoItems[item.id] = item
                    }
                }
            }
            
            print(pathForFile)
            
        } catch {
            print("Error when loading tasks from a JSON file \(error)")
        }
    }
    
    public func saveTodoItemsToCSVFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!.appending(path: file)
            var items = headOfCSVFile
            
            for todoItem in todoItems {
                items += "\(todoItem.value.csv)\n"
            }
            
            try items.write(to: pathForFile, atomically: true, encoding: .utf8)
            
        } catch {
            print("Error when saving tasks to a CSV file \(error)")
        }
    }
    
    public func loadTodoItemsFromCSVFile(file: String) {
        do {
            let pathForFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: file)
            let csv = try String(contentsOf: pathForFile, encoding: .utf8)
            
            let parsedCSV: [String] = csv.components(separatedBy: "\n")
            
            for pos in 1..<parsedCSV.count {
                if let item = TodoItem.parse(csv: parsedCSV[pos]) {
                    todoItems[item.id] = item
                }
            }
            
        } catch {
            print("Error when loading tasks from a file \(error)")
        }
    }
}
