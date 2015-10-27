//
//  ChartDataSetBase.swift
//  Charts
//
//  Created by Daniel Cohen Gindi on 26/2/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/ios-charts
//

import Foundation

public class ChartDataSetBase: NSObject
{
    public var colors = [UIColor]()
    
    public var label: String? = "DataSet"
    public var visible = true
    public var drawValuesEnabled = true
    
    /// the color used for the value-text
    public var valueTextColor: UIColor = UIColor.blackColor()
    
    /// the font for the value-text labels
    public var valueFont: UIFont = UIFont.systemFontOfSize(7.0)
    
    /// the formatter used to customly format the values
    internal var _valueFormatter: NSNumberFormatter? = ChartUtils.defaultValueFormatter()
    
    /// the axis this DataSet should be plotted against.
    public var axisDependency = ChartYAxis.AxisDependency.Left
    
    /// if true, value highlighting is enabled
    public var highlightEnabled = true
    
    /// - returns: true if value highlighting is enabled for this dataset
    public var isHighlightEnabled: Bool { return highlightEnabled }
    
    public override required init()
    {
        super.init()

        if self.isMemberOfClass(ChartDataSetBase)
        {
            fatalError("ChartDataSetBase cannot be instantiated directly")
        }
        
        // default color
        colors.append(UIColor(red: 140.0/255.0, green: 234.0/255.0, blue: 255.0/255.0, alpha: 1.0))
    }
    
    public convenience init(label: String?)
    {
        self.init()
        
        self.label = label
    }
    
    /// Use this method to tell the data set that the underlying data has changed
    public func notifyDataSetChanged()
    {
        // You may want to invalidate data in implementations of this class
    }
    
    public func calcMinMax(start start: Int, end: Int)
    {
        // This is where you calculate the min/max of the y-values for the range of start/end of x-indexes
    }
    
    /// - returns: the average value across all entries in this DataSet.
    public var average: Double
    {
        return 0.0
    }
    
    public var entryCount: Int { return 0 }
    
    public func yValForXIndex(x: Int) -> Double
    {
        return Double.NaN
    }
    
    /// - returns: the entry object found at the given index (not x-index!)
    /// - throws: out of bounds
    /// if `i` is out of bounds, it may throw an out-of-bounds exception
    public func entryForIndex(i: Int) -> ChartDataEntry?
    {
        return nil
    }
    
    /// - returns: the first Entry object found at the given xIndex with binary search.
    /// If the no Entry at the specifed x-index is found, this method returns the Entry at the closest x-index.
    /// nil if no Entry object at that index.
    public func entryForXIndex(x: Int) -> ChartDataEntry?
    {
        return nil
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter x: x-index of the entry to search for
    public func entryIndex(xIndex x: Int) -> Int
    {
        return -1
    }
    
    /// - returns: the array-index of the specified entry
    ///
    /// - parameter e: the entry to search for
    /// - parameter isEqual: check using value equality instead of pointer equality
    public func entryIndex(entry e: ChartDataEntry, isEqual: Bool) -> Int
    {
        return -1
    }
    
    /// the formatter used to customly format the values
    public var valueFormatter: NSNumberFormatter?
    {
        get
        {
            return _valueFormatter
        }
        set
        {
            if newValue == nil
            {
                _valueFormatter = ChartUtils.defaultValueFormatter()
            }
            else
            {
                _valueFormatter = newValue
            }
        }
    }
    
    /// - returns: the number of entries this DataSet holds.
    public var valueCount: Int { return 0 }
    
    public func resetColors()
    {
        colors.removeAll(keepCapacity: false)
    }
    
    public func addColor(color: UIColor)
    {
        colors.append(color)
    }
    
    public func setColor(color: UIColor)
    {
        colors.removeAll(keepCapacity: false)
        colors.append(color)
    }
    
    public func colorAt(var index: Int) -> UIColor
    {
        if (index < 0)
        {
            index = 0
        }
        return colors[index % colors.count]
    }
    
    public var isVisible: Bool
    {
            return visible
    }
    
    public var isDrawValuesEnabled: Bool
    {
            return drawValuesEnabled
    }
    
    // MARK: NSObject
    
    public override var description: String
    {
        return String(format: "%@, label: %@, %i entries", arguments: [NSStringFromClass(self.dynamicType), self.label ?? "", self.entryCount])
    }
    
    public override var debugDescription: String
    {
        var desc = description + ":"
        
        for (var i = 0, count = self.entryCount; i < count; i++)
        {
            desc += "\n" + (self.entryForIndex(i)?.description ?? "")
        }
        
        return desc
    }
    
    // MARK: NSCopying
    
    public func copyWithZone(zone: NSZone) -> AnyObject
    {
        let copy = self.dynamicType.init()
        
        copy.colors = colors
        copy.label = label
        
        return copy
    }
}
