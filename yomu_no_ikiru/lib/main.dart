import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yomu_no_ikiru/core/common/cubits/appuser/app_user_cubit.dart';
import 'package:yomu_no_ikiru/core/theme/default/default_theme.dart';
import 'package:yomu_no_ikiru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yomu_no_ikiru/features/auth/presentation/pages/login_page.dart';
import 'package:yomu_no_ikiru/features/debug/presentation/pages/dubug_page.dart';
import 'package:yomu_no_ikiru/init_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Render full size screen (bottom navigation bar and status bar transparent)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await dotenv.load(fileName: ".env");

  //initialize all dependencies for bloc structure and for date formatting
  await initDependencies();
  await initializeDateFormatting();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AppUserCubit>(),
        ),
        BlocProvider(
          create: (_) => serviceLocator<AuthBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      title: 'Yomu no Ikiru',
      darkTheme: DefaultTheme.darkTheme,
      theme: DefaultTheme.lightTheme,
      home: BlocSelector<AppUserCubit, AppUserState, bool>(
        selector: (state) {
          return state is AppUserLoggedIn;
        },
        builder: (context, isLoggedIn) {
          if (isLoggedIn) {
            // return const HomePage();
            return const DebugPage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
