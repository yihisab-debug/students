# Зачётка · Студент

Flutter-приложение студента. Вход через Firebase (Google). Студент видит
предметы своей группы (их создаёт преподаватель), отмечает задания
выполненными и видит выставленные оценки — всё в реальном времени через
Firestore.

## Процесс

1. Вход через Google → при первом входе профиль (имя, фамилия, группа),
   сохраняется в `students/{email}`.
2. Главный экран: предметы, у которых `group == моя группа`
   (создаёт преподаватель в своём приложении).
3. Открыть предмет → кнопка **«Сдать задание»**: студент вводит название
   задания, создаётся запись со статусом «на проверке».
4. Когда преподаватель поставит оценку — статус меняется на балл, итоговая
   оценка по предмету пересчитывается. Всё обновляется мгновенно (`snapshots()`).

## Настройка Firebase (Android, Flutter 3.16+)

1. Firebase Console: создать проект, включить **Authentication → Google**,
   создать **Firestore**.
2. `dart pub global activate flutterfire_cli` → `firebase login` →
   в папке проекта `flutterfire configure` (выберите ТОТ ЖЕ проект, что и для
   преподавателя). Команда перезапишет `lib/firebase_options.dart`.
3. В `lib/auth/auth_config.dart` укажите **Web client ID** в `serverClientId`.
4. Добавьте **SHA-1** в настройки Android-приложения в Firebase
   (`cd android && ./gradlew signingReport`). При необходимости поднимите
   `minSdkVersion` до 23.
5. Правила Firestore (прототип):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} { allow read, write: if request.auth != null; }
     }
   }
   ```
6. `flutter pub get && flutter run`.

## Схема Firestore

```
students/{email}:    { uid, email, name, group }
teachers/{email}:    { uid, email, name }
subjects/{id}:       { name, group, teacher, teacherEmail, semester }      (создаёт преподаватель)
submissions/{id}:    { subjectId, subjectName, group, studentEmail,
                       studentName, title, status('submitted'|'graded'),
                       score?, date, teacher }                              (создаёт студент, оценивает преподаватель)
```

## Чёрный экран при запуске?

Значит Firebase не настроен (в `firebase_options.dart` заглушки `REPLACE_ME`) —
приложение покажет об этом сообщение. Выполните `flutterfire configure`.
Реальную причину любой ошибки видно в `flutter run` (debug) или
`adb logcat | grep -i flutter`.
