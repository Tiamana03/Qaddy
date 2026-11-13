/// Choosing a course: search the catalogue, pick a result, or play on the
/// standard layout.
///
/// The sheet only talks to the `CourseCatalogue` interface, so it works the
/// same with the sample, with GolfCore or with nothing connected. It is honest
/// about each state: searching, results, no match, a provider that cannot be
/// reached, and a catalogue that is not connected yet.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qaddy/core/theme/qaddy_colours.dart';
import 'package:qaddy/core/theme/qaddy_radius.dart';
import 'package:qaddy/core/theme/qaddy_text.dart';
import 'package:qaddy/core/utils/haptics.dart';
import 'package:qaddy/core/widgets/forms/qaddy_search_bar.dart';
import 'package:qaddy/core/widgets/media/qaddy_media_placeholder.dart';
import 'package:qaddy/features/courses/models/course.dart';
import 'package:qaddy/features/courses/state/course_providers.dart';

/// Opens the picker. Choosing a course (or the standard layout) updates
/// [selectedCourseProvider].
Future<void> showCoursePicker(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).extension<QaddyColours>()!.surface1,
    builder: (context) => const CoursePickerSheet(),
  );
}

/// The picker's content.
class CoursePickerSheet extends ConsumerStatefulWidget {
  const CoursePickerSheet({super.key});

  @override
  ConsumerState<CoursePickerSheet> createState() => _CoursePickerSheetState();
}

enum _Phase { loading, results, failed }

class _CoursePickerSheetState extends ConsumerState<CoursePickerSheet> {
  final TextEditingController _text = TextEditingController();
  Timer? _debounce;
  _Phase _phase = _Phase.loading;
  List<CourseSummary> _results = const <CourseSummary>[];
  String? _choosing;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_search());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  Future<void> _search() async {
    final generation = ++_generation;
    setState(() => _phase = _Phase.loading);
    try {
      final found = await ref
          .read(courseCatalogueProvider)
          .search(CourseQuery(text: _text.text));
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = found;
        _phase = _Phase.results;
      });
    } on Object {
      if (!mounted || generation != _generation) return;
      setState(() => _phase = _Phase.failed);
    }
  }

  Future<void> _choose(CourseSummary summary) async {
    setState(() => _choosing = summary.id);
    try {
      final course = await ref.read(courseCatalogueProvider).course(summary.id);
      if (!mounted) return;
      if (course == null) {
        setState(() {
          _choosing = null;
          _phase = _Phase.failed;
        });
        return;
      }
      QaddyHaptics.selection();
      ref.read(selectedCourseProvider.notifier).choose(course);
      Navigator.of(context).pop();
    } on Object {
      if (!mounted) return;
      setState(() {
        _choosing = null;
        _phase = _Phase.failed;
      });
    }
  }

  void _useStandard() {
    QaddyHaptics.selection();
    ref.read(selectedCourseProvider.notifier).choose(null);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;
    final connected = ref.watch(courseCatalogueProvider).isConnected;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Choose your course',
              style: QaddyText.sectionTitle.copyWith(
                color: colours.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (connected) ...<Widget>[
              QaddySearchBar(
                hintText: 'Search courses…',
                controller: _text,
                onChanged: _onChanged,
                showFilter: false,
              ),
              const SizedBox(height: 10),
            ],
            Flexible(child: _body(colours, connected: connected)),
            const SizedBox(height: 10),
            _StandardLayoutRow(onTap: _useStandard),
          ],
        ),
      ),
    );
  }

  Widget _body(QaddyColours colours, {required bool connected}) {
    if (!connected) {
      return const _Message(
        icon: Icons.travel_explore_outlined,
        title: 'Course search is not connected yet',
        message:
            'Qaddy will find your course here once the course database is '
            'connected. Until then you can score on the standard layout.',
      );
    }
    switch (_phase) {
      case _Phase.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        );
      case _Phase.failed:
        return _Message(
          icon: Icons.cloud_off_outlined,
          title: "Couldn't reach the course database",
          message: 'Check your connection and try again.',
          actionLabel: 'Try again',
          onAction: _search,
        );
      case _Phase.results:
        if (_results.isEmpty) {
          return _Message(
            icon: Icons.search_off_outlined,
            title: 'No courses match',
            message: _text.text.trim().isEmpty
                ? 'No courses to show yet.'
                : 'Nothing matches "${_text.text.trim()}". Try another name.',
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: _results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final course = _results[index];
            return CourseRow(
              name: course.name,
              detail: <String>[
                if (course.location.label.isNotEmpty) course.location.label,
                if (course.holeCount != null) '${course.holeCount} holes',
                if (course.distanceKm != null)
                  '${course.distanceKm!.toStringAsFixed(1)} km',
              ].join(' · '),
              logoUrl: course.logoUrl,
              busy: _choosing == course.id,
              onTap: _choosing == null ? () => _choose(course) : null,
            );
          },
        );
    }
  }
}

/// One course in a list: a logo slot, the name and a line of detail.
///
/// The logo slot is 44 square and shows the placeholder until the course has
/// a logo (see `docs/design/asset-register.md`).
class CourseRow extends StatelessWidget {
  const CourseRow({
    required this.name,
    required this.detail,
    this.logoUrl,
    this.onTap,
    this.busy = false,
    this.trailing,
    super.key,
  });

  /// The course's name.
  final String name;

  /// A quiet line under the name.
  final String detail;

  /// The club's logo, when the provider has one.
  final Uri? logoUrl;

  /// Called when the row is tapped; `null` for a row that is not a button.
  final VoidCallback? onTap;

  /// Shows a spinner in place of the trailing widget.
  final bool busy;

  /// Something at the right edge ("Change").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colours = theme.extension<QaddyColours>()!;
    final radius = theme.extension<QaddyRadius>()!;

    final content = Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: QaddyMediaPlaceholder(
              borderRadius: BorderRadius.circular(10),
              image: logoUrl == null ? null : NetworkImage(logoUrl.toString()),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QaddyText.listTitle.copyWith(
                    color: colours.textPrimary,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: QaddyText.meta.copyWith(
                      color: colours.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            ?trailing,
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: detail.isEmpty ? name : '$name. $detail',
      excludeSemantics: onTap != null,
      onTap: onTap,
      child: Material(
        color: colours.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.medium),
          side: BorderSide(color: colours.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class _StandardLayoutRow extends StatelessWidget {
  const _StandardLayoutRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Semantics(
      button: true,
      label: 'Use the standard layout',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.format_list_numbered, size: 20, color: colours.gold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Use the standard layout (par and stroke index only)',
                  style: QaddyText.listMeta.copyWith(
                    color: colours.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).extension<QaddyColours>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 32, color: colours.textSecondary),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: QaddyText.listTitle.copyWith(color: colours.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: QaddyText.listMeta.copyWith(color: colours.textSecondary),
          ),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
