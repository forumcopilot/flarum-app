import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../config/app_forum_config.dart';
import '../../l10n/flarum_l10n.dart';

/// Forums to switch to in a debug build, for Phase 2's exit check (browse the census forums
/// on a phone): the local test forums, reached through adb reverse (docs/device-testing.md),
/// and the 21 forums the census check reads (test/census/census_test.dart).
const debugForums = <AppForumConfig>[
  AppForumConfig(name: 'Test forum 2.0 (local)', baseUrl: 'http://127.0.0.1:8082'),
  AppForumConfig(name: 'Test forum 1.8 (local)', baseUrl: 'http://127.0.0.1:8081'),
  AppForumConfig(name: 'Flarum Community', baseUrl: 'https://discuss.flarum.org'),
  AppForumConfig(name: 'mondedie.fr', baseUrl: 'https://mondedie.fr'),
  AppForumConfig(name: 'osTicket Forum', baseUrl: 'https://forum.osticket.com'),
  AppForumConfig(name: 'Swisscom Community', baseUrl: 'https://community.swisscom.ch'),
  AppForumConfig(name: 'Flarum en Español', baseUrl: 'https://flarum.es'),
  AppForumConfig(name: 'Linux Mint Україна', baseUrl: 'https://www.linuxmint.com.ua'),
  AppForumConfig(name: 'مُنتَدى الدّعم العَربي', baseUrl: 'https://foro.arsoporte.com'),
  AppForumConfig(name: 'LightCafe', baseUrl: 'https://bbs.liht.cc'),
  AppForumConfig(name: 'Yazılım Topluluğu', baseUrl: 'https://yazilimtoplulugu.com'),
  AppForumConfig(name: 'Acteurs Gezocht', baseUrl: 'https://forum.acteurs-gezocht.nl'),
  AppForumConfig(name: 'Mazda Mini Truckin', baseUrl: 'https://mazdaminitruckin.com/forums'),
  AppForumConfig(name: "Le Point d'Arrêt", baseUrl: 'https://lepointdarret.com/public'),
  AppForumConfig(name: 'KaOS', baseUrl: 'https://forum.kaosx.us'),
  AppForumConfig(name: 'Flarum 2x', baseUrl: 'https://flarum2.huseyinfiliz.com'),
  AppForumConfig(name: 'Flarum 中文社区', baseUrl: 'https://discuss.flarum.org.cn'),
  AppForumConfig(name: 'Forum Einsamkeit', baseUrl: 'https://forum-einsamkeit.org'),
  AppForumConfig(name: 'QuestPost', baseUrl: 'https://questpost.ru'),
  AppForumConfig(name: 'Next Gen Business Community', baseUrl: 'https://ngbc.kku.ac.th'),
  AppForumConfig(name: 'PeopleInside.IT', baseUrl: 'https://community.peopleinside.it'),
  AppForumConfig(name: 'あににゃ', baseUrl: 'https://f.ani-nya.com'),
  AppForumConfig(name: 'Flarum Deutsch', baseUrl: 'https://www.flarumde.com'),
];

/// Whether the forum switcher shows: debug builds only, never in a release.
bool get showForumSwitcher => kDebugMode;

/// Lets a debug build switch forums: a list, and an address of one's own.
/// Pops the chosen forum.
class DebugForumPage extends StatefulWidget {
  const DebugForumPage({super.key, required this.current});

  final String current;

  static Future<AppForumConfig?> open(BuildContext context, String current) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => DebugForumPage(current: current)));

  @override
  State<DebugForumPage> createState() => _DebugForumPageState();
}

class _DebugForumPageState extends State<DebugForumPage> {
  final _address = TextEditingController();

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _openAddress() {
    final url = _address.text.trim();
    if (Uri.tryParse(url)?.hasAuthority != true) return;
    Navigator.of(context).pop(AppForumConfig(name: Uri.parse(url).host, baseUrl: url));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = flarumL10n(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Forum (debug)')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _address,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'https://forum.example.com',
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), tooltip: l10n.search, onPressed: _openAddress),
              ),
              onSubmitted: (_) => _openAddress(),
            ),
          ),
          for (final forum in debugForums)
            ListTile(
              title: Text(forum.name),
              subtitle: Text(forum.baseUrl),
              trailing: forum.baseUrl == widget.current ? const Icon(Icons.check) : null,
              onTap: () => Navigator.of(context).pop(forum),
            ),
        ],
      ),
    );
  }
}
