# HAUMonsters

HAUMonsters is a Flutter app for adding, editing, deleting, and viewing monster spawn points on a map.

## What You Need

- Flutter installed
- XAMPP or any PHP + MySQL local server
- Android emulator, Android phone, Windows, or Chrome

## Setup

### 1. Install Flutter packages

In the project folder, run:

```bash
flutter pub get
```

### 2. Set up the backend

1. Copy the `backend` folder to your server so it becomes:

```text
C:\xampp\htdocs\haumonsters_api
```

2. Start `Apache` and `MySQL` in XAMPP.
3. Import `backend/haumonstersDB.sql` into phpMyAdmin.
4. If needed, update the database settings in:

```text
backend/config/database.php
```

Default database values are already:

```php
DB_HOST = 127.0.0.1
DB_PORT = 3306
DB_NAME = haumonstersDB
DB_USER = root
DB_PASS = ''
```

### 3. Check if the backend works

Open these in your browser:

```text
http://localhost/haumonsters_api/
http://localhost/haumonsters_api/get_monsters.php
```

If they return JSON, the backend is working.

### 4. Run the app with the correct API URL

The app needs a different URL depending on where it runs.

#### Windows

```bash
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1/haumonsters_api
```

#### Chrome

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/haumonsters_api
```

#### Android emulator

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2/haumonsters_api
```

#### Physical Android phone

Use your PC's local IP address:

```bash
flutter run -d YOUR_DEVICE_ID --dart-define=API_BASE_URL=http://YOUR_PC_IP/haumonsters_api
```

Example:

```text
http://192.168.1.5/haumonsters_api
```

Your phone and PC must be connected to the same Wi-Fi.

## Quick Troubleshooting

- Server not found: make sure Apache is running
- Database error: check `backend/config/database.php`
- Android phone cannot connect: use your PC IP, not `localhost`
- Android emulator cannot connect: use `10.0.2.2`, not `localhost`
- Image upload fails: make sure the backend `uploads` folder can be written to

## Summary

1. Run `flutter pub get`
2. Put `backend` in `htdocs/haumonsters_api`
3. Start Apache and MySQL
4. Import `haumonstersDB.sql`
5. Run Flutter with the correct `API_BASE_URL`
