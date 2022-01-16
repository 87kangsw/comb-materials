import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "min") {
    let publisher = [1, -50, 246, 0].publisher
    
    publisher
        .print("publisher")
        .min()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "min non-Comparable") {
    let publisher = [
        "12345",
        "ab",
        "hello world"
    ]
        .map { Data($0.utf8) }
        .publisher
    
    publisher
        .print("publisher")
        .min(by: { $0.count < $1.count })
        .sink { data in
            let string = String(data: data, encoding: .utf8)
            print("Smallest data is \(string), \(data.count) bytes")
        }
        .store(in: &subscriptions)
}

example(of: "max") {
    let publisher = ["A", "F", "Z", "E"].publisher
    
    publisher
        .print("publisher")
        .max()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "first") {
    let publisher = ["A", "B", "C"].publisher
    
    publisher
        .print()
        .first()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
    let publisher = ["J", "O", "H", "N"].publisher
    
    publisher
        .print()
        .first(where: { "Hello world".contains($0) })
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "last") {
    let publisher = ["A", "B", "C"].publisher
    
    publisher
        .print()
        .last()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "output(at:)") {
    let publisher = ["A", "B", "C"].publisher
    
    publisher
        .print()
        .output(at: 1)
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "output(in:)") {
    let publisher = ["A", "B", "C", "D", "E"].publisher
    
    publisher
        .output(in: 1...3)
        .sink(receiveCompletion: { print($0) }, receiveValue: { print("Value in range: \($0)")})
        .store(in: &subscriptions)
}

example(of: "count") {
    let publisher = ["A", "B", "C"].publisher
    
    publisher
        .print()
        .count()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "contains") {
    let publisher = ["A", "B", "C", "D", "E"].publisher
    let letter = "F"
    
    publisher
        .contains(letter)
        .sink(receiveValue: { contains in print(contains ? "emitted :\(letter)" : "never emitted: \(letter)") })
        .store(in: &subscriptions)
}

example(of: "contains(where:)") {
    
    struct Person {
        let id: Int
        let name: String
    }
    
    let people = [
        (123, "Hahaha"),
        (456, "ooops"),
        (214, "hhohoho")
    ]
        .map(Person.init)
        .publisher
    
    people
        .contains(where: { $0.id == 123 })
        .sink(receiveValue: { contains in print(contains ? "matches" : "couldn't find") })
        .store(in: &subscriptions)
}

example(of: "allSatisfy") {
    let publisher = stride(from: 0, to: 5, by: 1).publisher
    
    publisher
        .print()
        .allSatisfy { $0 % 2 == 0 }
        .sink(receiveValue: { allEven in print(allEven ? "all even" : "odd") })
        .store(in: &subscriptions)
}

example(of: "reduce") {
    let publisher = ["Hel", "lo", " " , "Wor", "ld", "!"].publisher
    
    publisher
        .print()
        .reduce("", { accumulator, value in accumulator + value })
        .sink(receiveValue: { print("reduced:: \($0)") })
        .store(in: &subscriptions)
}


/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
