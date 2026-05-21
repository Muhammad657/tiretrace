import 'package:flutter/material.dart';
import 'package:tiretrace/fakeData.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Location> _filtered = [];
  bool _hasSearched = false;

  void _onSearch(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty;
      _filtered = query.isEmpty
          ? []
          : allLocations
              .where(
                  (loc) => loc.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 16, color: Color(0xFF4A7A9B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Plan a route',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE8F0F8))),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: const Color(0xFF1A2D45)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F1E30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2D45), width: 1),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child:
                        Icon(Icons.search, color: Color(0xFF4A7A9B), size: 18),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      onChanged: _onSearch,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFFE8F0F8)),
                      cursorColor: const Color(0xFF5BA3F5),
                      decoration: const InputDecoration(
                        hintText: 'Search a destination...',
                        hintStyle:
                            TextStyle(color: Color(0xFF4A7A9B), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      ),
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _controller.clear();
                        _onSearch('');
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.close,
                            color: Color(0xFF4A7A9B), size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (!_hasSearched)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Color(0xFF2B7FE0), size: 28),
                    SizedBox(height: 12),
                    Text('Type to search for a destination',
                        style:
                            TextStyle(fontSize: 13, color: Color(0xFF4A7A9B))),
                  ],
                ),
              ),
            )
          else if (_filtered.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No destinations found',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4A7A9B))),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 0,
                    thickness: 0.5,
                    color: Color(0xFF1A2D45),
                    indent: 16),
                itemBuilder: (context, index) {
                  final location = _filtered[index];
                  return _LocationTile(
                    location: location,
                    onTap: () => Navigator.pushNamed(context, '/impact',
                        arguments: location),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatefulWidget {
  final Location location;
  final VoidCallback onTap;
  const _LocationTile({required this.location, required this.onTap});
  @override
  State<_LocationTile> createState() => _LocationTileState();
}

class _LocationTileState extends State<_LocationTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? const Color(0xFF0F1E30) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF2B7FE0),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF2B7FE0).withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1)
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.location.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFE8F0F8))),
                  const SizedBox(height: 2),
                  Text(widget.location.subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A7A9B))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF1A2D45), size: 18),
          ],
        ),
      ),
    );
  }
}
