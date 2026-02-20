import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const App());
}

// ── Palette ───────────────────────────────────────────────────────────────────

const _bg       = Color(0xFFFAFAF9);
const _surface  = Color(0xFFFFFFFF);
const _border   = Color(0xFFEAEAE8);
const _ink      = Color(0xFF111110);
const _inkMid   = Color(0xFF6B6B67);
const _inkLight = Color(0xFFB0AFA9);
const _accent   = Color(0xFF2563EB);

// ── App ───────────────────────────────────────────────────────────────────────

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.light(primary: _accent, surface: _surface),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      ),
      home: const SearchScreen(),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

enum ResultKind { web, news, video }

class SearchResult {
  final String title;
  final String snippet;
  final String domain;
  final String meta;
  final ResultKind kind;

  const SearchResult({
    required this.title,
    required this.snippet,
    required this.domain,
    required this.meta,
    required this.kind,
  });
}

const _allResults = <SearchResult>[
  SearchResult(
    title: 'Flutter — Build apps for any screen',
    snippet:
        "Flutter is Google's open-source UI toolkit for building beautiful, natively compiled apps for mobile, web, and desktop from a single codebase.",
    domain: 'flutter.dev',
    meta: 'Official',
    kind: ResultKind.web,
  ),
  SearchResult(
    title: 'Dart Programming Language',
    snippet:
        'Dart is a client-optimized language for fast apps on any platform. It pairs with Flutter to let you build expressive, type-safe UIs.',
    domain: 'dart.dev',
    meta: 'Official',
    kind: ResultKind.web,
  ),
  SearchResult(
    title: 'Flutter 3.22 Released — Impeller on by Default',
    snippet:
        'The Flutter team ships version 3.22 with Impeller enabled across iOS and Android, delivering smoother animations and reduced jank.',
    domain: 'medium.com',
    meta: '3 hours ago',
    kind: ResultKind.news,
  ),
  SearchResult(
    title: 'Build a Full App with Flutter in 2 Hours',
    snippet:
        'A hands-on walkthrough covering state management with Riverpod, navigation with GoRouter, and local storage with Hive.',
    domain: 'youtube.com',
    meta: '42 min',
    kind: ResultKind.video,
  ),
  SearchResult(
    title: 'State Management Options in Flutter Compared',
    snippet:
        'An in-depth comparison of Provider, Riverpod, BLoC, and GetX — covering boilerplate, scalability, and testability.',
    domain: 'fluttergems.dev',
    meta: '1 week ago',
    kind: ResultKind.web,
  ),
  SearchResult(
    title: 'Flutter vs React Native in 2024',
    snippet:
        'A no-nonsense look at performance benchmarks, ecosystem maturity, developer experience, and hiring considerations.',
    domain: 'blog.logrocket.com',
    meta: '2 weeks ago',
    kind: ResultKind.news,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  bool _loading = false;
  bool _showResults = false;
  String _query = '';
  String _filter = 'All';
  final _filters = ['All', 'Web', 'News', 'Videos'];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    _focus.unfocus();
    setState(() {
      _query = q;
      _loading = true;
      _showResults = false;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() {
      _loading = false;
      _showResults = true;
      _filter = 'All';
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _showResults = false;
      _query = '';
    });
    _focus.requestFocus();
  }

  List<SearchResult> get _results {
    if (_filter == 'All') return _allResults;
    final k = _filter == 'Web'
        ? ResultKind.web
        : _filter == 'News'
            ? ResultKind.news
            : ResultKind.video;
    return _allResults.where((r) => r.kind == k).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Container(
              color: _surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    child: Row(
                      children: [
                        const Text(
                          'search.',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: _buildSearchBar()),
                      ],
                    ),
                  ),

                  // Filter chips — only when results are showing
                  if (_showResults) ...[
                    const _Divider(),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: _filters.map((f) {
                          final active = f == _filter;
                          return GestureDetector(
                            onTap: () => setState(() => _filter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: active ? _ink : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active ? Colors.white : _inkMid,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const _Divider(),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const _Loader()
                  : _showResults
                      ? _buildResults()
                      : const _EmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const SizedBox(width: 11),
          const Icon(Icons.search, size: 17, color: _inkLight),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: _ink),
              decoration: const InputDecoration(
                hintText: 'Search…',
                hintStyle: TextStyle(fontSize: 14, color: _inkLight),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _clear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.close, size: 15, color: _inkLight),
              ),
            )
          else
            const SizedBox(width: 10),
        ],
      ),
    );
  }

  // ── Results ─────────────────────────────────────────────────────────────────

  Widget _buildResults() {
    final list = _results;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('(>_<)', style: TextStyle(fontSize: 28, color: _inkLight)),
            const SizedBox(height: 10),
            Text(
              'No results for "$_query" in this category.',
              style: const TextStyle(fontSize: 13, color: _inkLight),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
      itemCount: list.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${list.length} results for "$_query"',
              style: const TextStyle(fontSize: 12, color: _inkLight),
            ),
          );
        }
        return _ResultCard(result: list[i - 1]);
      },
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '( ᵕ—ᴗ— )',
            style: TextStyle(fontSize: 32, color: _inkLight, letterSpacing: 2),
          ),
          SizedBox(height: 12),
          Text(
            'Type something to search',
            style: TextStyle(fontSize: 14, color: _inkLight),
          ),
        ],
      ),
    );
  }
}

// ── Loader ────────────────────────────────────────────────────────────────────

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 1.8, color: _ink),
      ),
    );
  }
}

// ── Result Card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final SearchResult result;
  const _ResultCard({required this.result});

  static const _badge = {
    ResultKind.web:   null,
    ResultKind.news:  'NEWS',
    ResultKind.video: 'VIDEO',
  };

  @override
  Widget build(BuildContext context) {
    final badgeLabel = _badge[result.kind];

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: domain + badge + meta
              Row(
                children: [
                  Text(
                    result.domain,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _inkLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (badgeLabel != null) ...[
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _ink,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        badgeLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    result.meta,
                    style: const TextStyle(fontSize: 11, color: _inkLight),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                result.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                  height: 1.35,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 5),

              // Snippet
              Text(
                result.snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: _inkMid,
                  height: 1.55,
                ),
              ),

              const SizedBox(height: 12),

              // Action row
              Row(
                children: [
                  _IconBtn(icon: Icons.bookmark_border),
                  const SizedBox(width: 2),
                  _IconBtn(icon: Icons.ios_share),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: const [
                        Text(
                          'Visit',
                          style: TextStyle(
                            fontSize: 12,
                            color: _accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.arrow_outward, size: 12, color: _accent),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: _inkLight),
      ),
    );
  }
}

// ── Shared Divider ────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: _border);
  }
}