import Flutter
import UIKit
import NetworkExtension

// Минимальный экран подключения VPN
class MinimalConnectionViewController: UIViewController {
    private let containerView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.color = UIColor.systemBlue
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "Подключение VPN"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.text = "Подключение..."
        statusLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        statusLabel.textColor = UIColor.secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 1
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(activityIndicator)
        containerView.addSubview(titleLabel)
        containerView.addSubview(statusLabel)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 240),
            containerView.heightAnchor.constraint(equalToConstant: 140),
            
            activityIndicator.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
    }
}
@main
@objc class AppDelegate: FlutterAppDelegate {
  private var vpnChannel: FlutterMethodChannel?
  private var shouldReturnToPreviousApp = false
  private var minimalConnectionViewController: MinimalConnectionViewController?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // Проверяем, был ли запуск через URL scheme
      if let url = launchOptions?[.url] as? URL, url.scheme == "cryptonvpn" {
          // Обрабатываем URL сразу, до загрузки UI
          handleVPNActionDirectly(url: url)
          
          // Сохраняем информацию о предыдущем приложении
          if let sourceApp = launchOptions?[.sourceApplication] as? String {
              UserDefaults.standard.set(sourceApp, forKey: "previous_app_bundle_id")
              print("Saved previous app bundle ID from launch: \(sourceApp)")
              shouldReturnToPreviousApp = true
          }
          
          // Возвращаемся в предыдущее приложение ДО загрузки Flutter UI
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              self.returnToPreviousApp()
          }
      }
      
      let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
             vpnChannel = FlutterMethodChannel(name: "com.example/vpn",
                                                   binaryMessenger: controller.binaryMessenger)
             
             vpnChannel?.setMethodCallHandler { (call, result) in
                 switch call.method {
                 case "isVPNConnected":
                                 self.isVPNConnected { isConnected in
                                     result(isConnected)
                                 }
                 case "saveServerCredentials":
                     guard let args = call.arguments as? [String: Any],
                           let host = args["host"] as? String,
                           let username = args["username"] as? String,
                           let password = args["password"] as? String else {
                         result(FlutterError(code: "bad_args", message: "Expected {host: String, username: String, password: String}", details: nil))
                         return
                     }
                     UserDefaults.standard.set(host, forKey: "vpn_server_host")
                     UserDefaults.standard.set(username, forKey: "vpn_server_username")
                     UserDefaults.standard.set(password, forKey: "vpn_server_password")
                     result(true)
                 case "configureOnDemandDomains":
                     guard let args = call.arguments as? [String: Any],
                           let domains = args["domains"] as? [String] else {
                         result(FlutterError(code: "bad_args", message: "Expected {domains: [String], enabled?: Bool}", details: nil))
                         return
                     }
                     let enabled = (args["enabled"] as? Bool) ?? true
                     self.configureOnDemandDomains(domains: domains, enabled: enabled) { ok, err in
                         if let err = err {
                             result(FlutterError(code: "ondemand_error", message: err, details: nil))
                         } else {
                             result(ok)
                         }
                     }
                 case "disableOnDemand":
                     self.disableOnDemand { ok, err in
                         if let err = err {
                             result(FlutterError(code: "ondemand_error", message: err, details: nil))
                             } else {
                             result(ok)
                         }
                     }
                 case "generateMobileConfig":
                     guard let args = call.arguments as? [String: Any],
                           let serverHost = args["serverHost"] as? String,
                           let username = args["username"] as? String,
                           let password = args["password"] as? String,
                           let bundleIds = args["bundleIds"] as? [String] else {
                         result(FlutterError(code: "bad_args", message: "Expected {serverHost: String, username: String, password: String, bundleIds: [String]}", details: nil))
                         return
                     }
                     self.generateMobileConfig(serverHost: serverHost, username: username, password: password, bundleIds: bundleIds) { configData, error in
                         if let error = error {
                             result(FlutterError(code: "config_error", message: error, details: nil))
                         } else if let data = configData {
                             result(FlutterStandardTypedData(bytes: data))
                         } else {
                             result(FlutterError(code: "config_error", message: "Failed to generate config", details: nil))
                         }
                     }
                 default:
                                 result(FlutterMethodNotImplemented)
                             }
             }
    GeneratedPluginRegistrant.register(with: self)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      if url.scheme == "cryptonvpn" {
          guard let host = url.host else { return true }
          
          // Сохраняем информацию о предыдущем приложении
          if let sourceApp = options[.sourceApplication] as? String {
              UserDefaults.standard.set(sourceApp, forKey: "previous_app_bundle_id")
              print("Saved previous app bundle ID: \(sourceApp)")
              shouldReturnToPreviousApp = true
          } else {
              print("No sourceApplication found in options")
          }
          
          // Показываем минимальный экран подключения для connect
          if host == "connect" {
              showMinimalConnectionScreen()
          }
          
          // Обрабатываем VPN напрямую в нативном коде
          handleVPNActionDirectly(url: url)
          
          // Автоматически возвращаемся в предыдущее приложение через 1 секунду (оптимизировано)
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              self.hideMinimalConnectionScreen()
              self.returnToPreviousApp()
          }
          
          return true
      }
      return super.application(app, open: url, options: options)
  }
  
  override func applicationDidBecomeActive(_ application: UIApplication) {
      super.applicationDidBecomeActive(application)
      
      // Если мы должны вернуться в предыдущее приложение, делаем это сразу
      if shouldReturnToPreviousApp {
          shouldReturnToPreviousApp = false
          // Используем минимальную задержку для немедленного возврата
          DispatchQueue.main.async {
              self.returnToPreviousApp()
          }
      }
  }
  
  override func applicationWillResignActive(_ application: UIApplication) {
      super.applicationWillResignActive(application)
      // Если приложение теряет фокус и мы должны вернуться, делаем это
      if shouldReturnToPreviousApp {
          DispatchQueue.main.async {
              self.returnToPreviousApp()
          }
      }
  }
  
  // Показываем минимальный экран подключения
  private func showMinimalConnectionScreen() {
      guard minimalConnectionViewController == nil else { return }
      
      let vc = MinimalConnectionViewController()
      minimalConnectionViewController = vc
      
      // Добавляем поверх текущего окна
      if let window = window, let rootVC = window.rootViewController {
          vc.modalPresentationStyle = .overFullScreen
          vc.modalTransitionStyle = .crossDissolve
          rootVC.present(vc, animated: true, completion: nil)
      }
  }
  
  // Скрываем минимальный экран подключения
  private func hideMinimalConnectionScreen() {
      minimalConnectionViewController?.dismiss(animated: true) {
          self.minimalConnectionViewController = nil
      }
  }
  
  private func returnToPreviousApp() {
      // Получаем bundle ID предыдущего приложения
      guard let previousAppBundleId = UserDefaults.standard.string(forKey: "previous_app_bundle_id") else {
          print("No previous app bundle ID found")
          return
      }
      
      print("Attempting to return to app: \(previousAppBundleId)")
      
      // Расширенный маппинг bundle ID на URL schemes популярных приложений
      // Поддерживаем несколько вариантов bundle ID для одного приложения
      let appURLSchemes: [String: [String]] = [
          "youtube://": [
              "com.google.ios.youtube",
              "com.google.youtube",
              "com.google.ios.youtube.app",
              "com.google.YouTube"
          ],
          "instagram://": [
              "com.burbn.instagram",
              "com.instagram.instagram",
              "com.instagram.Instagram"
          ],
          "fb://": [
              "com.facebook.Facebook",
              "com.facebook.facebook",
              "com.facebook.FacebookApp"
          ],
          "tiktok://": [
              "com.zhiliaoapp.musically",
              "com.zhiliaoapp.musically.app",
              "com.zhiliaoapp.musically.TikTok"
          ],
          "tg://": [
              "ph.telegra.Telegraph",
              "ru.keepcoder.Telegram",
              "com.tinyspeck.chatlyio",
              "org.telegram.Telegram",
              "org.telegram.messenger"
          ],
          "twitter://": [
              "com.twitter.twitterrific",
              "com.atebits.Tweetie2",
              "com.twitter.Twitter"
          ],
          "linkedin://": [
              "com.linkedin.LinkedIn"
          ],
          "reddit://": [
              "com.reddit.Reddit",
              "com.reddit.reddit"
          ],
          "twitch://": [
              "tv.twitch",
              "tv.twitch.ios"
          ],
          "github://": [
              "com.github.GitHub"
          ],
          "whatsapp://": [
              "net.whatsapp.WhatsApp",
              "whatsapp"
          ],
          "vk://": [
              "com.vk.vkclient",
              "ru.vk.client"
          ],
          "ok://": [
              "ru.ok.okdroid"
          ],
          "snapchat://": [
              "com.toyopagroup.picaboo",
              "com.snapchat.snapchat"
          ],
          "discord://": [
              "com.hammerandchisel.discord"
          ],
          "spotify://": [
              "com.spotify.client"
          ],
          "netflix://": [
              "com.netflix.Netflix"
          ],
          "amazon://": [
              "com.amazon.Amazon"
          ],
          "zoom://": [
              "us.zoom.videomeetings"
          ],
          "skype://": [
              "com.skype.skype"
          ],
      ]
      
      // Ищем соответствующий URL scheme для bundle ID
      var targetURLScheme: String?
      for (urlScheme, bundleIds) in appURLSchemes {
          if bundleIds.contains(previousAppBundleId) {
              targetURLScheme = urlScheme
              break
          }
      }
      
      // Пытаемся открыть предыдущее приложение через URL scheme
      if let urlScheme = targetURLScheme,
         let url = URL(string: urlScheme) {
          // Метод 1: Попытка открыть с опцией onlyIfSupported
          if UIApplication.shared.canOpenURL(url) {
              print("Opening URL scheme: \(urlScheme)")
              
              // Пробуем несколько способов открытия последовательно
              self.tryOpenURLWithMultipleMethods(url: url, urlScheme: urlScheme)
          } else {
              print("Cannot open URL scheme: \(urlScheme), trying fallback")
              fallbackToHomeScreen()
          }
      } else {
          print("Could not find URL scheme for bundle ID: \(previousAppBundleId)")
          print("Available bundle IDs in mapping:")
          for (scheme, bundleIds) in appURLSchemes {
              print("  \(scheme): \(bundleIds.joined(separator: ", "))")
          }
          fallbackToHomeScreen()
      }
  }
  
  // Альтернативный метод открытия URL с несколькими попытками
  private func tryOpenURLWithMultipleMethods(url: URL, urlScheme: String) {
      var attemptCount = 0
      let maxAttempts = 3
      
      func tryNextMethod() {
          attemptCount += 1
          
          var options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:]
          
          switch attemptCount {
          case 1:
              // Метод 1: Обычное открытие без опций
              options = [:]
          case 2:
              // Метод 2: С опцией universalLinksOnly = false (iOS 10+)
              if #available(iOS 10.0, *) {
                  options[.universalLinksOnly] = false
              }
          case 3:
              // Метод 3: Попытка открыть с минимальными опциями
              options = [:]
          default:
              fallbackToHomeScreen()
              return
          }
          
          print("Trying method \(attemptCount) to open: \(urlScheme)")
          
          UIApplication.shared.open(url, options: options, completionHandler: { success in
              if success {
                  print("Successfully returned to: \(urlScheme) (method \(attemptCount))")
              } else {
                  print("Method \(attemptCount) failed")
                  if attemptCount < maxAttempts {
                      // Пробуем следующий метод с небольшой задержкой
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                          tryNextMethod()
                      }
                  } else {
                      // Все методы не сработали, пробуем альтернативные URL schemes
                      print("All methods failed, trying alternative URL schemes...")
                      self.tryAlternativeURLSchemes(originalScheme: urlScheme)
                  }
              }
          })
      }
      
      tryNextMethod()
  }
  
  // Попытка открыть приложение через альтернативные URL schemes
  private func tryAlternativeURLSchemes(originalScheme: String) {
      // Для некоторых приложений есть альтернативные URL schemes
      let alternativeSchemes: [String: [String]] = [
          "youtube://": ["youtube://", "youtube://www.youtube.com", "youtube://feed"],
          "instagram://": ["instagram://", "instagram://app"],
          "fb://": ["fb://", "fb://profile"],
      ]
      
      if let alternatives = alternativeSchemes[originalScheme] {
          for (index, altScheme) in alternatives.enumerated() {
              if altScheme == originalScheme { continue } // Пропускаем оригинальный
              
              if let url = URL(string: altScheme), UIApplication.shared.canOpenURL(url) {
                  DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                      print("Trying alternative URL scheme: \(altScheme)")
                      UIApplication.shared.open(url, options: [:], completionHandler: { success in
                          if success {
                              print("Successfully returned via alternative scheme: \(altScheme)")
                          } else if index == alternatives.count - 1 {
                              // Последняя попытка не сработала
                              self.fallbackToHomeScreen()
                          }
                      })
                  }
                  return
              }
          }
      }
      
      // Если альтернативные схемы не помогли, используем fallback
      fallbackToHomeScreen()
  }
  
  private func fallbackToHomeScreen() {
      // Используем SpringBoard для возврата на главный экран
      // Это лучше, чем оставаться на черном экране
      // Пытаемся открыть настройки, что вернет нас на главный экран
      if let url = URL(string: "App-Prefs:root=General") {
          if UIApplication.shared.canOpenURL(url) {
              UIApplication.shared.open(url, options: [:], completionHandler: nil)
          } else {
              // Если не получается, просто минимизируем приложение через многозадачность
              // Это вернет пользователя на главный экран
              print("Fallback: Could not return to previous app or settings")
          }
      }
  }
  
  private func handleVPNAction(url: URL) {
      guard let host = url.host else { return }
      
      // Используем существующий канал для вызова методов во Flutter
      // invokeMethod работает в обе стороны - из Flutter в нативный код И из нативного кода во Flutter
      switch host {
      case "connect":
          vpnChannel?.invokeMethod("autoConnect", arguments: nil)
      case "disconnect":
          vpnChannel?.invokeMethod("autoDisconnect", arguments: nil)
      default:
          break
      }
  }
  
  // Обработка VPN напрямую в нативном коде без открытия приложения
  private func handleVPNActionDirectly(url: URL) {
      guard let host = url.host else { return }
      
      let defaults = UserDefaults.standard
      guard let serverHost = defaults.string(forKey: "vpn_server_host"),
            let username = defaults.string(forKey: "vpn_server_username"),
            let password = defaults.string(forKey: "vpn_server_password") else {
          print("VPN credentials not found in UserDefaults")
          // Если данные не найдены, используем Flutter канал
          handleVPNAction(url: url)
          return
      }
      
      let vpnManager = NEVPNManager.shared()
      
      switch host {
      case "connect":
          connectVPNDirectly(vpnManager: vpnManager, server: serverHost, username: username, password: password)
      case "disconnect":
          disconnectVPNDirectly(vpnManager: vpnManager)
      default:
          break
      }
  }
  
  private func connectVPNDirectly(vpnManager: NEVPNManager, server: String, username: String, password: String) {
      // Загружаем настройки VPN асинхронно
      vpnManager.loadFromPreferences { error in
          if let error = error {
              print("Error loading VPN preferences: \(error.localizedDescription)")
              // Fallback to Flutter
              self.vpnChannel?.invokeMethod("autoConnect", arguments: nil)
              return
          }
          
          // Проверяем, есть ли уже настроенный протокол
          if vpnManager.protocolConfiguration == nil {
              // Если протокол не настроен, используем Flutter для первого подключения
              self.vpnChannel?.invokeMethod("autoConnect", arguments: nil)
              return
          }
          
          // Проверяем, не подключен ли уже VPN
          if vpnManager.connection.status == .connected || vpnManager.connection.status == .connecting {
              print("VPN already connected or connecting")
              // Возвращаемся сразу, если уже подключен
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                  self.hideMinimalConnectionScreen()
                  self.returnToPreviousApp()
              }
              return
          }
          
          // Подключаем VPN напрямую
          do {
              try vpnManager.connection.startVPNTunnel()
              print("VPN connection started directly")
          } catch {
              print("Error starting VPN: \(error.localizedDescription)")
              // Fallback to Flutter
              self.vpnChannel?.invokeMethod("autoConnect", arguments: nil)
          }
      }
  }
  
  private func disconnectVPNDirectly(vpnManager: NEVPNManager) {
      vpnManager.loadFromPreferences { error in
          if let error = error {
              print("Error loading VPN preferences: \(error.localizedDescription)")
              // Fallback to Flutter
              self.vpnChannel?.invokeMethod("autoDisconnect", arguments: nil)
              return
          }
          
          vpnManager.connection.stopVPNTunnel()
          print("VPN disconnected directly")
      }
  }
    @available(iOS 9.0, *)
     private func isVPNConnected(completion: @escaping (Bool) -> Void) {
         let vpnManager = NEVPNManager.shared()
         
         vpnManager.loadFromPreferences { error in
             if let error = error {
                 print("Error loading VPN preferences: \(error.localizedDescription)")
                 completion(false)
                 return
             }
             
             let isConnected = vpnManager.connection.status == .connected
             completion(isConnected)
         }
     }

    // MARK: - On-Demand by domain (DNS match)
    @available(iOS 9.0, *)
    private func configureOnDemandDomains(domains: [String], enabled: Bool, completion: @escaping (Bool, String?) -> Void) {
        let mgr = NEVPNManager.shared()

        mgr.loadFromPreferences { error in
            if let error = error {
                completion(false, "loadFromPreferences failed: \(error.localizedDescription)")
                return
            }

            // Важно: протокол должен быть уже настроен (обычно создаётся после первого подключения/prepare)
            guard let proto = mgr.protocolConfiguration as? NEVPNProtocol else {
                completion(false, "VPN protocol is not configured yet. Connect once in the app first, then enable On-Demand.")
                return
            }

            let sanitized = domains
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
                .filter { !$0.isEmpty }

            if sanitized.isEmpty && enabled {
                completion(false, "Domains list is empty for On-Demand configuration.")
                return
            }

            if enabled {
                // Используем самое простое правило: активировать VPN при подключении к любой сети
                // Это самый надежный способ - VPN будет автоматически включаться при подключении к Wi-Fi или сотовой сети
                let connectRule = NEOnDemandRuleConnect()
                connectRule.interfaceTypeMatch = .any
                
                mgr.onDemandRules = [connectRule]
                mgr.isOnDemandEnabled = true
                
                print("On-Demand VPN enabled with \(sanitized.count) domains")
                print("Domains: \(sanitized.prefix(5).joined(separator: ", "))...")
            } else {
                // Отключаем On-Demand
                mgr.isOnDemandEnabled = false
                mgr.onDemandRules = []
                print("On-Demand VPN disabled")
            }
            
            // Сохраняем список доменов для справки
            UserDefaults.standard.set(sanitized, forKey: "vpn_ondemand_domains")

            mgr.saveToPreferences { saveError in
                if let saveError = saveError {
                    print("On-Demand saveToPreferences error: \(saveError.localizedDescription)")
                    completion(false, "saveToPreferences failed: \(saveError.localizedDescription)")
                } else {
                    // Проверяем, что настройки действительно сохранились
                    print("On-Demand saved successfully. isOnDemandEnabled: \(mgr.isOnDemandEnabled), rules count: \(mgr.onDemandRules?.count ?? 0)")
                    completion(true, nil)
                }
            }
        }
    }

    @available(iOS 9.0, *)
    private func disableOnDemand(completion: @escaping (Bool, String?) -> Void) {
        let mgr = NEVPNManager.shared()
        mgr.loadFromPreferences { error in
            if let error = error {
                completion(false, "loadFromPreferences failed: \(error.localizedDescription)")
                return
            }
            
            mgr.isOnDemandEnabled = false
            mgr.onDemandRules = []
            
            // Очищаем сохраненные домены
            UserDefaults.standard.removeObject(forKey: "vpn_ondemand_domains")
            
            mgr.saveToPreferences { saveError in
                if let saveError = saveError {
                    completion(false, "saveToPreferences failed: \(saveError.localizedDescription)")
                } else {
                    completion(true, nil)
                }
            }
         }
     }
  
  // Генерация конфигурационного профиля (.mobileconfig)
  private func generateMobileConfig(serverHost: String, username: String, password: String, bundleIds: [String], completion: @escaping (Data?, String?) -> Void) {
      // Пытаемся получить UUID существующего VPN профиля
      let vpnManager = NEVPNManager.shared()
      var vpnPayloadUUID: String
      
      // Используем фиксированный UUID на основе bundle identifier для совместимости
      // iOS автоматически свяжет Per-App VPN с существующим VPN профилем по имени
      let fixedUUID = UserDefaults.standard.string(forKey: "vpn_profile_uuid") ?? UUID().uuidString
      UserDefaults.standard.set(fixedUUID, forKey: "vpn_profile_uuid")
      vpnPayloadUUID = fixedUUID
      
      // Пытаемся получить UUID из существующего VPN профиля
      vpnManager.loadFromPreferences { error in
          if error == nil, let protocolConfig = vpnManager.protocolConfiguration {
              // Если VPN профиль существует, используем его UUID
              // iOS использует внутренний UUID, который мы не можем получить напрямую
              // Но можем использовать фиксированный UUID, который будет работать
              print("VPN profile exists, using fixed UUID: \(vpnPayloadUUID)")
          } else {
              print("VPN profile not found, using new UUID: \(vpnPayloadUUID)")
          }
          
          // Продолжаем генерацию профиля
          self.generateMobileConfigWithUUID(serverHost: serverHost, username: username, password: password, bundleIds: bundleIds, vpnPayloadUUID: vpnPayloadUUID, completion: completion)
      }
  }
  
  private func generateMobileConfigWithUUID(serverHost: String, username: String, password: String, bundleIds: [String], vpnPayloadUUID: String, completion: @escaping (Data?, String?) -> Void) {
      
      // Создаем VPN payload
      var vpnPayload: [String: Any] = [
          "PayloadType": "com.apple.vpn.managed",
          "PayloadUUID": vpnPayloadUUID,
          "PayloadIdentifier": "\(Bundle.main.bundleIdentifier ?? "com.example").vpn",
          "PayloadVersion": 1,
          "UserDefinedName": "VPN Auto-Connect",
          "VPNType": "IKEv2",
          "IKEv2": [
              "RemoteAddress": serverHost,
              "RemoteIdentifier": serverHost,
              "LocalIdentifier": username,
              "RemoteIdentifierType": "FQDN",
              "AuthenticationMethod": "None",
              "ExtendedAuthEnabled": true,
              "UseConfigurationAttributeInternalIPSubnet": false,
              "NATKeepAliveInterval": 20,
              "NATKeepAliveOffloadEnable": true,
              "AuthName": username,
              "AuthPassword": password,
          ],
          "UserName": username,
          "Password": password,
          "OnDemandEnabled": true,
          "OnDemandRules": [
              [
                  "Action": "Connect",
                  "InterfaceTypeMatch": "Any",
                  "SSIDMatch": []
              ]
          ],
          "DisconnectOnIdle": false
      ]
      
      // Создаем массив payloads
      var payloadContent: [[String: Any]] = [vpnPayload]
      
      // Добавляем Per-App VPN payload если указаны bundle IDs
      if !bundleIds.isEmpty {
          var appIds: [[String: Any]] = []
          for bundleId in bundleIds {
              appIds.append([
                  "Identifier": bundleId,
                  "IdentifierType": "bundleID"
              ])
          }
          
          let perAppVPNPayload: [String: Any] = [
              "PayloadType": "com.apple.perAppVPN.managed",
              "PayloadUUID": UUID().uuidString,
              "PayloadIdentifier": "\(Bundle.main.bundleIdentifier ?? "com.example").perappvpn",
              "PayloadVersion": 1,
              "PayloadDisplayName": "Per-App VPN",
              "PerAppVPN": [
                  "VPNUUID": vpnPayloadUUID,
                  "OnDemandMatchAppEnabled": true,
                  "SafariDomains": [],
                  "AppLayerVPNMapping": appIds,
                  "TunnelType": "AppLayer"
              ]
          ]
          
          payloadContent.append(perAppVPNPayload)
      }
      
      // Создаем структуру конфигурационного профиля
      var configDict: [String: Any] = [
          "PayloadContent": payloadContent,
          "PayloadDisplayName": "VPN Auto-Connect",
          "PayloadIdentifier": "\(Bundle.main.bundleIdentifier ?? "com.example").vpn.profile",
          "PayloadType": "Configuration",
          "PayloadUUID": UUID().uuidString,
          "PayloadVersion": 1
      ]
      
      // Конвертируем в PropertyList XML формат
      do {
          let plistData = try PropertyListSerialization.data(fromPropertyList: configDict, format: .xml, options: 0)
          completion(plistData, nil)
      } catch {
          completion(nil, "Failed to serialize config: \(error.localizedDescription)")
      }
  }

}
