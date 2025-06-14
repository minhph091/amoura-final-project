// lib/presentation/profile/view/widgets/profile_accordion_section.dart

import 'package:flutter/material.dart';
import 'accordion_section_controller.dart';

class ProfileAccordionSection extends StatefulWidget {
  final AccordionSectionController controller;
  final String sectionKey;
  final String title;
  final IconData icon;
  final Widget child;
  final List<Widget>? tabs;
  final List<String>? tabTitles;

  const ProfileAccordionSection({
    super.key,
    required this.controller,
    required this.sectionKey,
    required this.title,
    required this.icon,
    required this.child,
    this.tabs,
    this.tabTitles,
  });

  @override
  State<ProfileAccordionSection> createState() => _ProfileAccordionSectionState();
}

class _ProfileAccordionSectionState extends State<ProfileAccordionSection> with SingleTickerProviderStateMixin {
  int _currentTab = 0;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (widget.tabs != null && widget.tabs!.length > 1) {
      _tabController = TabController(length: widget.tabs!.length, vsync: this);
      _tabController!.addListener(() {
        if (mounted && _tabController!.index != _currentTab) {
          setState(() => _currentTab = _tabController!.index);
        }
      });
    }
  }

  @override
  void didUpdateWidget(ProfileAccordionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.tabs?.length ?? 0) != (oldWidget.tabs?.length ?? 0)) {
      _tabController?.dispose();
      if (widget.tabs != null && widget.tabs!.length > 1) {
        _tabController = TabController(length: widget.tabs!.length, vsync: this);
        _tabController!.addListener(() {
          if (mounted && _tabController!.index != _currentTab) {
            setState(() => _currentTab = _tabController!.index);
          }
        });
      } else {
        _tabController = null;
        _currentTab = 0;
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = widget.controller.currentOpenKey == widget.sectionKey;
    final hasTabs = widget.tabs != null && widget.tabs!.length > 1;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(widget.icon, color: Theme.of(context).colorScheme.primary),
            title: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              // Đảm bảo text luôn hiển thị theo chiều ngang
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            trailing: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              child: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
            ),
            onTap: () => widget.controller.toggle(widget.sectionKey),
          ),
          ClipRect(
            child: AnimatedCrossFade(
              firstChild: const SizedBox(height: 0, width: double.infinity),
              secondChild: hasTabs
                  ? Column(
                children: [
                  if (widget.tabTitles != null)
                    TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: widget.tabTitles!
                          .map((t) => Tab(text: t))
                          .toList(),
                    ),
                  SizedBox(
                    height: 240,
                    child: TabBarView(
                      controller: _tabController,
                      children: widget.tabs!,
                    ),
                  ),
                ],
              )
                  : widget.child,
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }
}