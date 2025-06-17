// lib/providers/feature_providers.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// Import necessary components from each feature's data, domain, and presentation layers
// ... (All imports for Auth, Home, Notification, Profile features)
import '../core/network/http_service.dart'; // Core dependency

List<SingleChildWidget> featureProviders = [
  // --- Auth Feature Providers ---
  Provider<AuthRemoteDataSource>(create: (context) => AuthRemoteDataSourceImpl(dio: context.read<HttpService>().getInstance())),
  Provider<AuthRepository>(create: (context) => AuthRepositoryImpl(remoteDataSource: context.read<AuthRemoteDataSource>())),
  Provider<SignInUseCase>(create: (context) => SignInUseCase(repository: context.read<AuthRepository>())),
  ChangeNotifierProvider<LoginViewModel>(create: (context) => LoginViewModel(signInUseCase: context.read<SignInUseCase>())),

  // --- Home Feature Providers ---
  Provider<HomeRemoteDataSource>(create: (context) => HomeRemoteDataSourceImpl(dio: context.read<HttpService>().getInstance())),
  Provider<HomeRepository>(create: (context) => HomeRepositoryImpl(remoteDataSource: context.read<HomeRemoteDataSource>())),
  Provider<GetDashboardDataUseCase>(create: (context) => GetDashboardDataUseCase(repository: context.read<HomeRepository>())),
  ChangeNotifierProvider<HomeViewModel>(create: (context) => HomeViewModel(getDashboardDataUseCase: context.read<GetDashboardDataUseCase>())),

  // --- Notification Feature Providers ---
  Provider<NotificationRemoteDataSource>(create: (context) => NotificationRemoteDataSourceImpl(dio: context.read<HttpService>().getInstance())),
  Provider<NotificationRepository>(create: (context) => NotificationRepositoryImpl(remoteDataSource: context.read<NotificationRemoteDataSource>())),
  Provider<GetNotificationsUseCase>(create: (context) => GetNotificationsUseCase(repository: context.read<NotificationRepository>())),
  Provider<MarkNotificationAsReadUseCase>(create: (context) => MarkNotificationAsReadUseCase(repository: context.read<NotificationRepository>())),
  ChangeNotifierProvider<NotificationViewModel>(
      create: (context) => NotificationViewModel(getNotificationsUseCase: context.read<GetNotificationsUseCase>(), markNotificationAsReadUseCase: context.read<MarkNotificationAsReadUseCase>())),

  // --- Profile Feature Providers ---
  Provider<UserProfileRemoteDataSource>(create: (context) => UserProfileRemoteDataSourceImpl(dio: context.read<HttpService>().getInstance())),
  Provider<UserProfileRepository>(create: (context) => UserProfileRepositoryImpl(remoteDataSource: context.read<UserProfileRemoteDataSource>())),
  Provider<GetUserProfileUseCase>(create: (context) => GetUserProfileUseCase(repository: context.read<UserProfileRepository>())),
  Provider<UpdateUserProfileUseCase>(create: (context) => UpdateUserProfileUseCase(repository: context.read<UserProfileRepository>())),
  ChangeNotifierProvider<UserProfileViewModel>(
      create: (context) => UserProfileViewModel(getUserProfileUseCase: context.read<GetUserProfileUseCase>(), updateUserProfileUseCase: context.read<UpdateUserProfileUseCase>())),
];
