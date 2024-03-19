import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';

class WebAuthenticationSessionExampleScreen extends StatefulWidget {
  @override
  _WebAuthenticationSessionExampleScreenState createState() =>
      _WebAuthenticationSessionExampleScreenState();
}

class _WebAuthenticationSessionExampleScreenState
    extends State<WebAuthenticationSessionExampleScreen> {
  WebAuthenticationSession? session;
  String? token;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "WebAuthenticationSession",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
          child: Column(children: <Widget>[
            Center(
                child: Container(
              padding: EdgeInsets.all(20.0),
              child: Text("Token: $token"),
            )),
            session != null
                ? Container()
                : Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (session == null &&
                              !kIsWeb &&
                              [TargetPlatform.iOS, TargetPlatform.macOS]
                                  .contains(defaultTargetPlatform) &&
                              await WebAuthenticationSession.isAvailable()) {
                            session = await WebAuthenticationSession.create(
                                url: WebUri(
                                    "http://localhost:8080/web-auth.html"),
                                callbackURLScheme: "test",
                                onComplete: (url, error) async {
                                  if (url != null) {
                                    setState(() {
                                      token = url.queryParameters["token"];
                                    });
                                  }
                                });
                            setState(() {});
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Cannot create Web Authentication Session!'),
                            ));
                          }
                        },
                        child: Text("Create Web Auth Session")),
                  ),
            session == null
                ? Container()
                : Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          var started = false;
                          if (await session?.canStart() ?? false) {
                            started = await session?.start() ?? false;
                          }
                          if (!started) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Cannot start Web Authentication Session!'),
                            ));
                          }
                        },
                        child: Text("Start Web Auth Session")),
                  ),
            session == null
                ? Container()
                : Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          await session?.dispose();
                          setState(() {
                            token = null;
                            session = null;
                          });
                        },
                        child: Text("Dispose Web Auth Session")),
                  )
          ]),
        ));
  }
}
