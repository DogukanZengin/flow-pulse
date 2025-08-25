import Flutter
import UIKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Background task management
  private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
  private var backgroundTimerChannel: FlutterMethodChannel?
  private var batteryOptimizationChannel: FlutterMethodChannel?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window?.rootViewController as! FlutterViewController
    
    // Set up method channel for background timer
    backgroundTimerChannel = FlutterMethodChannel(
      name: "flow_pulse/background_timer",
      binaryMessenger: controller.binaryMessenger
    )
    
    backgroundTimerChannel?.setMethodCallHandler { [weak self] (call, result) in
      self?.handleBackgroundTimerCall(call: call, result: result)
    }
    
    // Set up method channel for battery optimization
    batteryOptimizationChannel = FlutterMethodChannel(
      name: "flow_pulse/battery_optimization",
      binaryMessenger: controller.binaryMessenger
    )
    
    batteryOptimizationChannel?.setMethodCallHandler { [weak self] (call, result) in
      self?.handleBatteryOptimizationCall(call: call, result: result)
    }
    
    // Setup background tasks and notifications
    setupBackgroundTasks()
    setupLowPowerModeNotifications()
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Background Tasks Setup
  
  private func setupBackgroundTasks() {
    // Register background app refresh task (iOS 13+)
    if #available(iOS 13.0, *) {
      BGTaskScheduler.shared.register(
        forTaskWithIdentifier: "com.flowpulse.timer-sync",
        using: nil
      ) { task in
        self.handleBackgroundAppRefresh(task: task as! BGAppRefreshTask)
      }
    }
  }
  
  @available(iOS 13.0, *)
  private func handleBackgroundAppRefresh(task: BGAppRefreshTask) {
    // Schedule next background refresh
    scheduleBackgroundAppRefresh()
    
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }
    
    // Sync timer state and notify Flutter
    DispatchQueue.main.async { [weak self] in
      self?.backgroundTimerChannel?.invokeMethod("backgroundAppRefresh", arguments: [
        "timestamp": Date().timeIntervalSince1970
      ])
    }
    
    task.setTaskCompleted(success: true)
  }
  
  @available(iOS 13.0, *)
  private func scheduleBackgroundAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.flowpulse.timer-sync")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
    
    try? BGTaskScheduler.shared.submit(request)
  }
  
  // MARK: - Battery Optimization Setup
  
  private func setupLowPowerModeNotifications() {
    NotificationCenter.default.addObserver(
      forName: .NSProcessInfoPowerStateDidChange,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.handleLowPowerModeChanged()
    }
  }
  
  private func handleLowPowerModeChanged() {
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    print("Low power mode changed: \(isLowPowerMode)")
    
    batteryOptimizationChannel?.invokeMethod("lowPowerModeChanged", arguments: [
      "enabled": isLowPowerMode
    ])
  }
  
  // MARK: - Background Timer Method Handlers
  
  private func handleBackgroundTimerCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startBackgroundTask":
      let arguments = call.arguments as? [String: Any]
      let reason = arguments?["reason"] as? String ?? "Timer session"
      let response = startBackgroundTask(reason: reason)
      result(response)
      
    case "endBackgroundTask":
      let arguments = call.arguments as? [String: Any]
      let taskId = arguments?["taskId"] as? Int ?? -1
      let response = endBackgroundTask(taskId: taskId)
      result(response)
      
    case "getRemainingBackgroundTime":
      let remainingTime = UIApplication.shared.backgroundTimeRemaining
      result(remainingTime)
      
    case "isBackgroundTaskActive":
      let isActive = backgroundTaskIdentifier != .invalid
      result(isActive)
      
    case "scheduleBackgroundRefresh":
      let arguments = call.arguments as? [String: Any]
      let sessionDuration = arguments?["sessionDuration"] as? Int ?? 0
      let startTime = arguments?["startTime"] as? TimeInterval ?? 0
      let response = scheduleBackgroundRefreshForSession(sessionDuration: sessionDuration, startTime: startTime)
      result(response)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func handleBatteryOptimizationCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkLowPowerMode":
      let response = checkLowPowerMode()
      result(response)
      
    case "getBatteryInfo":
      let response = getBatteryInfo()
      result(response)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Background Task Management
  
  private func startBackgroundTask(reason: String) -> [String: Any] {
    guard backgroundTaskIdentifier == .invalid else {
      return ["taskId": backgroundTaskIdentifier.rawValue, "success": false, "error": "Background task already running"]
    }
    
    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "TimerBackgroundTask") { [weak self] in
      self?.handleBackgroundTaskExpiration()
    }
    
    if backgroundTaskIdentifier == .invalid {
      return ["taskId": -1, "success": false, "error": "Failed to start background task"]
    }
    
    print("Background task started with ID: \(backgroundTaskIdentifier.rawValue)")
    
    // Notify Flutter that background task started
    DispatchQueue.main.async { [weak self] in
      self?.backgroundTimerChannel?.invokeMethod("backgroundTaskStarted", arguments: [
        "taskId": self?.backgroundTaskIdentifier.rawValue ?? -1
      ])
    }
    
    return ["taskId": backgroundTaskIdentifier.rawValue, "success": true]
  }
  
  private func endBackgroundTask(taskId: Int) -> [String: Any] {
    guard backgroundTaskIdentifier.rawValue == taskId && backgroundTaskIdentifier != .invalid else {
      return ["success": false, "error": "Invalid task ID or no background task running"]
    }
    
    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
    backgroundTaskIdentifier = .invalid
    
    print("Background task ended: \(taskId)")
    return ["success": true]
  }
  
  private func handleBackgroundTaskExpiration() {
    print("Background task expired, notifying Flutter")
    
    // Notify Flutter that the background task is about to expire
    DispatchQueue.main.async { [weak self] in
      self?.backgroundTimerChannel?.invokeMethod("backgroundTaskExpired", arguments: nil)
    }
    
    // Clean up the background task
    if backgroundTaskIdentifier != .invalid {
      UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
      backgroundTaskIdentifier = .invalid
    }
  }
  
  private func scheduleBackgroundRefreshForSession(sessionDuration: Int, startTime: TimeInterval) -> [String: Any] {
    if #available(iOS 13.0, *) {
      scheduleBackgroundAppRefresh()
      return ["success": true, "method": "BGAppRefreshTask"]
    } else {
      // Fallback for older iOS versions
      return ["success": true, "method": "legacy"]
    }
  }
  
  // MARK: - Battery Optimization Methods
  
  private func checkLowPowerMode() -> [String: Any] {
    let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
    return [
      "enabled": isLowPowerMode,
      "batteryLevel": UIDevice.current.batteryLevel,
      "batteryState": getBatteryState()
    ]
  }
  
  private func getBatteryInfo() -> [String: Any] {
    UIDevice.current.isBatteryMonitoringEnabled = true
    
    return [
      "level": UIDevice.current.batteryLevel,
      "state": getBatteryState(),
      "lowPowerMode": ProcessInfo.processInfo.isLowPowerModeEnabled
    ]
  }
  
  private func getBatteryState() -> String {
    UIDevice.current.isBatteryMonitoringEnabled = true
    
    switch UIDevice.current.batteryState {
    case .charging:
      return "charging"
    case .full:
      return "full"
    case .unplugged:
      return "unplugged"
    case .unknown:
      return "unknown"
    @unknown default:
      return "unknown"
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}