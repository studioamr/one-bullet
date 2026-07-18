// SPOTTER AI — app nativa de Mac (WKWebView). Su propia ventana, sin navegador.
import Cocoa
import WebKit

class Delegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ n: Notification) {
        let rect = NSRect(x: 0, y: 0, width: 1280, height: 840)
        window = NSWindow(contentRect: rect,
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        window.title = "SPOTTER AI"
        window.center()
        window.setFrameAutosaveName("SpotterMain")
        window.backgroundColor = .black
        window.minSize = NSSize(width: 900, height: 600)

        let cfg = WKWebViewConfiguration()
        let ucc = WKUserContentController()
        ucc.add(self, name: "spotter")     // puente: el botón Start Session lanza el Spotter
        cfg.userContentController = ucc
        webView = WKWebView(frame: rect, configuration: cfg)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.autoresizingMask = [.width, .height]
        webView.setValue(false, forKey: "drawsBackground") // fondo negro sin flash blanco
        window.contentView = webView

        if let res = Bundle.main.resourceURL {
            let index = res.appendingPathComponent("index.html")
            webView.loadFileURL(index, allowingReadAccessTo: res)
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { true }

    // Al volver a la app (tras una sesión), importa lo que el Spotter dejó en el journal.
    func applicationDidBecomeActive(_ n: Notification) { importJournal() }
    // Al terminar de cargar la plataforma, importa también.
    func webView(_ w: WKWebView, didFinish navigation: WKNavigation!) { importJournal() }

    // Lee ~/Library/Application Support/SpotterAI/journal/<fecha>.json (+ .png) que guardó el
    // Spotter y los inyecta al journal de la app (captura como data-URI + resumen de sesión).
    func importJournal() {
        guard let wv = webView else { return }
        let fm = FileManager.default
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support/SpotterAI/journal")
        guard let files = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { return }
        for f in files where f.pathExtension == "json" {
            guard let data = try? Data(contentsOf: f),
                  var obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let fecha = obj["fecha"] as? String else { continue }
            let png = dir.appendingPathComponent(fecha + ".png")
            if let img = try? Data(contentsOf: png) {
                obj["shot"] = "data:image/png;base64," + img.base64EncodedString()
            }
            guard let payload = try? JSONSerialization.data(withJSONObject: obj),
                  var payloadStr = String(data: payload, encoding: .utf8) else { continue }
            payloadStr = payloadStr.replacingOccurrences(of: "\u{2028}", with: "\\u2028")
                                   .replacingOccurrences(of: "\u{2029}", with: "\\u2029")
            let done = f.appendingPathExtension("done")
            DispatchQueue.main.async {
                wv.evaluateJavaScript("window.__spotterImport(\(payloadStr))") { result, error in
                    if error == nil, (result as? String) == "ok" { try? fm.moveItem(at: f, to: done) }
                }
            }
        }
    }

    // Start Session pide lanzar el Spotter (Claude Code vigilando la pantalla)
    func userContentController(_ u: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "spotter" { launchSpotter(profile: message.body as? String ?? "") }
    }
    func launchSpotter(profile: String) {
        guard let res = Bundle.main.resourceURL else { return }
        let fm = FileManager.default
        // Carpeta de trabajo del Spotter en Application Support.
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support/SpotterAI")
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        // 1) escribir el perfil que mandó la app (para que el Spotter te conozca)
        if !profile.isEmpty && profile != "start" {
            try? profile.write(to: dir.appendingPathComponent("profile.json"), atomically: true, encoding: .utf8)
        }
        // 2) copiar script + playbook (self-heal de cuarentena para que Gatekeeper no bloquee)
        for name in ["start-watch.command", "SPOTTER-PLAYBOOK.md"] {
            let src = res.appendingPathComponent(name)
            let dst = dir.appendingPathComponent(name)
            try? fm.removeItem(at: dst)
            try? fm.copyItem(at: src, to: dst)
        }
        let scriptPath = dir.appendingPathComponent("start-watch.command").path
        try? fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptPath)
        let strip = Process()
        strip.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        strip.arguments = ["-cr", dir.path]     // limpia cuarentena de toda la carpeta
        try? strip.run(); strip.waitUntilExit()
        // 3) abrir la copia limpia en Terminal → arranca Claude
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        p.arguments = [scriptPath]
        try? p.run()
    }

    // enlaces externos (http/https: Discord, WhatsApp, TradingView) → navegador del sistema
    func webView(_ w: WKWebView, decidePolicyFor a: WKNavigationAction,
                 decisionHandler d: @escaping (WKNavigationActionPolicy) -> Void) {
        if let u = a.request.url, let s = u.scheme?.lowercased(), s == "http" || s == "https" {
            NSWorkspace.shared.open(u); d(.cancel); return
        }
        d(.allow)
    }
    // target=_blank
    func webView(_ w: WKWebView, createWebViewWith cfg: WKWebViewConfiguration,
                 for a: WKNavigationAction, windowFeatures f: WKWindowFeatures) -> WKWebView? {
        if let u = a.request.url { NSWorkspace.shared.open(u) }
        return nil
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
let del = Delegate()
app.delegate = del

// menú mínimo para Cmd+Q / Cmd+W
let menu = NSMenu()
let appItem = NSMenuItem(); menu.addItem(appItem)
let appSub = NSMenu()
appSub.addItem(withTitle: "Ocultar SPOTTER AI", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
appSub.addItem(NSMenuItem.separator())
appSub.addItem(withTitle: "Salir de SPOTTER AI", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
appItem.submenu = appSub
let editItem = NSMenuItem(); menu.addItem(editItem)
let editSub = NSMenu(title: "Editar")
editSub.addItem(withTitle: "Copiar", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
editSub.addItem(withTitle: "Pegar", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
editSub.addItem(withTitle: "Seleccionar todo", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
editSub.addItem(withTitle: "Cerrar ventana", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
editItem.submenu = editSub
app.mainMenu = menu

app.run()
