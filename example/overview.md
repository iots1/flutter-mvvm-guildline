💻 สรุปโค้ด (Key File Examples)
ผมจะสรุปโค้ดตัวอย่างสำหรับไฟล์สำคัญๆ บางส่วน เพื่อให้เห็นการเชื่อมโยงของแต่ละ Layer และ Feature ครับ


1. lib/main.dart (Entry Point & DI Setup)
นี่คือไฟล์ที่เริ่มต้นแอปและตั้งค่า MultiProvider โดยรวม Provider จากทุก Layer/Feature:
``` dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/http_service.dart';
import 'providers/app_providers.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/profile/presentation/screens/user_profile_screen.dart';
import 'features/notification/presentation/screens/notification_screen.dart';
import 'core/theme/app_theme.dart'; // Import your custom theme

void main() {
  HttpService.setEnvironment(Environment.Development); // Set desired environment
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders, // All providers from core and features
      child: MaterialApp(
        title: 'Flutter MVVM App',
        theme: AppTheme.lightTheme,
        home: const LoginScreen(), // Starting screen
        routes: {
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const UserProfileScreen(),
          '/notifications': (context) => const NotificationScreen(),
          // Define other routes here
        },
      ),
    );
  }
}
```

2. lib/providers/app_providers.dart (Aggregating Providers)
ไฟล์นี้จะรวม Provider จาก core และ features ทั้งหมด:
``` dart
// lib/providers/app_providers.dart
import 'package:provider/single_child_widget.dart';
import 'core_providers.dart';
import 'feature_providers.dart';

List<SingleChildWidget> appProviders = [
  ...coreProviders,
  ...featureProviders,
];
```

3. lib/providers/feature_providers.dart (Feature-specific Providers)
ไฟล์นี้จะรวบรวม Providers ของแต่ละฟีเจอร์ย่อย (Data, Domain, Presentation):
``` dart
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
  ChangeNotifierProvider<NotificationViewModel>(create: (context) => NotificationViewModel(getNotificationsUseCase: context.read<GetNotificationsUseCase>(), markNotificationAsReadUseCase: context.read<MarkNotificationAsReadUseCase>())),

  // --- Profile Feature Providers ---
  Provider<UserProfileRemoteDataSource>(create: (context) => UserProfileRemoteDataSourceImpl(dio: context.read<HttpService>().getInstance())),
  Provider<UserProfileRepository>(create: (context) => UserProfileRepositoryImpl(remoteDataSource: context.read<UserProfileRemoteDataSource>())),
  Provider<GetUserProfileUseCase>(create: (context) => GetUserProfileUseCase(repository: context.read<UserProfileRepository>())),
  Provider<UpdateUserProfileUseCase>(create: (context) => UpdateUserProfileUseCase(repository: context.read<UserProfileRepository>())),
  ChangeNotifierProvider<UserProfileViewModel>(create: (context) => UserProfileViewModel(getUserProfileUseCase: context.read<GetUserProfileUseCase>(), updateUserProfileUseCase: context.read<UpdateUserProfileUseCase>())),
];
```

4. lib/core/network/http_service.dart (Core Component)
ตัวอย่าง HttpService ที่ใช้ Dio และ Interceptors สำหรับ HTTP Requests:
``` dart
// lib/core/network/http_service.dart
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../error/exceptions.dart';
import '../utils/app_local_storage.dart';
import '../utils/app_preferences_keys.dart';

enum ApiType { MainAPI, SocketAPI, UploadAPI } // Defined in api_constants.dart in full project
enum Environment { Production, Development, Local } // Defined in api_constants.dart in full project

class HttpService {
  static final Map<ApiType, Dio> _dioInstances = {};
  static Environment defaultEnvironment = Environment.Development;

  static Dio getInstance({ApiType apiType = ApiType.MainAPI, Environment? environment}) {
    Environment env = environment ?? defaultEnvironment;
    String baseUrl = ApiConstants.baseUrls[env]?[apiType] ?? ApiConstants.baseUrls[env]![apiType]!;

    if (!_dioInstances.containsKey(apiType)) {
      _dioInstances[apiType] = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      _dioInstances[apiType]!.interceptors.add(InterceptorsWrapper(
            onRequest: (options, handler) async {
              final credential = await AppLocalStorage.getLocalStorage(key: AppPreferencesKeys.credential);
              if (credential != null && credential['access_token'] != null && credential['access_token'] != "") {
                options.headers['Authorization'] = 'Bearer ${credential['access_token']}';
              }
              options.headers['Content-Type'] = 'application/json';
              return handler.next(options);
            },
            onError: (DioException e, handler) async {
              // Refresh Token Logic (simplified)
              if (e.response?.statusCode == 401 && e.requestOptions.path != '/auth/refresh-token') {
                final String? refreshToken = (await AppLocalStorage.getLocalStorage(key: AppPreferencesKeys.credential))?['refresh_token'];
                if (refreshToken != null && refreshToken.isNotEmpty) {
                  // Simulate refresh token call
                  try {
                    // For a real app, call your actual AuthService().refreshToken(refreshToken)
                    final newAccessToken = 'new_access_token';
                    await AppLocalStorage.setLocalStorage(key: AppPreferencesKeys.credential, object: {"access_token": newAccessToken, "refresh_token": refreshToken});
                    e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final newResponse = await _dioInstances[apiType]!.fetch(e.requestOptions);
                    return handler.resolve(newResponse);
                  } on DioException catch (refreshError) {
                    // Handle refresh failure / logout
                    return handler.reject(refreshError);
                  }
                }
              }
              // Convert DioException to custom exceptions
              if (e.type == DioExceptionType.badResponse) {
                return handler.reject(ServerException(statusCode: e.response?.statusCode, message: e.response?.data is Map ? e.response?.data['message'] : e.message));
              } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
                return handler.reject(NetworkException(message: e.message ?? 'No internet connection.'));
              } else {
                return handler.reject(e);
              }
            },
          ));
    }
    return _dioInstances[apiType]!;
  }
  static void setEnvironment(Environment environment) {
    defaultEnvironment = environment;
    _dioInstances.clear();
  }
}
```





5. features/profile/domain/entities/user_profile_entity.dart (Domain Layer - Entity)
ตัวอย่าง Entity สำหรับฟีเจอร์ Profile (สร้างด้วย freezed):
``` dart
// features/profile/domain/entities/user_profile_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

@freezed
abstract class UserProfileEntity with _$UserProfileEntity {
  const factory UserProfileEntity({
    required String id,
    required String name,
    required String email,
    @Default('') String avatarUrl,
  }) = _UserProfileEntity;
}
```

6. features/profile/data/models/user_profile_model.dart (Data Layer - Model)
ตัวอย่าง Model สำหรับฟีเจอร์ Profile (สร้างด้วย freezed และ json_annotation):
``` dart
// features/profile/data/models/user_profile_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_profile_entity.dart'; // Implements Entity

part 'user_profile_model.freezed.dart';
part 'user_profile_model.g.dart';

@freezed
abstract class UserProfileModel with _$UserProfileModel implements UserProfileEntity {
  const factory UserProfileModel({
    required String id,
    required String name,
    required String email,
    @JsonKey(name: 'profile_picture_url') @Default('') String avatarUrl,
  }) = _UserProfileModel;

  factory UserProfileModel.fromJson(Map<String, dynamic> json) => _$UserProfileModelFromJson(json);
}
```

7. features/profile/domain/usecases/get_user_profile_usecase.dart (Domain Layer - Use Case)
ตัวอย่าง Use Case สำหรับดึงข้อมูล Profile:
``` dart
// features/profile/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_profile_entity.dart';
// import '../repositories/user_profile_repository.dart'; // Uncomment in real app

class GetUserProfileUseCase {
  // final UserProfileRepository repository;
  // GetUserProfileUseCase({required this.repository});

  Future<Either<Failure, UserProfileEntity>> call(String userId) async {
    // Example: Call repository, get actual data
    await Future.delayed(const Duration(seconds: 1));
    if (userId == 'test_user_id') {
      return Right(UserProfileEntity(id: userId, name: 'Sample User', email: 'user@example.com', avatarUrl: 'https://i.pravatar.cc/150'));
    } else {
      return const Left(GeneralFailure(message: 'User not found'));
    }
  }
}
```

8. features/profile/presentation/view_models/user_profile_view_model.dart (Presentation Layer - ViewModel)
ตัวอย่าง ViewModel สำหรับ Profile Screen:
``` dart
// features/profile/presentation/view_models/user_profile_view_model.dart
import 'package:flutter/material.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
// import '../../domain/usecases/update_user_profile_usecase.dart'; // Uncomment in real app

class UserProfileViewModel extends ChangeNotifier {
  final GetUserProfileUseCase getUserProfileUseCase;
  // final UpdateUserProfileUseCase updateUserProfileUseCase; // Uncomment in real app

  UserProfileViewModel({required this.getUserProfileUseCase /*, required this.updateUserProfileUseCase*/});

  UserProfileEntity? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfileEntity? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getUserProfileUseCase.call(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (profile) {
        _userProfile = profile;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // Example for update logic (needs UpdateUserProfileUseCase uncommented)
  // Future<void> updateProfile(UserProfileEntity updatedProfile) async {
  //   // ... logic to call updateUserProfileUseCase
  //   notifyListeners();
  // }
}
```

9. features/profile/presentation/screens/user_profile_screen.dart (Presentation Layer - Screen)
ตัวอย่าง Screen สำหรับแสดงโปรไฟล์:
``` dart
// features/profile/presentation/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../view_models/user_profile_view_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProfileViewModel>(context, listen: false).fetchUserProfile('test_user_id'); // Example user ID
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfileViewModel viewModel) {
    if (viewModel.userProfile != null) {
      _nameController.text = viewModel.userProfile!.name;
      _emailController.text = viewModel.userProfile!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          _populateFields(viewModel);

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.red)));
          } else if (viewModel.userProfile != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 60, backgroundImage: NetworkImage(viewModel.userProfile!.avatarUrl.isNotEmpty ? viewModel.userProfile!.avatarUrl : 'https://via.placeholder.com/150')),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  AppTextFormField(controller: _nameController, labelText: 'Name'),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  AppTextFormField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  AppButton(text: 'Update Profile', onPressed: () {
                    // Call viewModel.updateProfile here
                  }),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No profile data to display.'));
          }
        },
      ),
    );
  }
}
```
