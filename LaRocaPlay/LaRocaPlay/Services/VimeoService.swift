////
////  VimeoService.swift
////  LaRocaPlay
////
////  Created by Ancel Dev account on 17/12/25.
////
//
//import Foundation
//import Supabase
//
//
//enum VimeoError: Error {
//    case invalidURL
//    case networkError(Error)
//    case decodingError(Error)
//    case hlsLinkNotFound
//    case videoAccessDenied
//    case testingError
//}
//@Observable
//final class VimeoService {
//    static var shared = VimeoService()
//    //    private let accessToken = Secrets.$vimeoAccessToken
//    private let accessToken = Secrets.$vimeoAccessToken
//    private let baseURL = "https://api.vimeo.com/videos/"
//    private let client = SBCLient.shared.supabase
//    
//
//    func getVideoURL(for videoId: String) async throws -> URL {
//        do {
//            let videoLink = try await getVimeoLinkFromEF(for: videoId)
//            return videoLink
//            
//        } catch let error as DecodingError {
//            print(error)
//            throw error
//        } catch let error as PostgrestError {
//            print("Error al hacer el fetch")
//            print(error)
//            if error.code == "PGRST116" { // Error que se produce al no encontrar un row con ese video_id
//                do {
//                    let supabaseVideo = try await getVideoFromVimeo(for: videoId)
//                    let videoURL = try await saveTemporalVideoLink(with: supabaseVideo)
//                    return videoURL
//                } catch {
//                    print(error)
//                    throw error
//                }
//            }
//            throw error
//        } catch {
//            print(error)
//            throw error
//        }
//    }
//    
//    private func saveTemporalVideoLink(with video: SupabaseVideo) async throws -> URL {
//        let savedVideo: SupabaseVideo = try await client
//            .from("video_temporal_link")
//            .insert(video)
//            .select()
//            .single()
//            .execute()
//            .value
//        
//        return URL(string: savedVideo.link)!
//    }
//    
//    private func getTemporalVideoLink(for videoId: String) async throws -> SupabaseVideo {
//        let dateInOneHour = Date().addingTimeInterval(3600)
//        let isoDateString = ISO8601DateFormatter().string(from: dateInOneHour)
//        
//        let video: SupabaseVideo = try await client
//            .from("video_temporal_link")
//            .select()
//            .eq("video_id", value: videoId)
//            .gt("link_expiration_time", value: isoDateString)
//            .single()
//            .execute()
//            .value
//        return video
//    }
//    
//    private func getVimeoLinkFromEF(for videoId: String) async throws -> URL {
////        return try await client.functions.invoke(
////            "get-vimeo-temporal-link",
////            options: FunctionInvokeOptions(
////                body: ["videoId": videoId]
////            )
////            )
//        let response: VimeoVideoResponse = try await client.functions.invoke(
//            "get-vimeo-temporal-link",
//            options: FunctionInvokeOptions(
//                body: ["videoId": videoId]
//            )
//            )
////        print(response)
////        return response
//        return URL(string: response.link)!
//    }
//    
////    func fetchHLSLink(for videoId: String) async throws -> String {
//    private func getVideoFromVimeo(for videoId: String) async throws -> SupabaseVideo {
//        guard let url = URL(string: baseURL + videoId) else {
//            throw VimeoError.invalidURL
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse else {
//            throw VimeoError.networkError(NSError(domain: "Network", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP Response"]))
//        }
//        
//        if httpResponse.statusCode != 200 {
//            print("Vimeo API Error:")
//            print("Status Code: \(httpResponse.statusCode)")
//            if let responseData = String(data: data, encoding: .utf8) {
//                print("Response Body: \(responseData)")
//            }
//            throw VimeoError.videoAccessDenied
//        }
//        
//        print(String(data: data, encoding: .utf8))
////        print(videoId)
////        guard let fileURL = Bundle.main.url(forResource: "vimeo_response_test", withExtension: "json") else {
////            print("File not found")
////            throw VimeoError.testingError
////        }
////        let data = try Data(contentsOf: fileURL)
//        
//        do {
////            let decoder = JSONDecoder()
////            
////            // Custom date formatter for the exact format
////            let dateFormatter = DateFormatter()
////            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
////            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
////            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
////            
////            decoder.dateDecodingStrategy = .formatted(dateFormatter)
////            
////            let vimeoResponse = try decoder.decode(VimeoResponse.self, from: data)
//            
//            let vimeoResponse = try JSONDecoder.supabaseDateDecoder.decode(VimeoResponse.self, from: data)
//            
//            print(vimeoResponse)
//            
//            guard let video = vimeoResponse.play.progressive.first (where: { $0.rendition == "720p" }) else {
//                throw VimeoError.invalidURL
//            }
//            print("The video is\n", video)
//            let supabaseVideo: SupabaseVideo = .init(
//                videoId: videoId,
//                link: video.link,
//                linkExpirationTime: video.linkExpirationTime
//            )
//            return supabaseVideo
//            
//        } catch let error as DecodingError {
//            throw VimeoError.decodingError(error)
//        } catch {
//            throw VimeoError.networkError(error)
//        }
//    }
//}
//
//
//
//
