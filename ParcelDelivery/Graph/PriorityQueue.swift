//
//  PriorityQueue.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 21/08/2020.
//  Copyright © 2020 lim lee jing. All rights reserved.
//
/*
import Foundation

public struct PriorityQueue<T> {
    fileprivate var heap: Heap<T>
    
    public init(sort: @escaping (T, T) -> Bool) {
        heap = Heap(priorityFunction: sort)
    }
    
    public var isEmpty : Bool {
        return heap.isEmpty
    }
    
    public var count : Int {
        return heap.count
    }
    
    public func peek() -> T? {
        return heap.peek()
    }
    
    public mutating func enqueue(_ element: T) {
        heap.enqueue(element)
    }
    
    public mutating func dequeue() -> T? {
        return heap.dequeue()
    }
}

*/
