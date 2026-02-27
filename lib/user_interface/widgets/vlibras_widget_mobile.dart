import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VLibrasWidget extends StatefulWidget {
  const VLibrasWidget({super.key});

  static WebViewController? _controller;
  static bool _isWidgetReady = false;
  static String? _pendingText;

  /// Chame de qualquer lugar do app
  static Future<void> buscarTraducao(String texto) async {
    final t = texto.trim();
    if (t.isEmpty) return;

    _pendingText = texto;

    if (_controller == null || !_isWidgetReady) {
      debugPrint("VLibras Mobile: ainda não está pronto. Texto ficará pendente.");
      return;
    }

    await _sendTextToWeb(texto);
  }

  static Future<void> _sendTextToWeb(String texto) async {
    final c = _controller;
    if (c == null) return;

    final safe = jsonEncode(texto);

    await c.runJavaScript("""
      try {
        if (window.queueTranslate) {
          window.queueTranslate($safe);
        } else {
          window.setTutorialText && window.setTutorialText($safe);
          window.translateTutorialText && window.translateTutorialText();
        }
      } catch (e) {
        console.log("VLibras translate error:", e);
      }
    """);
  }

  @override
  State<VLibrasWidget> createState() => _VLibrasWidgetState();
}

class _VLibrasWidgetState extends State<VLibrasWidget> {
  bool _isLoading = true;
  late final WebViewController _controller;
  int _reloadAttempts = 0;

  // Ajuste como quiser:
  static const double _buttonScale = 2.0;

  @override
  void initState() {
    super.initState();

    // Reuso do controller (evita reiniciar o VLibras toda hora)
    if (VLibrasWidget._controller != null) {
      _controller = VLibrasWidget._controller!;
      _isLoading = false;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final pending = VLibrasWidget._pendingText;
        if (VLibrasWidget._isWidgetReady &&
            pending != null &&
            pending.trim().isNotEmpty) {
          await VLibrasWidget.buscarTraducao(pending);
        }
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (!mounted) return;
            setState(() => _isLoading = false);

            final ok = await _waitUntilReady();
            if (!ok) {
              debugPrint("VLibras Mobile: não ficou pronto a tempo.");
              return;
            }

            VLibrasWidget._isWidgetReady = true;

            final pending = VLibrasWidget._pendingText;
            if (pending != null && pending.trim().isNotEmpty) {
              // envio inicial + retentativa curta
              await VLibrasWidget._sendTextToWeb(pending);
              await Future<void>.delayed(const Duration(milliseconds: 80));
              await VLibrasWidget._sendTextToWeb(pending);
            }
          },
          onWebResourceError: (error) async {
            debugPrint("VLibras Mobile: WebResourceError: ${error.description}");
            if (_reloadAttempts < 2) {
              _reloadAttempts++;
              await Future.delayed(const Duration(milliseconds: 700));
              await _controller.reload();
            }
          },
        ),
      );

    _controller.loadHtmlString(
      _vlibrasHtml(_buttonScale),
      baseUrl: 'https://vlibras.gov.br/app/',
    );

    VLibrasWidget._controller = _controller;
    VLibrasWidget._isWidgetReady = false;
  }

  Future<bool> _waitUntilReady() async {
    // espera o botão e o objeto VLibras aparecerem
    for (int i = 0; i < 70; i++) {
      final result = await _controller.runJavaScriptReturningResult(r"""
        (function () {
          const hasBtn = !!document.querySelector('.vw-access-button') || !!document.querySelector('[vw-access-button]');
          const hasVlibras = (typeof window.VLibras !== 'undefined');
          return hasBtn && hasVlibras;
        })();
      """);
      if (result.toString().contains('true')) return true;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      width: screenWidth * 0.95,
      height: screenHeight * 0.95,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: 300,
          height: 500,
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
      ),
    );
  }
}

String _vlibrasHtml(double scale) => '''
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <style>
      html, body {
        background: transparent !important;
        margin: 0;
        padding: 0;
        overflow: hidden;
      }

      div[vw-access-button], .vw-access-button {
        transform: scale(${scale}) !important;
        transform-origin: bottom right !important;
        -webkit-transform: scale(${scale}) !important;
        -webkit-transform-origin: bottom right !important;
        margin-right: 15px !important;
        margin-bottom: 15px !important;
      }

      [vw] { overflow: visible !important; }

      /* Esconde onboarding/tooltips */
      .vpw-guide, .vw-guide, .popover, .popover-content, .vpw-onboarding,
      div[class*="popover"], div[class*="onboarding"] {
        display: none !important;
        visibility: hidden !important;
        opacity: 0 !important;
        pointer-events: none !important;
      }

      /* Área “texto escondido” que o VLibras seleciona */
      #vlibrasText {
        position: fixed;
        left: -10000px;
        top: 0;
        width: 10px;
        height: 10px;
        overflow: hidden;
        opacity: 0.01;
        user-select: text;
        white-space: pre-wrap;
      }
    </style>
  </head>

  <body>
    <div id="vlibrasText">...</div>

    <div vw class="enabled">
      <div vw-access-button class="active"></div>
      <div vw-plugin-wrapper><div class="vw-plugin-top-wrapper"></div></div>
    </div>

    <script src="https://vlibras.gov.br/app/vlibras-plugin.js"></script>

    <script>
      window.widgetInstance = new window.VLibras.Widget('https://vlibras.gov.br/app');

      // Estilo do botão (reforço por mutation observer)
      (function () {
        const SCALE = ${scale};
        function apply() {
          const btn = document.querySelector('[vw-access-button]') || document.querySelector('.vw-access-button');
          if (!btn) return false;
          btn.style.transform = 'scale(' + SCALE + ')';
          btn.style.transformOrigin = 'bottom right';
          btn.style.webkitTransform = 'scale(' + SCALE + ')';
          btn.style.webkitTransformOrigin = 'bottom right';
          btn.style.marginRight = '15px';
          btn.style.marginBottom = '15px';
          return true;
        }
        const t = setInterval(() => { if (apply()) clearInterval(t); }, 200);
        new MutationObserver(() => apply()).observe(document.documentElement, { childList: true, subtree: true, attributes: true });
      })();

      // API simples
      window.setTutorialText = function(text) {
        const el = document.getElementById('vlibrasText');
        if (!el) return;
        el.textContent = (text || "");
      };

      window.translateTutorialText = function() {
        const el = document.getElementById('vlibrasText');
        if (!el) return;

        // seleção
        try {
          const range = document.createRange();
          range.selectNodeContents(el);
          const sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);
          document.dispatchEvent(new Event('selectionchange'));
        } catch(e) { console.log("VLibras selection error:", e); }

        // eventos (ajuda o plugin a pegar)
        try {
          el.dispatchEvent(new MouseEvent('mousedown', { bubbles: true }));
          el.dispatchEvent(new MouseEvent('mouseup', { bubbles: true }));
          el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
        } catch(e) { console.log("VLibras event error:", e); }
      };

      // fila robusta (limpa timers e faz tentativas sem spammar infinito)
      (function () {
        window.__vl_timers = [];
        window.__vl_lastText = null;

        function clearTimers() {
          (window.__vl_timers || []).forEach(id => clearTimeout(id));
          window.__vl_timers = [];
        }

        function translateOnce() {
          try { window.translateTutorialText && window.translateTutorialText(); } catch (e) {}
        }

        window.queueTranslate = function(text) {
          if (!text) return;

          // se for igual, força uma vez
          if (window.__vl_lastText === text) {
            translateOnce();
            return;
          }

          window.__vl_lastText = text;
          clearTimers();

          try { window.setTutorialText && window.setTutorialText(text); } catch(e) {}

          // tentativas escalonadas (bem leves)
          const delays = [0, 80, 160, 320, 640, 1200];
          delays.forEach((d) => {
            const id = setTimeout(translateOnce, d);
            window.__vl_timers.push(id);
          });
        };
      })();

      // quando o usuário abre o VLibras, força traduzir o último texto
      (function () {
        function hookOpenClick() {
          const btn = document.querySelector('.vw-access-button') || document.querySelector('[vw-access-button]');
          if (!btn) return false;

          btn.addEventListener('click', () => {
            const attempts = [250, 700, 1400, 2200];
            attempts.forEach((ms) => {
              setTimeout(() => {
                try {
                  const text = window.__vl_lastText;
                  if (text && window.queueTranslate) window.queueTranslate(text);
                  else window.translateTutorialText && window.translateTutorialText();
                } catch (e) {}
              }, ms);
            });
          });
          return true;
        }

        const timer = setInterval(() => {
          if (hookOpenClick()) clearInterval(timer);
        }, 300);
      })();
    </script>
  </body>
</html>
''';
