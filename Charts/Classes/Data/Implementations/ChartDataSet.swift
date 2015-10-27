//
//  ChartDataSet.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 23/2/15.

//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation
import UIKit

public class ChartDataSet: ChartDataSetBase
{
    internal var _yVals: [ChartDataEntry]!
    internal var _yMax = Double(0.0)
    internal var _yMin = Double(0.0)
    internal var _yValueSum = Double(0.0)
    
    /// the last start value used for calcMinMax
    internal var _lastStart: Int = 0
    
    /// the last end value used for calcMinMax
    internal var _lastEnd: Int = 0

    public var yVals: [ChartDataEntry] { return _yVals }
    public var yValueSum: Double { return _yValueSum }
    public var yMin: Double { return _yMin }
    public var yMax: Double { return _yMax }
    
    public required init()
    {
        super.init()
    }
    
    public init(yVals: [ChartDataEntry]?, label: String?)
    {
        super.init()
        
        self.label = label
        _yVals = yVals == nil ? [ChartDataEntry]() : yVals
        
        self.calcMinMax(start: _lastStart, end: _lastEnd)
        self.calcYValueSum()
    }
    
    public convenience init(yVals: [ChartDataEntry]?)
    {
        self.init(yVals: yVals, label: "DataSet")
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public override func notifyDataSetChanged()
    {
        calcMinMax(start: _lastStart, end: _lastEnd)
        calcYValueSum()
    }
    
    public override func calcMinMax(start start : Int, end: Int)
    {
        let yValCount = _yVals.count
        
        if yValCount == 0
        {
            return
        }
        
        var endValue : Int
        
        if end == 0 || end >= yValCount
        {
            endValue = yValCount - 1
        }
        else
        {
            endValue = end
        }
        
        _lastStart = start
        _lastEnd = endValue
        
        _yMin = DBL_MAX
        _yMax = -DBL_MAX
        
        for (var i = start; i <= endValue; i++)
        {
            let e = _yVals[i]
            
            if (!e.value.isNaN)
            {
                if (e.value < _yMin)
                {
                    _yMin = e.value
                }
                if (e.value > _yMax)
                {
                    _yMax = e.value
                }
            }
        }
        
        if (_yMin == DBL_MAX)
        {
            _yMin = 0.0
            _yMax = 0.0
        }
    }
    
    private func calcYValueSum()
    {
        _yValueSum = 0
        
        for var i = 0; i < _yVals.count; i++
        {
            _yValueSum += fabs(_yVals[i].value)
        }
    }
    
    /// - returns: the average value across all entries in this DataSet.
    public override var average: Double
    {
        return yValueSum / Double(valueCount)
    }
    
    public override var entryCount: Int { return _yVals!.count }
    
    public override func yValForXIndex(x: Int) -> Double
    {
        let e = self.entryForXIndex(x)
        
        if (e !== nil && e!.xIndex == x) { return e!.value }
        else { return Double.NaN }
    }
    
    public override func entryForIndex(i: Int) -> ChartDataEntry?
    {
        return _yVals[i]
    }
    
    public override func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        let index = self.entryIndex(xIndex: x)
        if (index > -1)
        {
            return _yVals[index]
        }
        return nil
    }
    
    public func entriesForXIndex(x: Int) -> [ChartDataEntry]
    {
        var entries = [ChartDataEntry]()
        
        var low = 0
        var high = _yVals.count - 1
        
        while (low <= high)
        {
            var m = Int((high + low) / 2)
            var entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--
                }
                
                high = _yVals.count
                for (; m < high; m++)
                {
                    entry = _yVals[m]
                    if (entry.xIndex == x)
                    {
                        entries.append(entry)
                    }
                    else
                    {
                        break
                    }
                }
            }
            
            if (x > _yVals[m].xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
        }
        
        return entries
    }
    
    public override func entryIndex(xIndex x: Int) -> Int
    {
        var low = 0
        var high = _yVals.count - 1
        var closest = -1
        
        while (low <= high)
        {
            var m = (high + low) / 2
            let entry = _yVals[m]
            
            if (x == entry.xIndex)
            {
                while (m > 0 && _yVals[m - 1].xIndex == x)
                {
                    m--
                }
                
                return m
            }
            
            if (x > entry.xIndex)
            {
                low = m + 1
            }
            else
            {
                high = m - 1
            }
            
            closest = m
        }
        
        return closest
    }
    
    public override func entryIndex(entry e: ChartDataEntry, isEqual: Bool) -> Int
    {
        if (isEqual)
        {
            for (var i = 0; i < _yVals.count; i++)
            {
                if (_yVals[i].isEqual(e))
                {
                    return i
                }
            }
        }
        else
        {
            for (var i = 0; i < _yVals.count; i++)
            {
                if (_yVals[i] === e)
                {
                    return i
                }
            }
        }
        
        return -1
    }
    
    public override var valueCount: Int { return _yVals.count }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to the end of the list.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    public func addEntry(e: ChartDataEntry)
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yValueSum += val
        
        _yVals.append(e)
    }
    
    /// Adds an Entry to the DataSet dynamically.
    /// Entries are added to their appropriate index respective to it's x-index.
    /// This will also recalculate the current minimum and maximum values of the DataSet and the value-sum.
    /// - parameter e: the entry to add
    public func addEntryOrdered(e: ChartDataEntry)
    {
        let val = e.value
        
        if (_yVals == nil)
        {
            _yVals = [ChartDataEntry]()
        }
        
        if (_yVals.count == 0)
        {
            _yMax = val
            _yMin = val
        }
        else
        {
            if (_yMax < val)
            {
                _yMax = val
            }
            if (_yMin > val)
            {
                _yMin = val
            }
        }
        
        _yValueSum += val
        
        if _yVals.last?.xIndex > e.xIndex
        {
            var closestIndex = entryIndex(xIndex: e.xIndex)
            if _yVals[closestIndex].xIndex < e.xIndex
            {
                closestIndex++
            }
            _yVals.insert(e, atIndex: closestIndex)
            return;
        }
        
        _yVals.append(e)
    }
    
    public func removeEntry(entry: ChartDataEntry) -> Bool
    {
        var removed = false
        
        for (var i = 0; i < _yVals.count; i++)
        {
            if (_yVals[i] === entry)
            {
                _yVals.removeAtIndex(i)
                removed = true
                break
            }
        }
        
        if (removed)
        {
            _yValueSum -= entry.value
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed
    }
    
    public func removeEntry(xIndex xIndex: Int) -> Bool
    {
        let index = self.entryIndex(xIndex: xIndex)
        if (index > -1)
        {
            let e = _yVals.removeAtIndex(index)
            
            _yValueSum -= e.value
            calcMinMax(start: _lastStart, end: _lastEnd)
            
            return true
        }
        
        return false
    }
    
    /// Removes the first Entry (at index 0) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public func removeFirst() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeFirst()
        
        let removed = entry != nil
        
        if (removed)
        {
            
            let val = entry!.value
            _yValueSum -= val
            
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Removes the last Entry (at index size-1) of this DataSet from the entries array.
    ///
    /// - returns: true if successful, false if not.
    public func removeLast() -> Bool
    {
        let entry: ChartDataEntry? = _yVals.isEmpty ? nil : _yVals.removeLast()
        
        let removed = entry != nil
        
        if (removed)
        {
            
            let val = entry!.value
            _yValueSum -= val
            
            calcMinMax(start: _lastStart, end: _lastEnd)
        }
        
        return removed;
    }
    
    /// Checks if this DataSet contains the specified Entry.
    /// - returns: true if contains the entry, false if not.
    public func contains(e: ChartDataEntry) -> Bool
    {
        for entry in _yVals
        {
            if (entry.isEqual(e))
            {
                return true
            }
        }
        
        return false
    }
    
    /// Removes all values from this DataSet and recalculates min and max value.
    public func clear()
    {
        _yVals.removeAll(keepCapacity: true)
        _lastStart = 0
        _lastEnd = 0
        notifyDataSetChanged()
    }

    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = super.copyWithZone(zone) as! ChartDataSet
        
        copy._yVals = _yVals
        copy._yMax = _yMax
        copy._yMin = _yMin
        copy._yValueSum = _yValueSum
        copy._lastStart = _lastStart
        copy._lastEnd = _lastEnd
        
        return copy
    }
}


