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

    // Start Session pide lanzar el Spotter (Claude Code vigilando la pantalla)
    func userContentController(_ u: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "spotter" { launchSpotter() }
    }
    func launchSpotter() {
        guard let res = Bundle.main.resourceURL else { return }
        let src = res.appendingPathComponent("start-watch.command")
        let fm = FileManager.default
        // Copiamos el script a Application Support y le quitamos la cuarentena que heredó de la
        // descarga; así Gatekeeper NO lo bloquea al abrirlo (self-heal).
        let dir = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support/SpotterAI")
        let dst = dir.appendingPathComponent("start-watch.command")
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        try? fm.removeItem(at: dst)
        do { try fm.copyItem(at: src, to: dst) } catch { return }
        try? fm.setAttributes([.posixPermissions: 0o755], ofItemAtPath: dst.path)
        let strip = Process()
        strip.executableURL = URL(fileURLWithPath: "/usr/bin/xattr")
        strip.arguments = ["-cr", dst.path]     // quita com.apple.quarantine y demás
        try? strip.run(); strip.waitUntilExit()
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        p.arguments = [dst.path]                 // abre la copia limpia en Terminal → arranca Claude
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
