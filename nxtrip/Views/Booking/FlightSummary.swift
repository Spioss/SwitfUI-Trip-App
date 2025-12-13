//
//  FlightSummary.swift
//  iza-app
//
//  Created by Lukáš Mader on 26/05/2025.
//
import SwiftUI


struct FlightSummary: View {
    let title: String
    let from: String
    let to: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let date: String
    let stops: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(from)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(departureTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                        .frame(width: 60)
                    
                    Text(duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if stops > 0 {
                        Text("\(stops) stop\(stops > 1 ? "s" : "")")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    } else {
                        Text("Direct")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(to)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(arrivalTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.adaptiveSecondaryBackground)
        .cornerRadius(12)
    }
}
