//
//  Algorithm.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 01/09/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//

import Foundation
class Node {
  var visited = false
  var connections: [Connection] = []
}

class Connection {
  public let to: Node
  public let weight: Double
  
  public init(to node: Node, weight: Double) {
    assert(weight >= 0, "weight has to be equal or greater than zero")
    self.to = node
    self.weight = weight
  }
}

class Path {
  public let cumulativeWeight: Double
  public let node: Node
  public let previousPath: Path?
  
  init(to node: Node, via connection: Connection? = nil, previousPath path: Path? = nil) {
    if
      let previousPath = path,
      let viaConnection = connection {
      self.cumulativeWeight = viaConnection.weight + previousPath.cumulativeWeight
    } else {
      self.cumulativeWeight = 0
    }
    
    self.node = node
    self.previousPath = path
  }
}

extension Path {
  var array: [Node] {
    var array: [Node] = [self.node]
    
    var iterativePath = self
    while let path = iterativePath.previousPath {
      array.append(path.node)
      
      iterativePath = path
    }
    
    return array
  }
}

func shortestPath(source: Node, destination: Node) -> Path? {
  var frontier: [Path] = [] {
    didSet { frontier.sort { return $0.cumulativeWeight < $1.cumulativeWeight } } // the frontier has to be always ordered
  }
  
  frontier.append(Path(to: source)) // the frontier is made by a path that starts nowhere and ends in the source
  
  while !frontier.isEmpty {
    let cheapestPathInFrontier = frontier.removeFirst() // getting the cheapest path available
    guard !cheapestPathInFrontier.node.visited else { continue } // making sure  haven't visited the node already
    
    if cheapestPathInFrontier.node === destination {
      return cheapestPathInFrontier // found the cheapest path
    }
    
    cheapestPathInFrontier.node.visited = true
    
    for connection in cheapestPathInFrontier.node.connections where !connection.to.visited { // adding new paths to our frontier
      frontier.append(Path(to: connection.to, via: connection, previousPath: cheapestPathInFrontier))
    }
  } // end while
  return nil // we didn't find a path
}


