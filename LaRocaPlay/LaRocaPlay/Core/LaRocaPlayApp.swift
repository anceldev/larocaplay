//
//  LaRocaPlayApp.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 1/8/25.
//

import AVKit
import ConfidentialKit
import FirebaseCore
import FirebaseMessaging
import RevenueCat
import RevenueCatUI
import SwiftData
import SwiftUI
import UserNotifications
import os

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // FCM Token recibido
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        // Enviamos el token a Supabase a través de nuestro Manager
        NotificationManager.shared.updateTokenInSupabase(token: token)
    }
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        NotificationManager.shared.updateTokenInSupabase()
//    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        NotificationManager.shared.handleNotificationResponse(userInfo: userInfo)
        completionHandler()
    }
    
}

@main
struct LaRocaPlayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @State private var network = NetworkMonitor.shared
    @State private var authManager: AuthManager
    @State private var libManager: LibraryManager
    
    let container: ModelContainer
    private let logger = Logger(subsystem: "com.anceldev.LaRocaPlay", category: "main")
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Secrets.$testStore)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            let schema = Schema([
                UserProfile.self,
                Preach.self,
                Preacher.self,
                Collection.self,
                CollectionType.self,
                CollectionItem.self,
                ExternalLink.self,
                Song.self
            ])
            logger.info("\(URL.documentsDirectory.path(percentEncoded: false), privacy: .public)")
            
            let config = ModelConfiguration("db.v1.4.2", schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: config)
            
            let manager = AuthManager(service: AuthService())
            manager.setContext(modelContext: self.container.mainContext)
            self._authManager = State(initialValue: manager)
            
            let libManager = LibraryManager(
                service: LibraryService(), context: self.container.mainContext)
            self._libManager = State(initialValue: libManager)
            
            
//            let notificationManager = NotificationManager(service: NotificationService())
//            self._notificationManager = State(initialValue: notificationManager)
            
            do {
                try audioSession.setCategory(.playback, mode: .moviePlayback, options: [])
                try audioSession.setActive(true)
            } catch {
                logger.error("ERROR: Error configurando la sesión de audio \(error)")
            }
        } catch {
            logger.fault("Error al inicializar SwiftData: \(error.localizedDescription)")
            fatalError("Error al inicializar SwiftData: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                Group {
                    switch authManager.navigationState {
                    case .loading:
                        ProgressView {
                            Text("Cargando")
                        }
                        .tint(.customRed)
                    case .onboarding:
                        OnboardingScreen()
                        
                    case .authorized:
                        RootView()
                    case .updatePassword:
//                        UpdatePasswordForm()
                        UpdatePasswordScreen()
                    }
                }
                .environment(authManager)
                .environment(libManager)
                .environment(network)
                .modelContainer(container)
            }
            .supportOfflineMode(isConnected: network.isConnected)
            .preferredColorScheme(.dark)
            .task {
                await authManager.initialize()
            }
            .onOpenURL { url in
                authManager.getSesssionFromUrlCode(url: url)
            }
        }
    }
}

#if canImport(HotSwiftUI)
@_exported import HotSwiftUI
#elseif canImport(Inject)
@_exported import Inject
#else
// This code can be found in the Swift package:
// https://github.com/johnno1962/HotSwiftUI

#if DEBUG
import Combine

private var loadInjectionOnce: () = {
    guard objc_getClass("InjectionClient") == nil else {
        return
    }
#if os(macOS) || targetEnvironment(macCatalyst)
    let bundleName = "macOSInjection.bundle"
#elseif os(tvOS)
    let bundleName = "tvOSInjection.bundle"
#elseif os(visionOS)
    let bundleName = "xrOSInjection.bundle"
#elseif targetEnvironment(simulator)
    let bundleName = "iOSInjection.bundle"
#else
    let bundleName = "maciOSInjection.bundle"
#endif
    let bundlePath = "/Applications/InjectionIII.app/Contents/Resources/" + bundleName
    guard let bundle = Bundle(path: bundlePath), bundle.load() else {
        return print(
          """
          ⚠️ Could not load injection bundle from \(bundlePath). \
          Have you downloaded the InjectionIII.app from either \
          https://github.com/johnno1962/InjectionIII/releases \
          or the Mac App Store?
          """)
    }
}()

public let injectionObserver = InjectionObserver()

public class InjectionObserver: ObservableObject {
    @Published var injectionNumber = 0
    var cancellable: AnyCancellable? = nil
    let publisher = PassthroughSubject<Void, Never>()
    init() {
        _ = loadInjectionOnce  // .enableInjection() optional Xcode 16+
        cancellable = NotificationCenter.default.publisher(
            for:
                Notification.Name("INJECTION_BUNDLE_NOTIFICATION")
        )
        .sink { [weak self] change in
            self?.injectionNumber += 1
            self?.publisher.send()
        }
    }
}

extension SwiftUI.View {
    public func eraseToAnyView() -> some SwiftUI.View {
        _ = loadInjectionOnce
        return AnyView(self)
    }
    public func enableInjection() -> some SwiftUI.View {
        return eraseToAnyView()
    }
    public func loadInjection() -> some SwiftUI.View {
        return eraseToAnyView()
    }
    public func onInjection(bumpState: @escaping () -> Void) -> some SwiftUI.View {
        return
        self
            .onReceive(injectionObserver.publisher, perform: bumpState)
            .eraseToAnyView()
    }
}

@available(iOS 13.0, *)
@propertyWrapper
public struct ObserveInjection: DynamicProperty {
    @ObservedObject private var iO = injectionObserver
    public init() {}
    public private(set) var wrappedValue: Int {
        get { 0 }
        set {}
    }
}
#else
extension SwiftUI.View {
    @inline(__always)
    public func eraseToAnyView() -> some SwiftUI.View { return self }
    @inline(__always)
    public func enableInjection() -> some SwiftUI.View { return self }
    @inline(__always)
    public func loadInjection() -> some SwiftUI.View { return self }
    @inline(__always)
    public func onInjection(bumpState: @escaping () -> Void) -> some SwiftUI.View {
        return self
    }
}

@available(iOS 13.0, *)
@propertyWrapper
public struct ObserveInjection {
    public init() {}
    public private(set) var wrappedValue: Int {
        get { 0 }
        set {}
    }
}
#endif
#endif
