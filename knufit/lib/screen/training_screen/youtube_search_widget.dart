import 'package:flutter/material.dart';
import 'youtube_search_service.dart';
import 'package:url_launcher/url_launcher.dart';

class YoutubeSearchWidget extends StatefulWidget {
  final String searchQuery;

  YoutubeSearchWidget({required this.searchQuery});

  @override
  _YoutubeSearchWidgetState createState() => _YoutubeSearchWidgetState();
}

class _YoutubeSearchWidgetState extends State<YoutubeSearchWidget> {
  late Future<List<YoutubeVideo>> youtubeVideos;

  @override
  void initState() {
    super.initState();
    youtubeVideos = YoutubeSearchService().fetchYoutubeVideos(widget.searchQuery);
  }

  // URL을 여는 함수
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // 외부 브라우저에서 열기
    )) {
      throw '$url 을 열 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<YoutubeVideo>>(
      future: youtubeVideos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('관련 유튜브 영상을 찾을 수 없습니다.'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final video = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  // 사용자가 비디오를 클릭할 때 유튜브 URL을 여는 코드 실행
                  _launchURL(video.videoUrl);
                },
                child: Card(
                  child: Row(
                    children: [
                      Image.network(
                        video.thumbnailUrl,
                        width: 120,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          video.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
