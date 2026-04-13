import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deteksipisang_app/models/prediction_result.dart';
import 'package:deteksipisang_app/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  PredictionResult? _predictionResult;
  bool _isLoading = false;

  Future<void> _openCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (photo != null && mounted) await _runPrediction(photo);
  }

  Future<void> _openGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && mounted) await _runPrediction(image);
  }

  Future<void> _runPrediction(XFile file) async {
    setState(() {
      _pickedFile = file;
      _isLoading = true;
      _predictionResult = null;
    });
    try {
      final result = await ApiService.predict(File(file.path));
      if (mounted) setState(() => _predictionResult = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6E8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 28),
                    Center(
                      child: Column(
                        children: const [
                          Text(
                            'Deteksi Kematangan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Arahkan kamera ke buah pisang untuk\nmendapatkan analisis tingkat\nkematangan instan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF888888),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(child: _buildScanCircle()),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    _buildResultBox(),
                    const SizedBox(height: 28),
                    _buildTipsSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFD600),
          ),
          child: const Center(
            child: Text('🍌', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'GedangScan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A3800),
          ),
        ),
      ],
    );
  }

  Widget _buildScanCircle() {
    return SizedBox(
      width: 290,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow
          Container(
            width: 290,
            height: 290,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD600).withOpacity(0.35),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
          // Outer ring with gradient
          Container(
            width: 268,
            height: 268,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                startAngle: 0,
                endAngle: 2 * pi,
                colors: [
                  Color(0xFFFFF176),
                  Color(0xFFFFD600),
                  Color(0xFFC89000),
                  Color(0xFF9A6E00),
                  Color(0xFFC89000),
                  Color(0xFFFFD600),
                  Color(0xFFFFF176),
                ],
              ),
            ),
          ),
          // Light yellow filler
          Container(
            width: 220,
            height: 220,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFF8D0),
            ),
          ),
          // White inner circle
          Container(
            width: 184,
            height: 184,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: _pickedFile != null
                ? ClipOval(
                    child: Image.file(
                      File(_pickedFile!.path),
                      width: 184,
                      height: 184,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.crop_free, size: 44, color: Color(0xFFB8860B)),
                      SizedBox(height: 6),
                      Text(
                        'SCAN',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.5,
                          color: Color(0xFFB8860B),
                        ),
                      ),
                    ],
                  ),
          ),
          // Siap Deteksi badge
          Positioned(
            top: 28,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF4CAF50)),
                  SizedBox(width: 6),
                  Text(
                    'Siap Deteksi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.camera_alt_outlined,
            label: 'Buka Kamera',
            onTap: _openCamera,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            icon: Icons.upload_file_outlined,
            label: 'Unggah Foto',
            onTap: _openGallery,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26, color: const Color(0xFF7A6000)),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A6000),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLabelColor(String className) {
    switch (className) {
      case 'fully-ripe':
        return const Color(0xFFE65100);
      case 'semi-ripe':
        return const Color(0xFFFFB300);
      case 'unripe':
        return const Color(0xFF388E3C);
      default:
        return const Color(0xFF333333);
    }
  }

  Widget _buildProbBar(String className, double prob) {
    const labelMap = {
      'unripe': 'Belum Matang',
      'semi-ripe': 'Setengah Matang',
      'fully-ripe': 'Matang',
    };
    final color = _getLabelColor(className);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelMap[className] ?? className,
                style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
              ),
              Text(
                '${(prob * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prob,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox() {
    late Widget content;

    if (_isLoading) {
      content = const Column(
        children: [
          CircularProgressIndicator(color: Color(0xFFFFD600)),
          SizedBox(height: 12),
          Text(
            'Menganalisis gambar...',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
        ],
      );
    } else if (_predictionResult != null && _pickedFile != null) {
      final result = _predictionResult!;
      final labelColor = _getLabelColor(result.className);
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_pickedFile!.path),
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  result.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(result.confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.probabilities.entries.map(
            (e) => _buildProbBar(e.key, e.value),
          ),
        ],
      );
    } else {
      content = Column(
        children: [
          Icon(Icons.bar_chart, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'Hasil Deteksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pindai atau unggah foto untuk melihat\ntingkat kematangan dan tips\npenyimpanan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: const Color(0xFFD4B800),
        radius: 16,
        strokeWidth: 1.5,
        dashWidth: 8,
        dashGap: 5,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: content,
      ),
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tips Kebun',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat Semua →',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _tipCard(
                icon: Icons.air,
                iconBg: const Color(0xFFFFF9C4),
                iconColor: const Color(0xFFB8860B),
                title: 'Kontrol Etilen',
                desc:
                    'Pisahkan pisang dari buah lain untuk memperlambat proses pematangan secara alami.',
              ),
              const SizedBox(width: 12),
              _tipCard(
                icon: Icons.thermostat_outlined,
                iconBg: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF388E3C),
                title: 'Suhu Penyimpanan',
                desc:
                    'Simpan pisang pada suhu ruang sekitar 13–18°C untuk kematangan optimal.',
              ),
              const SizedBox(width: 12),
              _tipCard(
                icon: Icons.water_drop_outlined,
                iconBg: const Color(0xFFE3F2FD),
                iconColor: const Color(0xFF1976D2),
                title: 'Kelembaban',
                desc:
                    'Jaga agar pisang tidak terkena air langsung untuk mencegah pembusukan dini.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tipCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF888888),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(index: 0, icon: Icons.crop_free, label: 'Pindai'),
            _navItem(index: 1, icon: Icons.history, label: 'Riwayat'),
            _navItem(index: 2, icon: Icons.lightbulb_outline, label: 'Tips'),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFD600) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: isActive ? Colors.white : Colors.grey),
            if (isActive) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 16,
    this.strokeWidth = 1.5,
    this.dashWidth = 8,
    this.dashGap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
