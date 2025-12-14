//
//  AmadeusErrorModel.swift
//  nxtrip
//
//  Created by Lukáš Mader on 14/12/2025.
//

struct AmadeusErrorResponse: Codable {
    let errors: [AmadeusError]
}

struct AmadeusError: Codable {
    let status: Int?
    let code: Int?
    let title: String?
    let detail: String?
}
