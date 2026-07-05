abstract class NavigationService {
  void go(String path, {Object? extra});
  void push(String path, {Object? extra});
  void pop();
}
