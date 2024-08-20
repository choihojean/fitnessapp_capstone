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
          return SizedBox(
            height: 140, // 영상 카드의 고정 높이 설정
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 가로 스크롤로 변경
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final video = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    // 사용자가 비디오를 클릭할 때 유튜브 URL을 여는 코드 실행
                    _launchURL(video.videoUrl);
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 8.0), // 카드 간격 설정
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          video.thumbnailUrl,
                          width: 160, // 이미지 너비 조정
                          height: 90, // 이미지 높이 조정
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 4),
                        Container(
                          width: 160, // 텍스트와 이미지의 너비를 동일하게 설정
                          child: Text(
                            video.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
