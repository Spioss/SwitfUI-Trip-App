//
//  MockFlightData.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

import Foundation

struct MockFlightData {
    
    // MARK: - Generate Mock Flights
    
    static func generateMockFlights(from: String, to: String, isRoundTrip: Bool) -> [SimpleFlight] {
        let flights = [
            createMockFlight(
                from: from, to: to,
                departureTime: "08:30", arrivalTime: "10:45",
                carrier: "VY", number: "8715",
                duration: "PT2H15M",
                price: 89.99,
                stops: 0,
                hasReturn: isRoundTrip
            ),
            createMockFlight(
                from: from, to: to,
                departureTime: "12:15", arrivalTime: "15:30",
                carrier: "FR", number: "2341",
                duration: "PT3H15M",
                price: 65.50,
                stops: 1,
                hasReturn: isRoundTrip
            ),
            createMockFlight(
                from: from, to: to,
                departureTime: "16:45", arrivalTime: "18:20",
                carrier: "BA", number: "847",
                duration: "PT1H35M",
                price: 145.00,
                stops: 0,
                hasReturn: isRoundTrip
            ),
            createMockFlight(
                from: from, to: to,
                departureTime: "19:30", arrivalTime: "22:45",
                carrier: "LH", number: "1234",
                duration: "PT3H15M",
                price: 120.00,
                stops: 1,
                hasReturn: isRoundTrip
            ),
            createMockFlight(
                from: from, to: to,
                departureTime: "06:00", arrivalTime: "08:15",
                carrier: "AF", number: "5678",
                duration: "PT2H15M",
                price: 99.99,
                stops: 0,
                hasReturn: isRoundTrip
            ),
        ]
        
        return flights
    }
    
    // MARK: - Create Single Mock Flight
    
    private static func createMockFlight(
        from: String,
        to: String,
        departureTime: String,
        arrivalTime: String,
        carrier: String,
        number: String,
        duration: String,
        price: Double,
        stops: Int,
        hasReturn: Bool
    ) -> SimpleFlight {
        
        let departureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let returnDate = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        
        // Outbound itinerary
        let outboundDeparture = formatDateForAPI(departureDate, time: departureTime)
        let outboundArrival = formatDateForAPI(departureDate, time: arrivalTime)
        
        var outboundSegments = [
            SimpleSegment(
                departure: FlightPoint(iataCode: from, at: outboundDeparture),
                arrival: FlightPoint(iataCode: to, at: outboundArrival),
                carrierCode: carrier,
                number: number,
                duration: duration
            )
        ]
        
        // Add stopover if needed
        if stops > 0 {
            let stopoverCode = getRandomStopover(from: from, to: to)
            let stopDepartureTime = addHours(to: departureTime, hours: 1)
            let stopArrivalTime = addHours(to: arrivalTime, hours: -1)
            
            outboundSegments = [
                SimpleSegment(
                    departure: FlightPoint(iataCode: from, at: formatDateForAPI(departureDate, time: departureTime)),
                    arrival: FlightPoint(iataCode: stopoverCode, at: formatDateForAPI(departureDate, time: stopDepartureTime)),
                    carrierCode: carrier,
                    number: number,
                    duration: "PT1H20M"
                ),
                SimpleSegment(
                    departure: FlightPoint(iataCode: stopoverCode, at: formatDateForAPI(departureDate, time: stopArrivalTime)),
                    arrival: FlightPoint(iataCode: to, at: formatDateForAPI(departureDate, time: arrivalTime)),
                    carrierCode: carrier,
                    number: String(Int(number)! + 1),
                    duration: "PT1H55M"
                )
            ]
        }
        
        let outbound = SimpleItinerary(
            duration: duration,
            segments: outboundSegments
        )
        
        // Return itinerary (if round trip)
        var itineraries = [outbound]
        
        if hasReturn {
            let returnDeparture = formatDateForAPI(returnDate, time: departureTime)
            let returnArrival = formatDateForAPI(returnDate, time: arrivalTime)
            
            var returnSegments = [
                SimpleSegment(
                    departure: FlightPoint(iataCode: to, at: returnDeparture),
                    arrival: FlightPoint(iataCode: from, at: returnArrival),
                    carrierCode: carrier,
                    number: String(Int(number)! + 100),
                    duration: duration
                )
            ]
            
            if stops > 0 {
                let stopoverCode = getRandomStopover(from: to, to: from)
                let stopDepartureTime = addHours(to: departureTime, hours: 1)
                let stopArrivalTime = addHours(to: arrivalTime, hours: -1)
                
                returnSegments = [
                    SimpleSegment(
                        departure: FlightPoint(iataCode: to, at: formatDateForAPI(returnDate, time: departureTime)),
                        arrival: FlightPoint(iataCode: stopoverCode, at: formatDateForAPI(returnDate, time: stopDepartureTime)),
                        carrierCode: carrier,
                        number: String(Int(number)! + 100),
                        duration: "PT1H20M"
                    ),
                    SimpleSegment(
                        departure: FlightPoint(iataCode: stopoverCode, at: formatDateForAPI(returnDate, time: stopArrivalTime)),
                        arrival: FlightPoint(iataCode: from, at: formatDateForAPI(returnDate, time: arrivalTime)),
                        carrierCode: carrier,
                        number: String(Int(number)! + 101),
                        duration: "PT1H55M"
                    )
                ]
            }
            
            let returnItinerary = SimpleItinerary(
                duration: duration,
                segments: returnSegments
            )
            
            itineraries.append(returnItinerary)
        }
        
        return SimpleFlight(
            id: UUID().uuidString,
            price: FlightPrice(
                total: String(format: "%.2f", price),
                currency: "EUR"
            ),
            itineraries: itineraries
        )
    }
    
    // MARK: - Helper Functions
    
    private static func formatDateForAPI(_ date: Date, time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        return "\(dateString)T\(time):00"
    }
    
    private static func addHours(to time: String, hours: Int) -> String {
        let components = time.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return time
        }
        
        let newHour = (hour + hours + 24) % 24
        return String(format: "%02d:%02d", newHour, minute)
    }
    
    private static func getRandomStopover(from: String, to: String) -> String {
        let stopovers = ["VIE", "MUC", "FRA", "AMS", "CDG", "ZRH"]
        return stopovers.filter { $0 != from && $0 != to }.randomElement() ?? "VIE"
    }
}
