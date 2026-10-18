import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const AutoDeckApp());

const _bg = Color(0xFF0B0F1A);
const _teal = Color(0xFF5EF2D6);

class AutoDeckApp extends StatelessWidget {
  const AutoDeckApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mosya Deck Auto',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: _bg,
          colorScheme: ColorScheme.fromSeed(seedColor: _teal, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: const DeckHome(),
      );
}

class DeckHome extends StatefulWidget {
  const DeckHome({super.key});
  @override
  State<DeckHome> createState() => _DeckHomeState();
}

class _DeckHomeState extends State<DeckHome> {
  final _player = AudioPlayer();
  DateTime _now = DateTime.now();
  Timer? _clock;
  int _tab = 0;
  bool _isPlaying = false;
  String _url = 'https://www.google.com';
  late final WebViewController _web = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(_url));

  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    // The recovered asset is named welcome_chime, not confirmed as a salam recording.
    _prepareChime();
  }

  Future<void> _prepareChime() async {
    try {
      await _player.setSource(AssetSource('legacy/dd_welcome_chime.wav'));
    } catch (_) {
      // Audio is optional; a playback failure must not stop the app from starting.
    }
  }

  Future<void> _playChime() async {
    try {
      await _player.play(AssetSource('legacy/dd_welcome_chime.wav'));
    } catch (_) {
      // Ignore playback errors so the UI stays usable on devices without audio.
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: switch (_tab) {
        0 => _dashboard(),
        1 => _simplePage('Waktu solat', Icons.mosque, 'Jadual lokasi dan data waktu solat perlu disambungkan.'),
        2 => _simplePage('Bola sepak', Icons.sports_soccer, 'Perlawanan, keputusan langsung dan carta liga.'),
        _ => _browser(),
      }),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Utama'),
          NavigationDestination(icon: Icon(Icons.mosque_outlined), label: 'Solat'),
          NavigationDestination(icon: Icon(Icons.sports_soccer_outlined), label: 'Bola'),
          NavigationDestination(icon: Icon(Icons.language), label: 'Browser'),
        ],
      ),
    );
  }

  Widget _dashboard() => LayoutBuilder(builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 18 : 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('AUTODECK', style: TextStyle(color: _teal, letterSpacing: 4, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('${_two(_now.hour)}:${_two(_now.minute)}', style: TextStyle(fontSize: compact ? 58 : 82, fontWeight: FontWeight.w200)),
            Text('${_weekday(_now.weekday)}, ${_now.day} ${_month(_now.month)} ${_now.year}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 26),
            Wrap(spacing: 10, runSpacing: 10, children: const [
              _InfoChip(icon: Icons.cloud_outlined, label: 'Cuaca', value: 'Belum disambung'),
              _InfoChip(icon: Icons.mosque_outlined, label: 'Waktu solat', value: 'Pilih lokasi'),
              _InfoChip(icon: Icons.sports_soccer, label: 'Bola sepak', value: 'Tiada data langsung'),
            ]),
            const SizedBox(height: 28),
            _card(Icons.music_note, 'Muzik & lirik', 'Kawal pemain media peranti dari skrin utama.', trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous)),
              IconButton(onPressed: () => setState(() => _isPlaying = !_isPlaying), icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 38, color: _teal)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next)),
            ])),
            const SizedBox(height: 14),
            _card(Icons.volume_up_outlined, 'Salam pembukaan', 'Audio asal: welcome chime (belum disahkan sebagai rakaman salam).', trailing: IconButton(
              onPressed: _playChime,
              icon: const Icon(Icons.play_arrow, color: _teal),
            )),
            const SizedBox(height: 14),
            _card(Icons.directions_car_outlined, 'Android Auto', 'Paparan kereta memerlukan integrasi Android for Cars dan kelulusan Google Play.', trailing: const Icon(Icons.info_outline, color: _teal)),
          ]),
        );
      });

  Widget _simplePage(String title, IconData icon, String message) => Center(
        child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 56, color: _teal), const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
        ])),
      );

  Widget _browser() => Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 6), child: Row(children: [
          Expanded(child: TextField(
            controller: TextEditingController(text: _url),
            keyboardType: TextInputType.url,
            decoration: InputDecoration(hintText: 'Masukkan alamat web', prefixIcon: const Icon(Icons.language), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
            onSubmitted: (value) {
              final target = value.contains('://') ? value : 'https://$value';
              setState(() => _url = target);
              _web.loadRequest(Uri.parse(target));
            },
          )),
          IconButton(onPressed: () => _web.reload(), icon: const Icon(Icons.refresh)),
        ])),
        Expanded(child: WebViewWidget(controller: _web)),
      ]);

  Widget _card(IconData icon, String title, String subtitle, {required Widget trailing}) => Card(
        color: Colors.white.withValues(alpha: .07),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withValues(alpha: .12))),
        child: ListTile(leading: Icon(icon, color: _teal), title: Text(title), subtitle: Text(subtitle), trailing: trailing),
      );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 18, color: _teal),
        label: Text('$label · $value'),
        backgroundColor: Colors.white.withValues(alpha: .08),
        side: BorderSide(color: Colors.white.withValues(alpha: .12)),
      );
}

String _two(int n) => n.toString().padLeft(2, '0');
String _weekday(int n) => const ['Isnin', 'Selasa', 'Rabu', 'Khamis', 'Jumaat', 'Sabtu', 'Ahad'][n - 1];
String _month(int n) => const ['Januari', 'Februari', 'Mac', 'April', 'Mei', 'Jun', 'Julai', 'Ogos', 'September', 'Oktober', 'November', 'Disember'][n - 1];
