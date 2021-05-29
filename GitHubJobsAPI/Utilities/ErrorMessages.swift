import Foundation

enum ErrorMessages: String, Error {
    case invalidData     = "Sorry. something went wrong, try again"
    case invalidResponse = "Server Error. Please modify your search and try again"
}
