import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sleep_provider.dart';
import '../widgets/statistics_card.dart';
import 'add_sleep_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName; // ← di sini

  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Refresh data saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SleepProvider>(context, listen: false).loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<SleepProvider>(
          builder: (context, provider, child) {
            final userName = provider.userProfile?.name ?? 'Pengguna';
            final targetHours = provider.userProfile?.targetSleepHours ?? 8;

            return CustomScrollView(
              slivers: [
                // App Bar
              SliverAppBar(
  expandedHeight: 120,
  floating: false,
  pinned: true,
  backgroundColor: const Color(0xFF667eea),
  flexibleSpace: FlexibleSpaceBar(
    titlePadding: EdgeInsets.zero, 
    title: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Text(
            'Halo, $userName!',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryScreen(),
                ),
              );
            },
            tooltip: 'Riwayat Lengkap',
          ),
        ],
      ),
    ),
    background: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
      ),
    ),
  ),
),


                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistik Cards
                        const Text(
                          'Statistik Tidur Anda',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: StatisticsCard(
                                icon: Icons.nightlight_round,
                                title: 'Rata-rata',
                                value: provider.averageSleepDuration
                                    .toStringAsFixed(1),
                                unit: 'jam',
                                color: const Color(0xFF667eea),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatisticsCard(
                                icon: Icons.calendar_today,
                                title: 'Minggu Ini',
                                value: provider.thisWeekTotal.toStringAsFixed(0),
                                unit: 'jam',
                                color: const Color(0xFF764ba2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        StatisticsCard(
                          icon: Icons.flag,
                          title: 'Target Harian',
                          value: targetHours.toString(),
                          unit: 'jam per hari',
                          color: const Color(0xFFf093fb),
                          isWide: true,
                        ),

                        const SizedBox(height: 24),

                        // Tidur Hari Ini
                        _buildTodaySection(context, provider),

                        const SizedBox(height: 24),

                        // Recent Records
                        _buildRecentRecords(provider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSleepScreen()),
          );

          if (result == true && mounted) {
            Provider.of<SleepProvider>(context, listen: false).loadRecords();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Tidur'),
        backgroundColor: const Color(0xFF667eea),
      ),
    );
  }

  Widget _buildTodaySection(BuildContext context, SleepProvider provider) {
    final todayRecord = provider.todayRecord;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Tidur Hari Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (todayRecord != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Durasi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayRecord.formattedDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Kualitas',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todayRecord.quality,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bedtime_outlined,
                    size: 40,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada catatan tidur hari ini',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentRecords(SleepProvider provider) {
    final recentRecords = provider.records.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Catatan Terbaru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (recentRecords.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada catatan tidur',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai catat tidur Anda dengan\nmenekan tombol di bawah',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...recentRecords.map((record) => _buildRecordCard(record, provider)),
      ],
    );
  }

  Widget _buildRecordCard(record, SleepProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getQualityColor(record.quality).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.bedtime,
            color: _getQualityColor(record.quality),
          ),
        ),
        title: Text(
          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(record.bedTime),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${DateFormat('HH:mm').format(record.bedTime)} - ${DateFormat('HH:mm').format(record.wakeTime)}',
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(record.formattedDuration),
                const SizedBox(width: 16),
                Icon(
                  _getQualityIcon(record.quality),
                  size: 16,
                  color: _getQualityColor(record.quality),
                ),
                const SizedBox(width: 4),
                Text(record.quality),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteRecord(record.id, provider),
        ),
      ),
    );
  }

  Future<void> _deleteRecord(int id, SleepProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
         TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Batal',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white, // warna teks
          ),
          child: const Text('Hapus'),
        ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.deleteRecord(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getQualityColor(String quality) {
    switch (quality) {
      case 'Sangat Baik':
        return Colors.green;
      case 'Baik':
        return Colors.lightGreen;
      case 'Cukup':
        return Colors.orange;
      case 'Buruk':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getQualityIcon(String quality) {
    switch (quality) {
      case 'Sangat Baik':
        return Icons.sentiment_very_satisfied;
      case 'Baik':
        return Icons.sentiment_satisfied;
      case 'Cukup':
        return Icons.sentiment_neutral;
      case 'Buruk':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}