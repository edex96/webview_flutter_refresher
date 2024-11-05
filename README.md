You want your official *webview_flutter* plugin to have pull to refresh feature?

Worry not use the code in web.dart :D

```dart
@override
Widget build(BuildContext context) {
  return WebviewRefresher(controller: webViewController);
}
```
