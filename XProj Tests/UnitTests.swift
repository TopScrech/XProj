import Testing

struct UnitTests {
    @Test func testExample() async throws {
        let array = [0, 1, 1, 2, 3, 3, 3, 4, 5, 5]
        
        let result = findDuplicates(array)
        print(result)
    }
    
    func findDuplicates(_ array: [Int]) -> [[Int]] {
        var countDict: [Int: Int] = [:]
        
        // Count occurrences of each number
        for num in array {
            if let count = countDict[num] {
                countDict[num] = count + 1
            } else {
                countDict[num] = 1
            }
        }
        
        var duplicates: [[Int]] = []
        
        // Gather numbers with count > 1 into duplicates array
        for (num, count) in countDict {
            if count > 1 {
                duplicates.append(Array(repeating: num, count: count))
            }
        }
        
        return duplicates
    }
}
