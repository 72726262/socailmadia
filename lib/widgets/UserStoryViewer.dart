import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:soso/model/selectestoryModale.dart';

class UserStoryViewer extends StatefulWidget {
  final List<Story> stories;

  const UserStoryViewer({required this.stories, super.key});

  @override
  State<UserStoryViewer> createState() => _UserStoryViewerState();
}

class _UserStoryViewerState extends State<UserStoryViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _progressController;

  VideoPlayerController? _videoController;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _loadStoryMedia();
  }

  void _loadStoryMedia() {
    _videoController?.dispose();
    _progressController.duration = const Duration(seconds: 5);
    _startProgress();
  }

  void _startProgress() {
    _progressController.forward(from: 0);
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) _nextStory();
    });
  }

  void _nextStory() {
    if (_currentIndex < widget.stories.length - 1) {
      setState(() => _currentIndex++);
      _loadStoryMedia();
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _loadStoryMedia();
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  String formatTime(DateTime createdAt, bool isRTL) {
    final diff = DateTime.now().difference(createdAt);

    // Less than 1 minute
    if (diff.inMinutes < 1) {
      return isRTL ? "الآن" : "Just now";
    }

    // Minutes
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      if (isRTL) {
        return "منذ $m دقيقة";
      } else {
        return "$m min ago";
      }
    }

    // Hours
    if (diff.inHours < 24) {
      final h = diff.inHours;
      if (isRTL) {
        return "منذ $h ساعة";
      } else {
        return "$h hours ago";
      }
    }

    // More than 1 day → show exact time (AM/PM)
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');

    if (isRTL) {
      final period = hour >= 12 ? 'م' : 'ص';
      final h = hour > 12
          ? hour - 12
          : hour == 0
          ? 12
          : hour;
      return "$h:$minute $period";
    } else {
      final period = hour >= 12 ? 'PM' : 'AM';
      final h = hour > 12
          ? hour - 12
          : hour == 0
          ? 12
          : hour;
      return "$h:$minute $period";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("No stories", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final currentStory = widget.stories[_currentIndex];
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) Navigator.pop(context);
        },

        onLongPressStart: (_) {
          setState(() {
            isPaused = true;
            _progressController.stop();
            _videoController?.pause();
          });
        },
        onLongPressEnd: (_) {
          setState(() {
            isPaused = false;
            _progressController.forward();
            _videoController?.play();
          });
        },

        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return AnimatedOpacity(
                  opacity: index == _currentIndex ? 1 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Image.network(story.imageUrl, fit: BoxFit.cover),
                );
              },
            ),

            // Progress bars
            Positioned(
              top: 35,
              left: 10,
              right: 10,
              child: Row(
                children: widget.stories.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          double value = index < _currentIndex
                              ? 1
                              : index == _currentIndex
                              ? _progressController.value
                              : 0;
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white30,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 4,
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // User info + time
            Positioned(
              top: 55,
              left: isRTL ? null : 15,
              right: isRTL ? 15 : null,
              child: Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(currentStory.userImage),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStory.userName,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        formatTime(currentStory.createdAt, isRTL),
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 50,
              left: isRTL ? 20 : null,
              right: isRTL ? null : 20,
              child: IconButton(
                icon: Icon(Icons.close, size: 30, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Right arrow
            Positioned(
              right: isRTL ? null : 10,
              left: isRTL ? 10 : null,
              top: MediaQuery.of(context).size.height * 0.45,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: _nextStory,
              ),
            ),

            // Left arrow
            Positioned(
              left: isRTL ? null : 10,
              right: isRTL ? 10 : null,
              top: MediaQuery.of(context).size.height * 0.45,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 35, color: Colors.white),
                onPressed: _previousStory,
              ),
            ),

            // Reactions bar
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  reaction("😍"),
                  reaction("🔥"),
                  reaction("❤️"),
                  reaction("😂"),
                  reaction("😮"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reaction(String emoji) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Reaction: $emoji")));
      },
      child: Text(emoji, style: TextStyle(fontSize: 32)),
    );
  }
}
