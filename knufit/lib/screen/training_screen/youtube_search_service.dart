import 'dart:convert';
import 'package:http/http.dart' as http;

class YoutubeSearchService {
  final String apiKey = 'AIzaSyAIJ81HGPPKpflKf8SX_fsn9BdG7nPgTuY'; // 유튜브 API 키

  Future<List<YoutubeVideo>> fetchYoutubeVideos(String query) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=5&q=$query&type=video&key=$apiKey');
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List videos = data['items'];
      return videos.map((video) => YoutubeVideo.fromJson(video)).toList();
    } else {
      throw Exception('영상 불러오기에 실패했습니다');
    }
  }
}

class YoutubeVideo {
  final String title;
  final String thumbnailUrl;
  final String videoUrl;

  YoutubeVideo({required this.title, required this.thumbnailUrl, required this.videoUrl});

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    final videoId = json['id']['videoId'];
    final title = json['snippet']['title'];
    final thumbnailUrl = json['snippet']['thumbnails']['high']['url'];

    return YoutubeVideo(
      title: title,
      thumbnailUrl: thumbnailUrl,
      videoUrl: 'https://www.youtube.com/watch?v=$videoId',
    );
  }
}
