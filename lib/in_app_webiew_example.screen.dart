import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class InAppWebViewExampleScreen extends StatefulWidget {
  @override
  _InAppWebViewExampleScreenState createState() =>
      _InAppWebViewExampleScreenState();
}

class _InAppWebViewExampleScreenState extends State<InAppWebViewExampleScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone",
      iframeAllowFullscreen: true,
      allowContentAccess: true,
      allowFileAccess: true,
  );

  PullToRefreshController? pullToRefreshController;

  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              id: 1,
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        settings: ContextMenuSettings(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = contextMenuItemClicked.id;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("InAppWebView")),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(children: <Widget>[
          TextField(
            decoration: InputDecoration(prefixIcon: Icon(Icons.search)),
            controller: urlController,
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
              var url = WebUri(value);
              if (url.scheme.isEmpty) {
                url = WebUri((!kIsWeb
                        ? "https://www.google.com/search?q="
                        : "https://www.bing.com/search?q=") +
                    value);
              }
              webViewController?.loadUrl(urlRequest: URLRequest(url: url));
            },
          ),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest:
                      URLRequest(url: WebUri('https://togumoguuat.doctime.com.bd'),headers:
                      {
                        "Authorization": "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI0IiwianRpIjoiZWU4ZWRhZjI2ZWIxN2NkMzE2M2VhZTVjYmQ2ZGE5ZjdlYTAyNGE5ZTRmZmE2ZmE4NDk5ZjcxMWNmNDUwMDNmYWZlZjZiNzE0MWQ1ZWFkZDIiLCJpYXQiOjE3MTk0NzI1MDguODM2MjIyLCJuYmYiOjE3MTk0NzI1MDguODM2MjI2LCJleHAiOjE3MTk1MTExOTkuMDEyMDA5LCJzdWIiOiI1MTc3MzIiLCJzY29wZXMiOlsiYWNjZXNzLXBhcnRuZXIiLCJwYXJ0bmVyLWlkLTMiXX0.BuCr-o_NsekImPzROwkCu_iegMmc6U3oTyC7L4edTfuvYAZAuOroj06zxk64dau6pjJhEvSbIWzM9rPn1SMt255Hwwv7TAgaIHSYS1blFTmpXpZPWPLN618NBOXQkE2Vwh-CvGMLhZQwxhjajHYJfAT9I3TtUzF4xM5vXGYBrsWBcxCUVpJqNfJEMEHOh7w8fnDm76nm6PNIvk2scysrOix_BxKxKtb9McLf1AzZKUhd4Qt_QjxvULGq9TwbfNMgfWlUAf2bczHdzAZlEHrN_GyiLw4qiTrk-dPPoZmVQn8nlnXHF5DEqTgDA-V4dcnR99mL1IocfOs0aH36MXEbwp_r5k8xQSbTafwZOIO3QuLAqD8NOZHqO_qU_p5lozsn6vMCXdT_2SXB9gPYWgRQtf2Km9hTn0LvnbjikgcAtPfxHt-5AOHdqU_fxnES2BOqFfzThjSzIiS0yqHmJkf9tXM4tFAvZCfCdikYfS2bCDVGXzsoY1UjfThsto2Nl_eNvjsdxqFXBsoN_ulYawztGCAtHAAxgh6GPu0iz80QG0iYROdRpje5GALWiMc7ROTQ_CH2yhHqtd0mPvUF1lNmSScu_zVHpWinZVwE1Z-KuDLsHGebTOTrv8qL_uP_pcEq-5SRcrNB4oRXtjU0Fenxr55TRI60irY3YbbaOSSPc8I",
                        "platform": "Android",
                        "version": "2.202"}

                      ),
                  // initialUrlRequest:
                  // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                  // initialFile: "assets/index.html",
                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                  initialSettings: settings,
                  contextMenu: contextMenu,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    controller.addJavaScriptHandler(handlerName: 'handlerFoo', callback: (args) {
                      // return data to the JavaScript side!
                      return {
                        'bar': 'bar_value', 'baz': 'baz_value'
                      };
                    });
                  },
                  onLoadStart: (controller, url) async {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = this.url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, isReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    print("consoleMessage $consoleMessage");
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Icon(Icons.arrow_back),
                onPressed: () {
                  webViewController?.goBack();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.arrow_forward),
                onPressed: () {
                  webViewController?.goForward();
                },
              ),
              ElevatedButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
            ],
          ),
        ])));
  }
}
