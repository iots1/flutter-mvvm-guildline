# flutter-mvvm-guildline
ยอดเยี่ยมครับ! การเข้าใจถึงแนวคิดเบื้องหลังแต่ละโฟลเดอร์เป็นสิ่งสำคัญที่สุดในการบำรุงรักษาและขยายโปรเจกต์ในระยะยาว ผมจะอธิบายแนวคิดและบทบาทของแต่ละโฟลเดอร์ในโครงสร้าง Flutter MVVM แบบ Feature-First ให้คุณอย่างละเอียดครับ

🌳 แนวคิดและคำอธิบายโครงสร้างโปรเจกต์ Flutter MVVM (Feature-First)
โครงสร้างนี้ถูกออกแบบมาเพื่อจัดการความซับซ้อนของแอปพลิเคชันขนาดใหญ่ โดยมีหลักการสำคัญคือ "แยกตามฟีเจอร์, จัดระเบียบตาม Layer" (Feature-first, Layer-within). แต่ละส่วนจะถูกออกแบบมาให้มีหน้าที่เฉพาะเจาะจงและเป็นอิสระจากกันมากที่สุด

🧱 สรุปแนวคิด
	•	🔍 Feature-First: แยกโค้ดตามฟีเจอร์ เช่น auth, home, notification
	•	🧬 Layer-within: แต่ละฟีเจอร์มี 3 เลเยอร์ย่อย (Data, Domain, Presentation)
	•	🧼 แยกสัดส่วนชัดเจน: Core ใช้ร่วมกัน, Features ทำงานแยกกัน
	•	🧪 Testable: แต่ละเลเยอร์มีหน้าที่เฉพาะ ทำให้เขียนเทสต์ได้ง่าย
	•	🔌 Dependency Injection ด้วย Provider

``` 
lib/
├── main.dart
├── core/
├── features/
└── providers/
```

🚀 main.dart
	•	จุดเริ่มต้นของแอป (void main())
	•	ตั้งค่า Environment เช่น Dev / Prod
	•	ใช้ MultiProvider เพื่อ Inject Dependencies ทั้งหมด

``` dart
void main() {
  runApp(
    MultiProvider(
      providers: appProviders,
      child: MyApp(),
    ),
  );
}
```

🧩 core/ - ใช้ร่วมกันทั่วแอป
constants เก็บค่าคงที่ เช่น api_constants.dart
error จัดการข้อผิดพลาด exceptions.dart, failures.dart
network จัดการ Dio, Interceptors, BaseOptions
theme จัดการ Theme, สี, ขนาด UI
utils Local Storage, Helpers
widgets Global Reusable Widgets เช่น AppButton, AppTextFormField

🧱 features/ - แยกตามฟีเจอร์
แต่ละฟีเจอร์แยกกันอย่างอิสระ เช่น
```
features/
├── auth/
├── home/
├── notification/
└── profile/
```

ภายในแต่ละฟีเจอร์จะมีโครงสร้างย่อยดังนี้:
📦 data/
	•	datasources/remote/: เรียก API เฉพาะฟีเจอร์นั้น
	•	models/: Map ข้อมูลจาก JSON (ใช้ freezed)
	•	repositories/: ทำหน้าที่เป็น Bridge เชื่อม Data ↔ Domain
🧠 domain/
	•	entities/: โครงสร้างข้อมูลหลัก (immutable)
	•	repositories/: Interface ที่ Data ต้อง Implement
	•	usecases/: ตรรกะทางธุรกิจ เช่น signInUsecase, getProfileUsecase
🎨 presentation/
	•	screens/: หน้าจอหลักของฟีเจอร์
	•	view_models/: จัดการ UI State, เรียก UseCase
	•	widgets/: Reusable UI สำหรับฟีเจอร์นั้นโดยเฉพาะ

ตัวอย่าง Features/auth
```
auth/
├── data/
│   ├── datasources/remote/auth_remote_data_source.dart
│   └── models/user_credential_model.dart
├── domain/
│   ├── entities/user_credential_entity.dart
│   ├── repositories/auth_repository.dart
│   └── usecases/sign_in_usecase.dart
├── presentation/
│   ├── screens/login_screen.dart
│   ├── view_models/login_view_model.dart
│   └── widgets/
```

 
📌 providers/
ใช้ Provider เป็นเครื่องมือ Inject Dependencies ให้ทุกฟีเจอร์
ไฟล์                    | หน้าที่
core_providers.dart    | Provider สำหรับ Global Services เช่น HttpService
feature_providers.dart | Provider สำหรับทุกฟีเจอร์ (ViewModel, Repository, UseCase)
app_providers.dart     | รวมทุก Provider เข้าด้วยกันเพื่อใช้ใน main.dart


```
lib/
├── main.dart                      # จุดเริ่มต้นของแอป, ตั้งค่า Dependency Injection (MultiProvider)
│
├── core/                          # ส่วนกลางที่ใช้ร่วมกันทุก Feature (Global, Cross-cutting Concerns)
│   ├── constants/                 # ค่าคงที่ทั่วแอป (API Endpoints, etc.)
│   │   └── api_constants.dart
│   ├── error/                     # การจัดการข้อผิดพลาด (Custom Exceptions, Failures)
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/                   # การจัดการเครือข่าย (Dio client, Interceptors)
│   │   └── http_service.dart
│   ├── theme/                     # การกำหนด Theme และ UI Guidelines
│   │   ├── app_colors.dart
│   │   ├── app_dimensions.dart
│   │   └── app_theme.dart
│   ├── utils/                     # Utility functions, Local Storage
│   │   └── app_local_storage.dart
│   │   └── app_preferences_keys.dart
│   └── widgets/                   # UI Components ที่ใช้ซ้ำได้ทั่วแอป (Global Reusable Widgets)
│       ├── app_button.dart
│       └── app_text_form_field.dart
│
├── features/                      # แต่ละโฟลเดอร์คือ 1 Feature ที่ทำงานแยกกันอย่างอิสระ
│   ├── auth/                      # ฟีเจอร์: การยืนยันตัวตน (Login, Register)
│   │   ├── data/                  # Data Layer สำหรับ Auth Feature
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       └── auth_remote_data_source.dart
│   │   │   └── models/
│   │   │       └── user_credential_model.dart
│   │   └── domain/                # Domain Layer สำหรับ Auth Feature
│   │   │   ├── entities/
│   │   │   │   └── user_credential_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       └── sign_up_usecase.dart
│   │   └── presentation/          # Presentation Layer สำหรับ Auth Feature
│   │       ├── screens/
│   │       │   └── login_screen.dart
│   │       ├── view_models/
│   │       │   └── login_view_model.dart
│   │       └── widgets/
│   │
│   ├── home/                      # ฟีเจอร์: หน้าหลัก
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── home_screen.dart
│   │       └── view_models/
│   │           └── home_view_model.dart
│   │
│   ├── notification/              # ฟีเจอร์: การแจ้งเตือน
│   │   ├── data/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── notification_entity.dart
│   │   │   └── usecases/
│   │   │       ├── get_notifications_usecase.dart
│   │   │       └── mark_notification_as_read_usecase.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── notification_screen.dart
│   │       └── view_models/
│   │           └── notification_view_model.dart
│   │
│   └── profile/                   # ฟีเจอร์: โปรไฟล์ผู้ใช้
│       ├── data/
│       │   ├── datasources/
│       │   │   └── remote/
│       │   │       └── user_profile_remote_data_source.dart
│       │   └── models/
│       │       └── user_profile_model.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user_profile_entity.dart
│       │   ├── repositories/
│       │   │   └── user_profile_repository.dart
│       │   └── usecases/
│       │       ├── get_user_profile_usecase.dart
│       │       └── update_user_profile_usecase.dart
│       └── presentation/
│           ├── screens/
│           │   └── user_profile_screen.dart
│           ├── view_models/
│           │   └── user_profile_view_model.dart
│           └── widgets/
│
└── providers/                     # การจัดการ Dependency Injection (รวม Providers จากทุก Feature)
    ├── app_providers.dart         # รวม providers ทั้งหมดเข้าด้วยกัน
    ├── core_providers.dart        # Providers ของ Core Layer
    └── feature_providers.dart     # Providers ของทุก Feature
```
