//
//  SBTBarcodeDecoder.swift
//  Smart Baby Tracker
//
//  Created by J. HOWARD SMART on 2/28/15.
//  Copyright (c) 2015 J. HOWARD SMART. All rights reserved.
//

import UIKit
import Foundation

class SBTBarcodeDecoder: NSObject {
    struct Barcode {
        init(_ rawCode: String?) {
            raw = rawCode
            var n = rawCode
            while n != nil{
                n = storeLeadingComponent(n!)
            }
        }
        var raw: String?{
            didSet{
                var n = raw
                while n != nil{
                    n = storeLeadingComponent(n!)
                }
            }
        }
        var gtin: String?
        var ndc: String?
        var expDate: NSDateComponents?
        var lotNumber: String?
        mutating func storeLeadingComponent(code: String) -> String?{
            var start = code.startIndex
            var end = advance(start, 2)
            let last = code.endIndex
            let ai = code.substringWithRange(start..<end)
            start = end
            switch ai{
            case "01": // the GTIN (including the NDC) - always 14 characters
                end = advance(start, 14)
                gtin = code.substringWithRange(start..<end)
                let ndcStart = advance(start, 3)
                let ndcEnd = advance(ndcStart, 10)
                let rawNDC = code.substringWithRange(ndcStart..<ndcEnd)
                var startIdx = rawNDC.startIndex
                var nextIdx = advance(startIdx, 5)
                var formattedNDC = rawNDC.substringWithRange(startIdx..<nextIdx)
                formattedNDC += "-"
                startIdx = nextIdx
                nextIdx = advance(nextIdx, 4)
                var partial = rawNDC.substringWithRange(startIdx..<nextIdx)
                formattedNDC += partial
                formattedNDC += "-"
                startIdx = nextIdx
                nextIdx = advance(nextIdx, 2)
                partial = rawNDC.substringWithRange(startIdx..<nextIdx)
                formattedNDC += partial
                ndc = formattedNDC
                return code.substringWithRange(end..<last)
            case "10": // lot number (always chews up the rest of the code)
                end = last
                lotNumber = code.substringWithRange(start..<end)
                return nil
            case "17": // expiration date - always 6 characters
                end = advance(start, 6)
                let rawDate = code.substringWithRange(start..<end)
                var pos = rawDate.startIndex
                var pos2 = advance(pos, 2)
                let rawYear = rawDate.substringWithRange(pos..<pos2)
                pos = pos2
                pos2 = advance(pos, 2)
                let rawMonth = rawDate.substringWithRange(pos..<pos2)
                pos = pos2
                pos2 = advance(pos, 2)
                let rawDay = rawDate.substringWithRange(pos..<pos2)
                
                var date = NSDateComponents()
                date.calendar = NSCalendar.currentCalendar()
                if let year = rawYear.toInt(){
                    date.year = year + 2000
                }
                if let month = rawMonth.toInt(){
                    date.month = month
                }
                if let day = rawDay.toInt(){
                    date.day = day
                }
                expDate = date
                
                
                return code.substringWithRange(end..<last)
            default:
                println("This does not appear to be a valid bar code")
                return nil
            }
        }
    }
    func decodeBarcode(string: String?) -> SBTVaccine?{
        let bc = Barcode(string)
        let bigVaccineList = BCRVaccineCodeLoader.vaccines() // this returns an NSDictionary of available vaccines, keyed on NDC as "00000-0000-00" Strings
        let vax = bigVaccineList[bc.ndc!] as NSDictionary!
        /* This is the first line of the data file, which will be the keys in the dictionary
        NDCInnerID,UseUnitLabeler,UseUnitProduct,UseUnitPackage,UseUnitPropName,UseUnitGenericName,UseUnitLabelerName, UseUnitstartDate,UseUnitEndDate,UseUnitGTIN,CVX Code,CVX Short Description,NoInner,NDC11,last_updated_date,GTIN
        */
        var newVaccine = SBTVaccine(name: vax["CVX Short Description"], displayNames: <#[AnyObject]!#>, manufacturer: vax["UseUnitLabelerName"], andComponents: <#[AnyObject]!#>)
    }
}
