# HAUMonsters PHP Backend

This folder contains a simple PHP/MySQL backend for the Flutter app.

## Files

- `config/database.php`: MySQL connection settings
- `config/bootstrap.php`: shared helpers and JSON response handling
- `get_monsters.php`
- `add_monster.php`
- `update_monster.php`
- `delete_monster.php`
- `upload_monster_image.php`
- `haumonstersDB.sql`: database and table setup

## XAMPP Deployment

1. Copy this `backend` folder to `C:\xampp\htdocs\haumonsters_api`
2. Start `Apache` and `MySQL` in XAMPP
3. Import `haumonstersDB.sql` in phpMyAdmin
4. Make sure `config/database.php` matches your MySQL credentials
5. Confirm these URLs work in a browser:
   - `http://localhost/haumonsters_api/get_monsters.php`
   - `http://localhost/haumonsters_api/`

## Real Phone URL

If your phone is on the same Wi-Fi as your PC, use your PC's IPv4 address:

- `http://YOUR_PC_IP/haumonsters_api`

Example:

- `http://192.168.1.5/haumonsters_api`
