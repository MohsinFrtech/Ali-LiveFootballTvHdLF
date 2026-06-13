import UIKit
import Flutter
import AVFoundation
import AVKit
import MediaPlayer
@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if let registrar = self.registrar(forPlugin: "NativeVideoPlayer") {
            let factory = NativeVideoPlayerFactory(messenger: registrar.messenger())
            registrar.register(factory, withId: "ios_native_video_player")

            let advancedFactory = AdvancedVideoPlayerFactory(messenger: registrar.messenger())
            registrar.register(advancedFactory, withId: "ios_advanced_video_player")
        }


        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

// MARK: - Factory
class NativeVideoPlayerFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return NativeVideoPlayerView(frame: frame, args: args, messenger: messenger, viewId: viewId)
    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class AdvancedVideoPlayerFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    init(messenger: FlutterBinaryMessenger) { self.messenger = messenger; super.init() }
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return AdvancedNativeVideoPlayerView(frame: frame, args: args, messenger: messenger, viewId: viewId)
    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol { return FlutterStandardMessageCodec.sharedInstance() }
}

class AdvancedNativeVideoPlayerView: NSObject, FlutterPlatformView {
    private var _containerView: AdvancedPlayerContainerView
    private var _spinner: UIActivityIndicatorView
    private var _player: AVQueuePlayer?
    private var _channel: FlutterMethodChannel
    private var _playerLayer: AVPlayerLayer?

    private var _statusObserver: NSKeyValueObservation?
    private var _bufferEmptyObserver: NSKeyValueObservation?
    private var _keepUpObserver: NSKeyValueObservation?
    private var _swapObserver: NSKeyValueObservation?
    private var _refreshTimer: Timer?
    private var _currentGravity: AVLayerVideoGravity = .resize

    private var _watchdogTimer: Timer?
    private var _lastCheckTime: CMTime = .zero
    private var _consecutiveStalledTicks: Int = 0

    // 2. Add the route picker variable here
    private var _routePickerView: AVRoutePickerView?

    init(frame: CGRect, args: Any?, messenger: FlutterBinaryMessenger, viewId: Int64) {
        _containerView = AdvancedPlayerContainerView(frame: frame)
        _containerView.backgroundColor = .black
        _spinner = UIActivityIndicatorView(style: .large)
        _spinner.color = .white
        _spinner.hidesWhenStopped = true
        _spinner.translatesAutoresizingMaskIntoConstraints = false
        _containerView.addSubview(_spinner)
        // This ensures the iOS presentation engine can anchor and trigger the AirPlay popover framework successfully.
        _routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        _routePickerView?.isHidden = false
        _routePickerView?.alpha = 0.01
        _routePickerView?.prioritizesVideoDevices = true
        if let picker = _routePickerView {
            _containerView.addSubview(picker)
        }

        _channel = FlutterMethodChannel(name: "ios_advanced_video_player_\(viewId)", binaryMessenger: messenger)
        super.init()
        setupConstraints()
        setupMethodChannel()
        if let params = args as? [String: Any], let urlStr = params["url"] as? String {
            setupPlayer(url: URL(string: urlStr)!)
        }
    }

    private func setupMethodChannel() {
        _channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "updateUrl", let args = call.arguments as? [String: Any], let urlStr = args["url"] as? String {
                self?.updateUrl(URL(string: urlStr)!)
            } else if call.method == "updateExpiry", let args = call.arguments as? [String: Any], let ts = args["timestamp"] as? Double {
                self?.startRefreshTimer(expiryTimestamp: ts)
            }else if call.method == "setVideoGravity" {
                // Handle the dynamic gravity changes sent from Flutter
                if let gravityMode = call.arguments as? String {
                    self?.updateVideoGravity(gravityMode)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected a String", details: nil))
                }
            }else if call.method == "triggerAirPlay" {
                // 4. Handle the custom Cast request fired from Dart
                self?.openAirPlayPicker()
                result(nil)
            }
            result(nil)
        }
    }

    private func setupPlayer(url: URL) {
        setLoading(true)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .allowBluetooth)
        let item = AVPlayerItem(url: url)
        item.automaticallyPreservesTimeOffsetFromLive = true

        let player = AVQueuePlayer(items: [item])
        player.automaticallyWaitsToMinimizeStalling = true

        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        _player = player

        let layer = AVPlayerLayer(player: player)
        _playerLayer = layer
        layer.videoGravity = _currentGravity
        _containerView.playerLayer = layer
        _containerView.layer.insertSublayer(layer, at: 0)

        observeItem(item)

        player.play()
        updateNowPlayingInfo()
        startWatchdog()
        _channel.invokeMethod("requestExpiryExtraction", arguments: ["url": url.absoluteString])
    }

    private func openAirPlayPicker() {
        DispatchQueue.main.async { [weak self] in
            guard let picker = self?._routePickerView else { return }
            // Recursively search the view's hierarchy to tap Apple's structural button asset
            if let routePickerButton = picker.subviews.first(where: { $0 is UIButton }) as? UIButton {
                routePickerButton.sendActions(for: .touchUpInside)
            }
        }
    }


    private func updateVideoGravity(_ mode: String) {
        // 1. Map the string from Dart to native types and save it globally
        switch mode {
        case "stretch": _currentGravity = .resize
        case "fill":    _currentGravity = .resizeAspectFill
        case "fit":     _currentGravity = .resizeAspect
        default:        _currentGravity = .resize
        }

        // 2. Apply it immediately to the active player layer on the main UI thread
        guard let playerLayer = _playerLayer else { return }
        DispatchQueue.main.async {
            playerLayer.videoGravity = self._currentGravity
        }
    }

    // MARK: - Watchdog Engine (Standard)
    private func startWatchdog() {
        stopWatchdog()
        _consecutiveStalledTicks = 0
        guard let player = _player else { return }
        _lastCheckTime = player.currentTime()

        _watchdogTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self._player else { return }

            if player.rate > 0 && player.timeControlStatus != .paused {
                let currentTime = player.currentTime()

                if currentTime == self._lastCheckTime {
                    self._consecutiveStalledTicks += 1
                    let totalStalledTime = self._consecutiveStalledTicks * 10
                    print("⚠️ NATIVE (Standard): Stream timeline frozen. Duration: \(totalStalledTime)s")

                    if self._consecutiveStalledTicks == 1 {
                        print("🚨 NATIVE (Standard): 10 seconds of freeze reached. Sending link refresh request...")
                        self._channel.invokeMethod("onStuck", arguments: nil)
                    }

                    if self._consecutiveStalledTicks >= 6 {
                        print("💀 NATIVE (Standard): Stream completely locked for 1 minute. Notifying dead state.")
                        self.stopWatchdog()
                        self._channel.invokeMethod("onPlayerDead", arguments: nil)
                    }
                } else {
                    self._consecutiveStalledTicks = 0
                }
                self._lastCheckTime = currentTime
            }
        }
    }

    private func stopWatchdog() {
        _watchdogTimer?.invalidate()
        _watchdogTimer = nil
    }


    private func updateUrl(_ url: URL) {
        print("🚀 NATIVE: Performing Hard Swap with Masking...")

        // 1. Capture current frame as a static image
        if let snapshot = _containerView.snapshotView(afterScreenUpdates: false) {
            snapshot.tag = 999
            _containerView.addSubview(snapshot)
        }

        // 2. Prepare new item
        let newItem = AVPlayerItem(url: url)
        newItem.automaticallyPreservesTimeOffsetFromLive = true

        // 3. Immediately kill the old connection and swap
        self.invalidateItemObservers()
        _player?.replaceCurrentItem(with: newItem)
        self.observeItem(newItem)
        _player?.playImmediately(atRate: 1.0)

        // 4. Wait for new video to actually render before hiding the snapshot
        _swapObserver = newItem.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            if item.isPlaybackLikelyToKeepUp {
                DispatchQueue.main.async { self?.removeSnapshotWithFade() }
            }
        }

        // 5. Safety: Force remove snapshot after 4s if buffer is slow
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.removeSnapshotWithFade()
        }

        _channel.invokeMethod("requestExpiryExtraction", arguments: ["url": url.absoluteString])

        // Refresh Now Playing metadata for the new stream
        updateNowPlayingInfo()
    }

    private func removeSnapshotWithFade() {
        guard let snapshot = _containerView.viewWithTag(999) else { return }
        UIView.animate(withDuration: 0.4, animations: {
            snapshot.alpha = 0
        }) { _ in
            snapshot.removeFromSuperview()
        }
        _swapObserver?.invalidate()
        _swapObserver = nil
        setLoading(false)
    }

    private func startRefreshTimer(expiryTimestamp: Double) {
        _refreshTimer?.invalidate()
        // Start refresh 20s before expiry
        let delay = expiryTimestamp - Date().timeIntervalSince1970 - 20
        DispatchQueue.main.async {
            self._refreshTimer = Timer.scheduledTimer(withTimeInterval: max(delay, 1.0), repeats: false) { [weak self] _ in
                self?._channel.invokeMethod("requestRefresh", arguments: nil)
            }
        }
    }

    private func observeItem(_ item: AVPlayerItem) {
        _bufferEmptyObserver = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] i, _ in
            // Don't show spinner if we are in the middle of a swap mask
            if i.isPlaybackBufferEmpty && self?._containerView.viewWithTag(999) == nil {
                self?.setLoading(true)
            }
        }
        _keepUpObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] i, _ in
            if i.isPlaybackLikelyToKeepUp { self?.setLoading(false) }


        }
        _statusObserver = item.observe(\.status, options: [.new]) { [weak self] i, _ in
            if i.status == .failed { self?._channel.invokeMethod("onError", arguments: i.error?.localizedDescription) }
        }
    }

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle]             = "Live"          // or your stream title
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        info[MPMediaItemPropertyMediaType]         = MPMediaType.tvShow.rawValue
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }


    private func setLoading(_ loading: Bool) {
        DispatchQueue.main.async { loading ? self._spinner.startAnimating() : self._spinner.stopAnimating() }
    }

    private func invalidateItemObservers() {
        _statusObserver?.invalidate(); _statusObserver?.invalidate();
        _bufferEmptyObserver?.invalidate();
        _bufferEmptyObserver?.invalidate(); _keepUpObserver?.invalidate()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
                                        _spinner.centerXAnchor.constraint(equalTo: _containerView.centerXAnchor),
                                        _spinner.centerYAnchor.constraint(equalTo: _containerView.centerYAnchor)
                                    ])
    }

    func view() -> UIView { return _containerView }

    deinit {
        stopWatchdog();
        clearNowPlayingInfo();
        _refreshTimer?.invalidate(); _swapObserver?.invalidate(); invalidateItemObservers()
        _player?.pause(); _player?.removeAllItems(); _player = nil
    }
}


class AdvancedPlayerContainerView: UIView {
    var playerLayer: AVPlayerLayer?
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer?.frame = self.bounds
        CATransaction.commit()
    }
}

// MARK: - Custom Container
// This class is the "Fix". It listens for size changes from Flutter
// and stretches the Video Layer to match.
class PlayerContainerView: UIView {
    var playerLayer: AVPlayerLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        // Force the video layer to fill the entire view bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true) // Prevents the layer from "sliding" into place
        playerLayer?.frame = self.bounds
        CATransaction.commit()
    }
}

// MARK: - Native View
class NativeVideoPlayerView: NSObject, FlutterPlatformView {
    private var _containerView: PlayerContainerView
    private var _spinner: UIActivityIndicatorView
    private var _player: AVPlayer?
    private var _playerLayer: AVPlayerLayer?
    private var _channel: FlutterMethodChannel

    private var _timeControlObserver: NSKeyValueObservation?
    private var _statusObserver: NSKeyValueObservation?
    private var _isErrorState: Bool = false
    // Add this near your other variable declarations like _player and _playerLayer
    private var _currentGravity: AVLayerVideoGravity = .resize
    private var _bufferEmptyObserver: NSKeyValueObservation?
    private var _likelyToKeepUpObserver: NSKeyValueObservation?

    private var _watchdogTimer: Timer?
    private var _lastCheckTime: CMTime = .zero
    private var _consecutiveStalledTicks: Int = 0

    // 2. Add the route picker variable here
    private var _routePickerView: AVRoutePickerView?

    private var _referer: String?

    init(frame: CGRect, args: Any?, messenger: FlutterBinaryMessenger, viewId: Int64) {
        _containerView = PlayerContainerView(frame: frame)
        _containerView.backgroundColor = .black

        _spinner = UIActivityIndicatorView(style: .large)
        _spinner.color = .white
        _spinner.hidesWhenStopped = true
        _spinner.translatesAutoresizingMaskIntoConstraints = false
        _containerView.addSubview(_spinner)

        // This ensures the iOS presentation engine can anchor and trigger the AirPlay popover framework successfully.
        _routePickerView = AVRoutePickerView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        _routePickerView?.isHidden = false
        _routePickerView?.alpha = 0.01
        _routePickerView?.prioritizesVideoDevices = true
        if let picker = _routePickerView {
            _containerView.addSubview(picker)
        }

        _channel = FlutterMethodChannel(name: "ios_native_video_player_\(viewId)", binaryMessenger: messenger)

        super.init()
        //     Listen for method calls from Flutter
        _channel.setMethodCallHandler { [weak self] (call, result) in
            if call.method == "play" {
                self?._player?.play()
                result(nil)
            } else if call.method == "pause" {
                self?._player?.pause()
                result(nil)
            }else if call.method == "setVideoGravity" {
                // Handle the dynamic gravity changes sent from Flutter
                if let gravityMode = call.arguments as? String {
                    self?.updateVideoGravity(gravityMode)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Expected a String", details: nil))
                }
            }else if call.method == "updateUrl"{
                if let args = call.arguments as? [String: Any],
                   let urlStr = args["url"] as? String,
                   let url = URL(string: urlStr) {
                    // Capture new referer if passed during a dynamic update
                    if let newReferer = args["referer"] as? String {
                        self?._referer = newReferer
                    }
                    self?.updateUrl(url)
                }
                result(nil)
            }else if call.method == "triggerAirPlay" {
                // 4. Handle the custom Cast request fired from Dart
                self?.openAirPlayPicker()
                result(nil)
            }
            else {
                result(FlutterMethodNotImplemented)
            }
        }
        NSLayoutConstraint.activate([
                                        _spinner.centerXAnchor.constraint(equalTo: _containerView.centerXAnchor),
                                        _spinner.centerYAnchor.constraint(equalTo: _containerView.centerYAnchor)
                                    ])


        if let params = args as? [String: Any] {
            self._referer = params["referer"] as? String

            if let urlString = params["url"] as? String,
               let url = URL(string: urlString) {
                setupPlayer(url: url)
            }
        }
    }
    // Helper helper to build asset options conditionally
    private func createAssetOptions() -> [String: Any] {
        var httpHeaders: [String: String] = [:]

        // ✅ CRUCIAL FIX: If referer is empty or nil, it is NOT added to the dictionary.
        // iOS will completely omit the header instead of sending an empty string.
        if let ref = _referer, !ref.isEmpty {
            httpHeaders["Referer"] = ref
        }

        if httpHeaders.isEmpty {
            return [:]
        } else {
            return ["AVURLAssetHTTPHeaderFieldsKey": httpHeaders]
        }
    }

    private func updateUrl(_ url: URL) {
        print("🚀 NATIVE (Standard): Performing dynamic URL swap...")

        // Reset watchdog counters for the new stream window
        self._consecutiveStalledTicks = 0
        self._lastCheckTime = .zero

        let options = createAssetOptions()
        let asset = AVURLAsset(url: url, options: options)
        let newItem = AVPlayerItem(asset: asset)

        // Kill observers on the older item context, swap elements, and observe the new asset
        self.invalidateItemObservers()
        _player?.replaceCurrentItem(with: newItem)

        // if #available(iOS 16.0, *) {
        //     _routePickerView?.player = _player
        // }

        self.observeItem(newItem)
        _player?.play()

        // Refresh Now Playing metadata for the new stream
        updateNowPlayingInfo()
    }


    private func setupPlayer(url: URL) {
        // Explicitly set route sharing policy for video playback redirection
        let audioSession = AVAudioSession.sharedInstance()
        // Set Category so sound plays even on Silent Mode
        // try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? audioSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormVideo, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)

        let options = createAssetOptions()
        let asset = AVURLAsset(url: url, options: options)

        let playerItem = AVPlayerItem(asset: asset)
        playerItem.preferredForwardBufferDuration = 15
        playerItem.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        playerItem.automaticallyPreservesTimeOffsetFromLive = true

        let player = AVPlayer(playerItem: playerItem)

// 5. CRUCIAL: Instruct the player instance to allow external stream mirrors
        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true

        player.automaticallyWaitsToMinimizeStalling = true
        _player = player

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = _currentGravity
        _playerLayer = playerLayer

        // Connect the layer to the container's logic
        _containerView.playerLayer = playerLayer
        _containerView.layer.insertSublayer(playerLayer, at: 0)

        updateLoadingState(true)
        // Monitor Buffering & Playback
        _timeControlObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                if player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self?.updateLoadingState(true)
                } else {
                    self?.updateLoadingState(false)
                }

                // ✅ FIX #2: Update Now Playing info when playback actually starts
                if player.timeControlStatus == .playing {
                    self?.updateNowPlayingInfo()
                }
            }
        }


        observeItem(playerItem)
        player.play()
        startWatchdog()
    }

    private func updateNowPlayingInfo() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle]             = "Live"          // or your stream title
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        info[MPMediaItemPropertyMediaType]         = MPMediaType.tvShow.rawValue
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func openAirPlayPicker() {
        DispatchQueue.main.async { [weak self] in
            guard let picker = self?._routePickerView else { return }
            // Recursively search the view's hierarchy to tap Apple's structural button asset
            if let routePickerButton = picker.subviews.first(where: { $0 is UIButton }) as? UIButton {
                routePickerButton.sendActions(for: .touchUpInside)
            }
        }
    }
    // private func openAirPlayPicker() {
    //     DispatchQueue.main.async { [weak self] in
    //         guard let self = self, let picker = self._routePickerView else { return }
    //
    //         if #available(iOS 16.0, *) {
    //             // On iOS 16+, with .player set, just simulate tap normally
    //             picker.sendAction(#selector(UIControl.touchUpInside), to: nil, for: nil)
    //         }
    //
    //         // Fallback for all iOS versions — walk subviews for the UIButton
    //         func findAndTapButton(in view: UIView) -> Bool {
    //             for subview in view.subviews {
    //                 if let button = subview as? UIButton {
    //                     button.sendActions(for: .touchUpInside)
    //                     return true
    //                 }
    //                 if findAndTapButton(in: subview) { return true }
    //             }
    //             return false
    //         }
    //         _ = findAndTapButton(in: picker)
    //     }
    // }
    private func observeItem(_ item: AVPlayerItem) {
        // Monitor Errors
        _statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                if item.status == .failed {
                    self?._isErrorState = true
                    self?.updateLoadingState(true)
                    let errorMsg = item.error?.localizedDescription ?? "Playback Failed"
                    self?._channel.invokeMethod("onError", arguments: errorMsg)
                }
            }
        }

        _bufferEmptyObserver = item.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] i, _ in
            DispatchQueue.main.async { if i.isPlaybackBufferEmpty { self?.updateLoadingState(true) } }
        }

        _likelyToKeepUpObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] i, _ in
            DispatchQueue.main.async {
                if i.isPlaybackLikelyToKeepUp {
                    self?.updateLoadingState(false)
                    self?._player?.play()
                }
            }
        }
    }

    private func updateVideoGravity(_ mode: String) {
        // 1. Map the string from Dart to native types and save it globally
        switch mode {
        case "stretch": _currentGravity = .resize
        case "fill":    _currentGravity = .resizeAspectFill
        case "fit":     _currentGravity = .resizeAspect
        default:        _currentGravity = .resize
        }

        // 2. Apply it immediately to the active player layer on the main UI thread
        guard let playerLayer = _playerLayer else { return }
        DispatchQueue.main.async {
            playerLayer.videoGravity = self._currentGravity
        }
    }

    // MARK: - Watchdog Engine (Standard)
    private func startWatchdog() {
        stopWatchdog()
        _consecutiveStalledTicks = 0
        guard let player = _player else { return }
        _lastCheckTime = player.currentTime()

        _watchdogTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self._player else { return }

            if player.rate > 0 && player.timeControlStatus != .paused {
                let currentTime = player.currentTime()

                if currentTime == self._lastCheckTime {
                    self._consecutiveStalledTicks += 1
                    let totalStalledTime = self._consecutiveStalledTicks * 10
                    print("⚠️ NATIVE (Standard): Stream timeline frozen. Duration: \(totalStalledTime)s")

                    if self._consecutiveStalledTicks == 1 {
                        print("🚨 NATIVE (Standard): 10 seconds of freeze reached. Sending link refresh request...")
                        self._channel.invokeMethod("onStuck", arguments: nil)
                    }

                    if self._consecutiveStalledTicks >= 6 {
                        print("💀 NATIVE (Standard): Stream completely locked for 1 minute. Notifying dead state.")
                        self.stopWatchdog()
                        self._channel.invokeMethod("onPlayerDead", arguments: nil)
                    }
                } else {
                    self._consecutiveStalledTicks = 0
                }
                self._lastCheckTime = currentTime
            }
        }
    }

    private func stopWatchdog() {
        _watchdogTimer?.invalidate()
        _watchdogTimer = nil
    }

    private func invalidateItemObservers() {
        _statusObserver?.invalidate()
        _bufferEmptyObserver?.invalidate()
        _likelyToKeepUpObserver?.invalidate()
    }

    private func updateLoadingState(_ isLoading: Bool) {
        if _isErrorState || isLoading {
            _spinner.startAnimating()
            _containerView.bringSubviewToFront(_spinner)
        } else {
            _spinner.stopAnimating()
        }
    }

    func view() -> UIView {
        return _containerView
    }

    deinit {
        stopWatchdog()
        _statusObserver?.invalidate()
        invalidateItemObservers()
        _timeControlObserver?.invalidate()
        _player?.pause()
        _playerLayer?.removeFromSuperlayer()
        _player = nil
        clearNowPlayingInfo()
    }
}
