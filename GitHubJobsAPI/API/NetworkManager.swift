import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func getResults(description: String, location: String, completed: @escaping (Result<[Results], ErrorMessages>) -> (Void)) {
        
        // replace the space in the given description with a plus sign
        let urlString = "\(Constants.API_URL)?description=\(description.replacingOccurrences(of: " ", with: "+"))&location=\(location.replacingOccurrences(of: " ", with: "+"))"
        
        guard let url = URL(string: urlString) else { return }
        
        // handle each one of what we get from the closure of the dataTask() then parse the json data
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completed(.failure(.invalidData))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                // use this line if the fields in our codable model are written in camel case
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                // parse the json data into an object of our model that comform to Codable Protocol
                let results = try decoder.decode([Results].self, from: data)
                completed(.success(results))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
}
