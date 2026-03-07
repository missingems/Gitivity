//
//  ContributionsCollection.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

struct ContributionsCollection: Decodable {
  let calendar: Calendar
  
  struct Calendar: Decodable {
    let weeks: [Week]
    
    struct Week: Decodable {
      let days: [Day]
    }
    
    struct Day: Decodable {
      let count: Int
    }
  }
}
