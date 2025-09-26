//
//  NetworkService.swift
//  kolokol
//
//  Created by Tom Tim on 20.09.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable, K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: K?,
        headers: [String: String]?,
        shouldCache: Bool
    ) async throws -> T
}

final class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let baseURL: String
    private let cache = NSCache<NSString, NSData>()
    
    private init() {
//        guard let baseURLString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
//            fatalError("BASE_URL is not set in Info.plist!")
//        }
        let baseURLString = "http://158.160.183.50:8080"
        self.baseURL = baseURLString
    }
    
    // MARK: - Подготовка запроса
    private func prepareRequest<K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]?,
        body: K?,
        headers: [String: String]?
    ) -> URLRequest? {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes] // для красоты

        do {
            let data = try encoder.encode(body)
            if let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            } else {
                print("Ошибка: не удалось преобразовать Data в String")
            }
        } catch {
            print("Ошибка кодирования: \(error)")
        }
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return nil
            }
        }
        return request
    }
    
    // MARK: - Логика кэширования
    private func cachedData(for request: URLRequest) -> Data? {
        guard let urlString = request.url?.absoluteString else { return nil }
        return cache.object(forKey: urlString as NSString) as Data?
    }
    
    private func cache(data: Data, for request: URLRequest) {
        guard let urlString = request.url?.absoluteString else { return }
        cache.setObject(data as NSData, forKey: urlString as NSString)
    }
    
    // MARK: - Основной метод запроса
    func request<T: Decodable, K: Codable>(
        endpoint: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: K? = nil,
        headers: [String: String]? = nil,
        shouldCache: Bool = true
    ) async throws -> T {
        
        guard let request = prepareRequest(
            endpoint: endpoint,
            method: method,
            queryItems: queryItems,
            body: body,
            headers: headers
        ) else {
            throw NetworkError.invalidURL
        }
        
        // Проверяем кэш
        if method == .get && shouldCache, let cachedData = cachedData(for: request) {
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: cachedData)
                return decodedData
            } catch {
                throw NetworkError.decodingError
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(message: "No HTTP response")
            }
            
            // Проверка ошибок по статус-кодам
            guard (200...299).contains(httpResponse.statusCode) else {
                switch httpResponse.statusCode {
                case 400:
                    if let str = String(data: data, encoding: .utf8), !str.isEmpty {
                        throw NetworkError(message: str) ?? NetworkError.unknown(message: str)
                    } else {
                        throw NetworkError.unknown(message: "UnknownError")
                    }
                case 403: throw NetworkError.forbidden
                case 404: throw NetworkError.notFound
                case 500...599: throw NetworkError.internalServerError
                default: throw NetworkError.unknown(message: "UnknownError")
                }
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            // Кэшируем успешные GET
            if method == .get && shouldCache {
                cache(data: data, for: request)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(T.self, from: data)
            if let prettyData = data.prettyJSON {
                print(prettyData)
            }
            return decoded
            
        } catch {
            throw NetworkError.unknown(message: error.localizedDescription)
        }
    }
}

extension Data {
    var prettyJSON: String? {
        guard
            let obj = try? JSONSerialization.jsonObject(with: self, options: []),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: obj,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let string = String(data: prettyData, encoding: .utf8)
        else { return nil }
        return string
    }
}
