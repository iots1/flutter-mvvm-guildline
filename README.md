
# 🚀 Flutter MVVM Guideline (Feature-First Structure)

🌳 แนวคิดและคำอธิบายโครงสร้างโปรเจกต์ Flutter MVVM (Feature-First) โครงสร้างนี้ถูกออกแบบมาเพื่อจัดการความซับซ้อนของแอปพลิเคชันขนาดใหญ่ โดยมีหลักการสำคัญคือ "แยกตามฟีเจอร์, จัดระเบียบตาม Layer" (Feature-first, Layer-within). แต่ละส่วนจะถูกออกแบบมาให้มีหน้าที่เฉพาะเจาะจงและเป็นอิสระจากกันมากที่สุด

---

## 🧱 สรุปแนวคิดหลัก

- 🔍 **Feature-First**: แยกโค้ดตามฟีเจอร์ เช่น `auth`, `home`, `notification`
- 🧬 **Layer-within**: แต่ละฟีเจอร์แยกย่อยเป็น 3 เลเยอร์ (`data`, `domain`, `presentation`)
- 🧼 **Separation of Concern**: Core ใช้ร่วมกัน / Features แยกการทำงาน
- 🧪 **Testability**: แต่ละเลเยอร์ชัดเจน จึงเขียนเทสต์ง่าย
- 🔌 **Dependency Injection**: ใช้ `Provider` เพื่อจัดการ Dependencies

---

## 🗂️ โครงสร้างโปรเจกต์

```
lib/
├── main.dart
├── core/
├── features/
└── providers/
```

---

## 📌 main.dart

- จุดเริ่มต้นของแอป
- ตั้งค่า `Environment` เช่น Dev / Prod
- ใช้ `MultiProvider` เพื่อลงทะเบียน Dependencies

```dart
void main() {
  runApp(
    MultiProvider(
      providers: appProviders,
      child: MyApp(),
    ),
  );
}
```

---

## 🧩 core/ - Global Utilities

> สิ่งที่ทุก Feature ใช้ร่วมกัน

| โฟลเดอร์ | รายละเอียด |
|----------|-------------|
| `constants/` | ค่าคงที่ เช่น `api_constants.dart` |
| `error/` | การจัดการข้อผิดพลาด เช่น `exceptions.dart`, `failures.dart` |
| `network/` | จัดการ Dio, Interceptor, BaseOptions |
| `theme/` | สี, ขนาด, ฟอนต์ ของแอป |
| `utils/` | ฟังก์ชันทั่วไป เช่น LocalStorage, Preferences |
| `widgets/` | UI Components ที่ใช้ซ้ำได้ เช่น `AppButton`, `AppTextFormField` |

---

## 🚧 features/ - แต่ละฟีเจอร์ในแอป

แต่ละฟีเจอร์ประกอบด้วย:

```
features/
└── feature_name/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── screens/
        ├── view_models/
        └── widgets/
```

ตัวอย่าง `auth`:

```
features/
└── auth/
    ├── data/
    │   ├── datasources/remote/auth_remote_data_source.dart
    │   └── models/user_credential_model.dart
    ├── domain/
    │   ├── entities/user_credential_entity.dart
    │   ├── repositories/auth_repository.dart
    │   └── usecases/sign_in_usecase.dart
    └── presentation/
        ├── screens/login_screen.dart
        ├── view_models/login_view_model.dart
        └── widgets/
```

---

## 🧪 providers/ - Dependency Injection

จัดการการ Inject Dependencies ผ่าน `Provider` แบบรวมศูนย์

| ไฟล์ | หน้าที่ |
|------|---------|
| `core_providers.dart` | Provider สำหรับ Global Services เช่น `HttpService` |
| `feature_providers.dart` | รวม ViewModel, Repository, UseCase ของแต่ละฟีเจอร์ |
| `app_providers.dart` | รวมทั้งหมดเพื่อใช้ใน `main.dart` |

---

## 📘 ตัวอย่างโครงสร้างเต็ม

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
