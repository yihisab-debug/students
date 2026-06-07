import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/app_user.dart';
import '../auth/auth_service.dart';
import '../data/student_data.dart';
import '../data/subject_repository.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/subject_card.dart';
import 'subject_detail_sheet.dart';

enum SortMode { name, gradeDesc, gradeAsc, favoritesFirst }

extension on SortMode {
  String get label {
    switch (this) {
      case SortMode.name:
        return 'По названию (А–Я)';
      case SortMode.gradeDesc:
        return 'По оценке (убыванию)';
      case SortMode.gradeAsc:
        return 'По оценке (возрастанию)';
      case SortMode.favoritesFirst:
        return 'Сначала избранные';
    }
  }
}

class HomeScreen extends StatefulWidget {
  final AuthService auth;
  final AppUser user;
  const HomeScreen({super.key, required this.auth, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StudentData _data = StudentData();
  StreamSubscription<List<Subject>>? _sub;

  List<Subject> _subjects = [];
  final Set<String> _favorites = {};
  bool _loaded = false;
  bool _seededFavorites = false;

  final TextEditingController _searchCtrl = TextEditingController();

  String _query = '';
  int _tab = 0;
  SortMode _sort = SortMode.name;
  SubjectStatus? _statusFilter;
  double _minGrade = 0;

  @override
  void initState() {
    super.initState();
    _sub = _data.watchSubjects(widget.user).listen((subs) {
      if (!_seededFavorites) {
        for (final s in subs) {
          if (s.isFavorite) _favorites.add(s.name);
        }
        _seededFavorites = true;
      }
      setState(() {
        _subjects = subs;
        _loaded = true;
      });
    }, onError: (_) {
      setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  double get _gpa {
    if (_subjects.isEmpty) return 0;
    final sum = _subjects.fold<double>(0, (a, s) => a + s.finalGrade);
    return sum / _subjects.length;
  }

  int get _passedCount =>
      _subjects.where((s) => s.status == SubjectStatus.passed).length;

  int get _inProgressCount =>
      _subjects.where((s) => s.status == SubjectStatus.inProgress).length;

  int get _passPercent => _subjects.isEmpty
      ? 0
      : ((_passedCount / _subjects.length) * 100).round();

  List<Subject> get _visible {
    for (final s in _subjects) {
      s.isFavorite = _favorites.contains(s.name);
    }
    var list = _subjects.where((s) {
      if (_tab == 1 && !s.isFavorite) return false;
      if (_tab == 2 && s.status != SubjectStatus.passed) return false;
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!s.name.toLowerCase().contains(q) &&
            !s.teacher.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_statusFilter != null && s.status != _statusFilter) return false;
      if (s.finalGrade < _minGrade) return false;
      return true;
    }).toList();

    switch (_sort) {
      case SortMode.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortMode.gradeDesc:
        list.sort((a, b) => b.finalGrade.compareTo(a.finalGrade));
        break;
      case SortMode.gradeAsc:
        list.sort((a, b) => a.finalGrade.compareTo(b.finalGrade));
        break;
      case SortMode.favoritesFirst:
        list.sort((a, b) {
          if (a.isFavorite == b.isFavorite) {
            return a.name.compareTo(b.name);
          }
          return a.isFavorite ? -1 : 1;
        });
        break;
    }
    return list;
  }

  void _toggleFavorite(Subject s) => setState(() {
        if (_favorites.contains(s.name)) {
          _favorites.remove(s.name);
        } else {
          _favorites.add(s.name);
        }
      });

  void _openSort() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Сортировка',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            ),
            for (final m in SortMode.values)
              RadioListTile<SortMode>(
                value: m,
                groupValue: _sort,
                activeColor: AppTheme.primary,
                title: Text(m.label),
                onChanged: (v) {
                  setState(() => _sort = v!);
                  Navigator.pop(context);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openFilters() {
    SubjectStatus? tempStatus = _statusFilter;
    double tempMin = _minGrade;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Фильтры',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              const Text('Статус', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _filterChip('Все', tempStatus == null,
                      () => setSheet(() => tempStatus = null)),
                  _filterChip('Зачтено',
                      tempStatus == SubjectStatus.passed,
                      () => setSheet(() => tempStatus = SubjectStatus.passed)),
                  _filterChip('В процессе',
                      tempStatus == SubjectStatus.inProgress,
                      () =>
                          setSheet(() => tempStatus = SubjectStatus.inProgress)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Минимальная оценка',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(tempMin.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary)),
                ],
              ),
              Slider(
                value: tempMin,
                min: 0,
                max: 5,
                divisions: 10,
                activeColor: AppTheme.primary,
                label: tempMin.toStringAsFixed(1),
                onChanged: (v) => setSheet(() => tempMin = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _statusFilter = null;
                          _minGrade = 0;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Сбросить'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary),
                      onPressed: () {
                        setState(() {
                          _statusFilter = tempStatus;
                          _minGrade = tempMin;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Применить'),
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

  Widget _filterChip(String text, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.primary.withOpacity(0.15),
      labelStyle: TextStyle(
        color: selected ? AppTheme.primaryDark : AppTheme.inkSoft,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
          color: selected ? AppTheme.primary : const Color(0xFFE0E1EC)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            final cols = width >= 1100
                ? 3
                : width >= 700
                    ? 2
                    : 1;
            final horizontal = width >= 700 ? 28.0 : 16.0;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _header(),
                      const SizedBox(height: 20),
                      _tabs(),
                      const SizedBox(height: 18),
                      _statsGrid(),
                      const SizedBox(height: 18),
                      _searchRow(width),
                      const SizedBox(height: 18),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  sliver: _visible.isEmpty
                      ? SliverToBoxAdapter(child: _emptyState())
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            mainAxisExtent: 264,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final s = _visible[i];
                              return SubjectCard(
                                subject: s,
                                onTap: () => SubjectDetailSheet.show(
                                  context,
                                  subject: s,
                                  data: _data,
                                  user: widget.user,
                                ),
                                onToggleFavorite: () => _toggleFavorite(s),
                              );
                            },
                            childCount: _visible.length,
                          ),
                        ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
                    child: Center(
                      child: Text(
                        '© 2024 Зачётка · учебный прототип системы оценок',
                        style: TextStyle(
                            color: AppTheme.inkSoft.withOpacity(0.8),
                            fontSize: 12.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.headerGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.school_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Зачётка',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              Text('Успеваемость студента',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: AppTheme.inkSoft)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _profileChip(),
      ],
    );
  }

  Widget _profileChip() {
    final user = widget.user;
    return PopupMenuButton<String>(
      tooltip: 'Аккаунт',
      offset: const Offset(0, 52),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) {
        if (v == 'signout') widget.auth.signOut();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppTheme.ink)),
              Text(user.email,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.inkSoft)),
              const SizedBox(height: 2),
              Text('${StudentInfo.role} · Группа ${user.group ?? '—'}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.inkSoft)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppTheme.inkSoft),
              SizedBox(width: 10),
              Text('Выйти'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFEDEEF5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary,
              backgroundImage:
                  user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(user.initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13))
                  : null,
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more, size: 18, color: AppTheme.inkSoft),
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
    const labels = ['Все предметы', 'Избранное', 'Завершённые'];
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _tab == i
                            ? AppTheme.primary
                            : const Color(0xFFEDEEF5)),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _tab == i ? Colors.white : AppTheme.inkSoft,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _statsGrid() {
    final cards = [
      StatCard(
        icon: Icons.trending_up_rounded,
        label: 'Средний балл',
        value: _gpa.toStringAsFixed(1),
        hint: 'GPA за семестр',
        color: AppTheme.primary,
      ),
      StatCard(
        icon: Icons.menu_book_rounded,
        label: 'Всего предметов',
        value: '${_subjects.length}',
        hint: StudentInfo.term,
        color: AppTheme.accent,
      ),
      StatCard(
        icon: Icons.task_alt_rounded,
        label: 'Сдано',
        value: '$_passedCount',
        hint: '$_passPercent% успеваемость',
        color: const Color(0xFF22A06B),
      ),
      StatCard(
        icon: Icons.schedule_rounded,
        label: 'В процессе',
        value: '$_inProgressCount',
        hint: 'осталось до конца семестра',
        color: const Color(0xFFE0A800),
      ),
    ];
    return LayoutBuilder(
      builder: (context, cc) {
        final w = cc.maxWidth;
        final cols = w >= 900
            ? 4
            : w >= 600
                ? 2
                : 1;
        const spacing = 14.0;
        final cardW = (w - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards) SizedBox(width: cardW, child: c),
          ],
        );
      },
    );
  }

  Widget _searchRow(double width) {
    final search = Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF5)),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        decoration: const InputDecoration(
          hintText: 'Поиск по предметам или преподавателям…',
          prefixIcon: Icon(Icons.search, color: AppTheme.inkSoft),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
      ),
    );

    final buttons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(Icons.tune_rounded, 'Фильтры', _openFilters,
            active: _statusFilter != null || _minGrade > 0),
        const SizedBox(width: 10),
        _actionButton(Icons.swap_vert_rounded, 'Сортировка', _openSort),
      ],
    );

    if (width < 560) {
      return Column(
        children: [search, const SizedBox(height: 12), buttons],
      );
    }
    return Row(
      children: [Expanded(child: search), const SizedBox(width: 12), buttons],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap,
      {bool active = false}) {
    return Material(
      color: active ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: active ? AppTheme.primary : const Color(0xFFEDEEF5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 18,
                  color: active ? AppTheme.primary : AppTheme.inkSoft),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: active ? AppTheme.primaryDark : AppTheme.ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppTheme.inkSoft.withOpacity(0.5)),
          const SizedBox(height: 12),
          const Text('Ничего не найдено',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.ink)),
          const SizedBox(height: 4),
          const Text('Измените запрос или сбросьте фильтры',
              style: TextStyle(color: AppTheme.inkSoft)),
        ],
      ),
    );
  }
}
