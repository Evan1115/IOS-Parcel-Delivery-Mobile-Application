//
//  MergeSort.swift
//  ParcelDelivery
//
//  Created by lim lee jing on 03/03/2021.
//  Copyright © 2021 lim lee jing. All rights reserved.
//

import Foundation

class Mergesort {
    
    func mergeSort(array: inout [Int], start: Int, end : Int) {
        // base case
        if (start < end) {
            // find the middle point
            let middle = ((start + end) / 2 )
          print("debug merge middle \(middle)")
          
            mergeSort(array: &array, start: start, end: middle) // sort first half
             mergeSort(array: &array, start: middle + 1, end: end)  // sort second half

            // merge the sorted halves
            merge(array: &array, start: start, middle: middle, end: end)
        }
    }

    // merges two subarrays of array[]
    func merge(array : inout [Int], start: Int, middle: Int, end: Int) {
        // create temp arrays
        let leftArrayLength = middle - start + 1
        let rightArrayLength = end - middle

        var leftArray :  [Int] = []
        var rightArray :  [Int] = []

        // fill in left array
        for index  in 0..<leftArrayLength {
                        leftArray[index] = array[start + index ]
        }
       

        // fill in right array
        for index  in 0..<rightArrayLength {
                    rightArray[index] = array[middle + 1 + index]
        }
       
        // merge the temp arrays

        // initial indexes of first and second subarrays
        var leftIndex = 0, rightIndex = 0

        // the index we will start at when adding the subarrays back into the main array
        var currentIndex = start;

        // compare each index of the subarrays adding the lowest value to the currentIndex
        while (leftIndex < leftArrayLength && rightIndex < rightArrayLength) {
            if (leftArray[leftIndex] <= rightArray[rightIndex]) {
               
               
                array[currentIndex] = leftArray[leftIndex]
                leftIndex += 1
            }
            else{
                array[currentIndex] = rightArray[rightIndex]
                 rightIndex += 1
            }
            currentIndex += 1
            
        }

        // copy remaining elements of leftArray[] if any
        while (leftIndex < leftArrayLength){
            array[currentIndex] = leftArray[leftIndex]
            currentIndex += 1
            leftIndex += 1
        }

        // copy remaining elements of rightArray[] if any
        while (rightIndex < rightArrayLength) {
            array[currentIndex] = rightArray[rightIndex]
            currentIndex += 1
            rightIndex += 1
    }

   }
    
    func quickSort(array: inout [Places] , startIndex : Int, endIndex : Int) {
      // verify that the start and end index have not overlapped
      if (startIndex < endIndex) {
        // calculate the pivotIndex
        let pivotIndex = partition(array: &array, startIndex: startIndex, endIndex: endIndex)
        // sort the left sub-array
        quickSort(array: &array, startIndex: startIndex, endIndex: pivotIndex)
        // sort the right sub-array
        quickSort(array: &array, startIndex: pivotIndex + 1, endIndex: endIndex)
      }
    }

    func partition(array: inout [Places] , startIndex : Int, endIndex : Int) -> Int {
      let pivotIndex = (startIndex + endIndex) / 2
      let pivotValue = array[pivotIndex]
      var startIndex = startIndex
     var endIndex = endIndex

      while (true) {
        // start at the FIRST index of the sub-array and increment
        // FORWARD until we find a value that is > pivotValue
        while (array[startIndex].distance < pivotValue.distance) {
          startIndex += 1
        }

        // start at the LAST index of the sub-array and increment
        // BACKWARD until we find a value that is < pivotValue
        while (array[endIndex].distance > pivotValue.distance) {
          endIndex -= 1
        }

        if (startIndex >= endIndex) {return endIndex}

        // swap values at the startIndex and endIndex
        let temp = array[startIndex]
        array[startIndex] = array[endIndex]
        array[endIndex] = temp
      }
    }
    
}
