import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/presentation/providers/place_search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {

  const SearchScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      setState(() {
        _query = v.trim();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(placeSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search),
                hintText: 'Rechercher un lieu…',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: resultsAsync.when(
                data: (items) {
                  if (_query.isEmpty) {
                    return const Center(child: Text('Tape un lieu (ex: “Paris”, “Gare de Lyon”).'));
                  }
                  if (items.isEmpty) {
                    return const Center(child: Text('Aucun résultat.'));
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      final subtitleParts = <String>[];
                      if (s.city != null && s.city!.isNotEmpty) subtitleParts.add(s.city!);
                      if (s.state != null && s.state!.isNotEmpty) subtitleParts.add(s.state!);
                      if (s.country != null && s.country!.isNotEmpty) subtitleParts.add(s.country!);

                      return ListTile(
                        title: Text(s.name),
                        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' • ')),
                        trailing: const Icon(LucideIcons.chevronRight),
                        onTap: () => Navigator.of(context).pop<PlaceSuggestion>(s),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) {
                  final msg = err is AppFailure ? err.message : err.toString();
                  return Center(child: Text(msg));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
