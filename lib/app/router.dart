enum AppRoute { chat, settings }

class AppRouterState {
  const AppRouterState({this.route = AppRoute.chat});

  final AppRoute route;

  AppRouterState copyWith({AppRoute? route}) => AppRouterState(route: route ?? this.route);
}
