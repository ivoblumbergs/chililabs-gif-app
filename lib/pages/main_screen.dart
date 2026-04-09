import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_app/providers/search_provider.dart';
import 'package:gif_app/providers/gif_provider.dart';
import 'dart:async';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 200) {
        final query = ref.read(searchQueryProvider);
        ref.read(gifProvider.notifier).loadMore(query);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final orientation = MediaQuery.of(context).orientation;
    final gifsAsync = ref.watch(gifProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF4f5d75),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2d3142),
        title: TextField(
          controller: _searchController,
          cursorColor: Colors.deepOrange,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search GIFs...',
            hintStyle: const TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(gifProvider.notifier).search('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 500), () {
              ref.read(searchQueryProvider.notifier).state = value;
              ref.read(gifProvider.notifier).search(value);
            });
          },
        ),
      ),
      body: gifsAsync.errorMessage != null
          ? Center(
              child: Text(
                gifsAsync.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : gifsAsync.gifs.isEmpty && searchQuery.isNotEmpty
              ? const Center(
                  child: Text(
                    'No GIFs were found. Try a different search.',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: gifsAsync.isLoadingMore
                      ? gifsAsync.gifs.length + 1
                      : gifsAsync.gifs.length,
                  itemBuilder: (context, index) {
                    if (index == gifsAsync.gifs.length) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Colors.deepOrange),
                      );
                    }
                    return GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        final gif = gifsAsync.gifs[index];
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: const Color(0xFF2d3142),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(gif.url),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '${gif.width} x ${gif.height}px  •  ${(int.parse(gif.size) / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepOrange,
                                      ),
                                      icon: const Icon(Icons.share,
                                          color: Colors.white),
                                      label: const Text('Share',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      onPressed: () {},
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).then((_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        });
                      },
                      child: Image.network(
                        gifsAsync.gifs[index].url,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Colors.deepOrange),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
