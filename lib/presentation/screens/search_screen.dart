import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/presentation/providers/place_search_provider.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';
import 'package:weathernav/presentation/widgets/app_state_message.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({required this.title, this.initialQuery, super.key});
  final String title;
  final String? initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      _controller.text = q;
      _query = q;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(LucideIcons.search),
                hintText: 'Rechercher un lieu…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: resultsAsync.when(
                data: (items) {
                  if (_query.isEmpty) {
                    return const AppStateMessage(
                      icon: LucideIcons.search,
                      illustrationAssetName:
                          'assets/illustrations/empty_search.svg',
                      title: 'Recherche de destination',
                      message: 'Tape un lieu (ex: “Paris”, “Gare de Lyon”).',
                    );
                  }
                  if (items.isEmpty) {
                    return const AppStateMessage(
                      icon: LucideIcons.mapPinOff,
                      illustrationAssetName:
                          'assets/illustrations/empty_search.svg',
                      title: 'Aucun résultat',
                      message: 'Aucun lieu trouvé. Essaie un nom plus précis.',
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = items[i];
                      final subtitleParts = <String>[];
                      final city = s.city;
                      if (city != null && city.isNotEmpty)
                        subtitleParts.add(city);
                      final state = s.state;
                      if (state != null && state.isNotEmpty)
                        subtitleParts.add(state);
                      final country = s.country;
                      if (country != null && country.isNotEmpty)
                        subtitleParts.add(country);

                      return ListTile(
                        title: Text(s.name),
                        subtitle: subtitleParts.isEmpty
                            ? null
                            : Text(subtitleParts.join(' • ')),
                        trailing: const Icon(LucideIcons.chevronRight),
                        onTap: () =>
                            Navigator.of(context).pop<PlaceSuggestion>(s),
                      );
                    },
                  );
                },
                loading: () => const Center(child: AppLoadingIndicator()),
                error: (err, st) {
                  final msg = err is AppFailure ? err.message : err.toString();
                  return AppStateMessage(
                    icon: LucideIcons.alertTriangle,
                    iconColor: scheme.error,
                    illustrationAssetName:
                        'assets/illustrations/error_state.svg',
                    title: 'Erreur de recherche',
                    message: msg,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
