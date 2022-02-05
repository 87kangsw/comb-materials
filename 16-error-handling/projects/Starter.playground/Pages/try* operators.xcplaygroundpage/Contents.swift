//: [Previous](@previous)
import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()
//: ## try* operators
example(of: "tryMap") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }
    
    let names = ["Marin", "Shai", "Florent"].publisher
    
    names
        .tryMap { value -> Int in
            let length = value.count
            
            guard length >= 5 else {
                throw NameError.tooShort(value)
            }
            
            return length
        }
        .sink(receiveCompletion: { print("Completed with \($0)") }, receiveValue: { print("Got value: \($0)") })
        .store(in: &subscriptions)
}

example(of: "map vs tryMap") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }
    
    Just("Hello")
        .setFailureType(to: NameError.self)
        // .tryMap { $0 + " World" }
        .tryMap { throw NameError.tooShort($0) }
        .mapError { $0 as? NameError ?? .unknown }
        .sink { completion in
            switch completion {
            case .finished:
                print("Done!")
            case .failure(NameError.tooShort(let name)):
                print("\(name) is too short!")
            case .failure(NameError.unknown):
                print("An unknown error occurred")
            }
        } receiveValue: { value in
            print("Got value: \(value)")
        }
        .store(in: &subscriptions)
}

example(of: "Joke API") {
    class DadJokes {
        enum Error: Swift.Error, CustomStringConvertible {
            case network
            case jokeDoesntExist(id: String)
            case parsing
            case unknown
            
            var description: String {
                switch self {
                case .network:
                    return "Request to API Server failed"
                case .jokeDoesntExist(id: let id):
                    return "Joke with ID \(id) doesn't exist"
                case .parsing:
                    return "Failed parsing response from server"
                case .unknown:
                    return "An unknown error ocurred"
                }
            }
        }
        
        struct Joke: Codable {
            let id: String
            let joke: String
        }
        
        func getJoke(id: String) -> AnyPublisher<Joke, Error> {
            guard id.rangeOfCharacter(from: .letters) != nil else {
                return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
                    .eraseToAnyPublisher()
            }
            
            
            let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = ["Accept": "application/json"]
            
            return URLSession.shared
              .dataTaskPublisher(for: request)
//              .map(\.data)
              .tryMap { data, _ -> Data in
                  guard let obj = try? JSONSerialization.jsonObject(with: data), let dict = obj as? [String: Any],
                        dict["status"] as? Int == 404 else {
                            return data
                        }
                  throw DadJokes.Error.jokeDoesntExist(id: id)
              }
              .decode(type: Joke.self, decoder: JSONDecoder())
              .mapError({ error -> DadJokes.Error in
                  switch error {
                  case is URLError:
                      return .network
                  case is DecodingError:
                      return .parsing
                  default:
                      return error as? DadJokes.Error ?? .unknown
                  }
              })
              .eraseToAnyPublisher()
        }
    }
    
    let api = DadJokes()
    let jokeID = "9prWnjyImyd"
    let badJokeID = "123456"
    
    api
        .getJoke(id: jokeID)
        .print()
        .sink(receiveCompletion: { print($0) }, receiveValue: { print("Got joke: \($0)") })
        .store(in: &subscriptions)
}

//: [Next](@next)

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
