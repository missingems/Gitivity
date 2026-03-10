//
//  ContributionsCollection.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

public struct ContributionsCollection: Decodable {
  let calendar: Calendar
  
  enum CodingKeys: String, CodingKey {
    case calendar = "contributionCalendar"
  }
  
  public struct Calendar: Decodable {
    let weeks: [Week]
    
    public struct Week: Decodable {
      let days: [Day]
      
      enum CodingKeys: String, CodingKey {
        case days = "contributionDays"
      }
    }
    
    public struct Day: Decodable {
      let count: Int
      let date: String
      
      enum CodingKeys: String, CodingKey {
        case count = "contributionCount"
        case date
      }
    }
  }
}
