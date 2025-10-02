
import 'package:flutter/material.dart';
import 'package:flutter_wayforpay_package/model/pares_model.dart';
import 'package:flutter_wayforpay_package/model/wayforpay_response.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VerificationScreen extends StatefulWidget {
  final WayForPayResponse? wayForPayResponse;

  const VerificationScreen({Key? key, this.wayForPayResponse})
      : super(key: key);

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const String POST_BACK_URL =
      'https://demo.cloudpayments.ru/WebFormPost/GetWebViewData';

  late final WebViewController _controller;
  late String _htmlData;

  String buildHtml() {
    return '''
      <html>
      <body>
        <form name='downloadForm' action='${widget.wayForPayResponse!.d3AcsUrl}' method='POST'>
          <input type='hidden' name='PaReq' value='${widget.wayForPayResponse!.d3Pareq}'>
          <input type='hidden' name='MD' value='${widget.wayForPayResponse!.d3Pareq}'>
          <input type='hidden' name='TermUrl' value='$POST_BACK_URL'>
        </form>
        <script>
          window.onload = function() { document.downloadForm.submit(); }
        </script>
      </body>
      </html>
    ''';
  }

  @override
  void initState() {
    super.initState();

    _htmlData = buildHtml();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) async {
            if (url.toLowerCase().contains(POST_BACK_URL.toLowerCase())) {
              // Evaluate JS to get page content
              final content = await _controller.runJavaScriptReturningResult(
                  'document.getElementsByTagName("body")[0].innerHTML;');

              String response = content.toString();
              // Clean up the string
              response = response.replaceAll(r'\n', '');
              response = response.replaceAll(' ', '');
              response = response.replaceAll('\\', '');

              if (response.length > 2) {
                response = response.substring(1, response.length - 1);
              }

              final paResModel = paResModelFromJson(response);
              if (mounted) {
                Navigator.of(context).pop(paResModel);
              }
            }
          },
        ),
      )
      ..loadHtmlString(_htmlData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
