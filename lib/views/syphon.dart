import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:sembast/sembast.dart';
import 'package:syphon/cache/index.dart';
import 'package:syphon/context/index.dart';
import 'package:syphon/global/formatters.dart';
import 'package:syphon/global/notifications.dart';

import 'package:syphon/global/themes.dart';
import 'package:syphon/global/values.dart';
import 'package:syphon/storage/index.dart';
import 'package:syphon/store/alerts/actions.dart';
import 'package:syphon/store/alerts/model.dart';
import 'package:syphon/store/auth/actions.dart';
import 'package:syphon/store/auth/context/actions.dart';
import 'package:syphon/store/events/messages/actions.dart';
import 'package:syphon/store/index.dart';
import 'package:syphon/store/settings/theme-settings/model.dart';
import 'package:syphon/store/sync/actions.dart';
import 'package:syphon/store/sync/background/storage.dart';
import 'package:syphon/store/user/model.dart';
import 'package:syphon/views/home/home-screen.dart';
import 'package:syphon/views/intro/intro-screen.dart';
import 'package:syphon/views/navigation.dart';

class Syphon extends StatefulWidget {
  final Database? cache;
  final Database? storage;
  final Store<AppState> store;

  const Syphon(
    this.store,
    this.cache,
    this.storage,
  );

  @override
  SyphonState createState() => SyphonState(
        store,
        cache,
        storage,
      );
}

class SyphonState extends State<Syphon> with WidgetsBindingObserver {
  Database? cache;
  Database? storage;
  Store<AppState> store;
  final globalScaffold = GlobalKey<ScaffoldMessengerState>();

  Widget defaultHome = HomeScreen();

  SyphonState(
    this.store,
    this.cache,
    this.storage,
  );

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    super.initState();

    store.dispatch(initDeepLinks());
    store.dispatch(initClientSecret());
    store.dispatch(startAuthObserver());
    store.dispatch(startAlertsObserver());
    store.dispatch(startContextObserver());

    // init current auth state with current user
    store.state.authStore.authObserver?.add(
      store.state.authStore.user,
    );

    // mutate messages
    store.dispatch(mutateMessagesAll());

    final currentUser = store.state.authStore.user;
    final authed = currentUser.accessToken != null;

    if (!authed) {
      defaultHome = IntroScreen();
    }
  }

  @override
  // ignore: avoid_void_async
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        setupTheme(store.state.settingsStore.themeSettings);

        dismissAllNotifications(
          pluginInstance: globalNotificationPluginInstance,
        );
        saveNotificationsUnchecked(const {});
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        store.dispatch(setBackgrounded(true));
        break;
      case AppLifecycleState.detached:
        store.dispatch(setBackgrounded(true));
        break;
    }
  }

  ///
  /// a.k.a. onMounted()
  ///
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // init auth listener
    store.state.authStore.onAuthStateChanged!.listen(onAuthStateChanged);

    // set auth state listener
    store.state.authStore.onContextChanged!.listen(onContextChanged);

    // init alerts listener
    store.state.alertsStore.onAlertsChanged.listen(onAlertsChanged);
  }

  onContextChanged(User? user) async {
    final contextCurrent = await loadCurrentContext();

    var contextNew = StoreContext.DEFAULT;

    // save new user context
    if (user != null) {
      contextNew = generateContextId(id: user.userId!);
      await saveContext(contextNew);
    } else {
      // Remove old context and check all remained
      await deleteContext(contextCurrent.current);
      final allContexts = await loadContexts();

      // set to another if one exists
      // otherwise, will be default
      if (allContexts.isNotEmpty) {
        contextNew = allContexts.first.current;
      }
    }

    final cacheContext = await initCache(context: contextNew);
    final storageContext = await initStorage(context: contextNew);
    final storeContext = await initStore(
      cache,
      storage,
      existingState: AppState(
        authStore: store.state.authStore,
      ),
    );

    setState(() {
      cache = cacheContext;
      storage = storageContext;
      store = storeContext;
    });

    // delete cache data if now authenticated (context is not default)
    if (user == null) {
      deleteCache(context: contextCurrent.current);
      deleteStorage(context: contextCurrent.current);
    }

    store.state.authStore.authObserver?.add(user);
  }

  onAuthStateChanged(User? user) async {
    if (user == null && defaultHome.runtimeType == HomeScreen) {
      defaultHome = IntroScreen();
      NavigationService.clearTo(NavigationPaths.intro, context);
    } else if (user != null && user.accessToken != null && defaultHome.runtimeType == IntroScreen) {
      defaultHome = HomeScreen();
      NavigationService.clearTo(NavigationPaths.home, context);
    }
  }

  onAlertsChanged(Alert alert) {
    Color? color;

    switch (alert.type) {
      case 'error':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.red;
        break;
      case 'success':
        color = Colors.green;
        break;
      case 'info':
      default:
        color = Colors.grey;
    }

    final alertMessage = alert.message ?? alert.error ?? 'Unknown Error Occurred';

    globalScaffold.currentState?.showSnackBar(SnackBar(
      backgroundColor: color,
      content: Text(
        alertMessage,
        style: Theme.of(context).textTheme.subtitle1?.copyWith(color: Colors.white),
      ),
      duration: alert.duration,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          globalScaffold.currentState?.removeCurrentSnackBar();
        },
      ),
    ));
  }

  @override
  void dispose() {
    store.dispatch(stopContextObserver());
    store.dispatch(stopAuthObserver());
    store.dispatch(stopAlertsObserver());
    store.dispatch(disposeDeepLinks());
    closeCache(cache);
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // Store should not need to be passed to a widget to affect
  // lifecycle widget functions
  @override
  Widget build(BuildContext context) => StoreProvider<AppState>(
        key: Key(store.hashCode.toString()),
        store: store,
        child: localization.EasyLocalization(
          path: 'assets/translations',
          useOnlyLangCode: true,
          startLocale: Locale(formatLanguageCode(store.state.settingsStore.language)),
          fallbackLocale: Locale(LangCodes.en),
          supportedLocales: const [
            Locale(LangCodes.en),
            Locale(LangCodes.ru),
            Locale(LangCodes.pl),
          ],
          child: StoreConnector<AppState, ThemeSettings>(
            distinct: true,
            converter: (store) => store.state.settingsStore.themeSettings,
            builder: (context, themeSettings) => MaterialApp(
              scaffoldMessengerKey: globalScaffold,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: setupTheme(themeSettings, generateThemeData: true),
              navigatorKey: NavigationService.navigatorKey,
              routes: NavigationProvider.getRoutes(),
              home: defaultHome,
            ),
          ),
        ),
      );
}