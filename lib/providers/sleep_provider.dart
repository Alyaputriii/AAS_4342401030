import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_record.dart';
import '../models/user_profile.dart';
import '../database/database_helper.dart';

class SleepProvider with ChangeNotifier {
  List<SleepRecord> _records = [];
  UserProfile? _userProfile;
  bool _isLoading = false;

  List<SleepRecord> get records => _records;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  // Inisialisasi data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadUserProfile();
      await loadRecords();
    } catch (e) {
      debugPrint('Error saat inisialisasi: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Muat profil user dari SharedPreferences
  Future<void> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('userName');
      final targetHours = prefs.getInt('targetSleepHours') ?? 8;

      if (name != null) {
        _userProfile = UserProfile(
          name: name,
          targetSleepHours: targetHours,
        );
      }
    } catch (e) {
      debugPrint('Error memuat profil: $e');
    }
  }

  // Simpan profil user
  Future<void> saveUserProfile(String name, int targetHours) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', name);
      await prefs.setInt('targetSleepHours', targetHours);

      _userProfile = UserProfile(
        name: name,
        targetSleepHours: targetHours,
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal menyimpan profil: $e');
    }
  }

  // Muat semua record dari database
  Future<void> loadRecords() async {
    try {
      _records = await DatabaseHelper.instance.readAllRecords();
      notifyListeners();
    } catch (e) {
      debugPrint('Error memuat record: $e');
      throw Exception('Gagal memuat data tidur: $e');
    }
  }

  // Tambah record baru
  Future<void> addRecord(SleepRecord record) async {
    try {
      final newRecord = await DatabaseHelper.instance.create(record);
      _records.insert(0, newRecord);
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal menambah catatan tidur: $e');
    }
  }

  // Hapus record
  Future<void> deleteRecord(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      _records.removeWhere((record) => record.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Gagal menghapus catatan tidur: $e');
    }
  }

  // Hitung rata-rata durasi tidur
  double get averageSleepDuration {
    if (_records.isEmpty) return 0;
    double total = _records.fold(0, (sum, record) => sum + record.duration);
    return total / _records.length;
  }

  // Hitung total tidur minggu ini
  double get thisWeekTotal {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weekRecords = _records.where((record) =>
      record.bedTime.isAfter(weekAgo) && record.bedTime.isBefore(now)
    );

    return weekRecords.fold(0, (sum, record) => sum + record.duration);
  }

  // Ambil record hari ini
  SleepRecord? get todayRecord {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    try {
      return _records.firstWhere((record) {
        final recordDate = DateTime(
          record.bedTime.year,
          record.bedTime.month,
          record.bedTime.day,
        );
        return recordDate == today;
      });
    } catch (e) {
      return null;
    }
  }

  // Hitung persentase kualitas tidur
  Map<String, int> get qualityDistribution {
    Map<String, int> distribution = {
      'Buruk': 0,
      'Cukup': 0,
      'Baik': 0,
      'Sangat Baik': 0,
    };

    for (var record in _records) {
      distribution[record.quality] = (distribution[record.quality] ?? 0) + 1;
    }

    return distribution;
  }
}