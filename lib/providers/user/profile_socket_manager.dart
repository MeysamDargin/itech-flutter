import 'package:flutter/material.dart';
import 'package:itech/service/ws/profile_web_sockets.dart';

class ProfileSocketManager extends ChangeNotifier {
  final ProfileSocketService _profileSocketService = ProfileSocketService();
  final UserSocketService _userSocketService = UserSocketService();

  // User data
  String _userName = '...';
  int _id = 0;
  String _emailName = '...';
  String _first_name = '...';
  String _last_name = '...';
  String _groups = '...';
  String _job_title = '...';
  String _phone_number = '...';
  String _country = '...';
  String _website = '...';
  String _city_state = '...';
  String _bio = '...';
  String? _profile_picture;
  String? _profile_caver;
  String _membershipStatus = '';
  int _article_count = 0;
  int _follower_count = 0;
  int _following_count = 0;

  // Getters
  String get userName => _userName;
  int get id => _id;
  String get emailName => _emailName;
  String get first_name => _first_name;
  String get last_name => _last_name;
  String get groups => _groups;
  String get job_title => _job_title;
  String get phone_number => _phone_number;
  String get country => _country;
  String get website => _website;
  String get city_state => _city_state;
  String get bio => _bio;
  String? get profile_picture => _profile_picture;
  String? get profile_caver => _profile_caver;
  String get membershipStatus => _membershipStatus;
  int get article_count => _article_count;
  int get follower_count => _follower_count;
  int get following_count => _following_count;

  ProfileSocketManager() {
    _initWebSocket();
  }

  void _initWebSocket() {
    _profileSocketService.connectToWebSocket((data) {
      if (data['action'] == 'updated') {
        _first_name = data['first_name'] ?? '...';
        _article_count = data['article_count'] ?? 0;
        _follower_count = data['follower_count'] ?? 0;
        _following_count = data['following_count'] ?? 0;
        _country = data['country'] ?? '...';
        _bio = data['bio'] ?? '...';
        _city_state = data['city_state'] ?? '...';
        _job_title = data['job_title'] ?? '...';
        _website = data['website'] ?? '...';
        _last_name = data['last_name'] ?? '...';
        _groups = data['groups'] ?? '--';
        _phone_number = data['phone_number'] ?? '...';
        _profile_picture = data['profile_picture'];
        _profile_caver = data['profile_caver'];
        notifyListeners();
      } else if (data['action'] == 'follow_update') {
        if (data['user_id'] == _id) {
          _follower_count = data['follower_count'] ?? _follower_count;
          _following_count = data['following_count'] ?? _following_count;
          notifyListeners();
        }
      } else if (data['action'] == 'article_update') {
        if (data['user_id'] == _id) {
          _article_count = data['article_count'] ?? _article_count;
          notifyListeners();
        }
      }
    });

    _userSocketService.connectToWebSocket((data) {
      if (data['action'] == 'updated') {
        _id = data['id'] ?? 0;
        _userName = data['username'] ?? '...';
        _emailName = data['email'] ?? '...';
        _groups = '${data['groups'] ?? "--"}';
        _membershipStatus = _groups.contains("Premium") ? '1' : '0';
        notifyListeners();
      }
    });
  }

  void sendProfileData(Map<String, dynamic> data) {
    _profileSocketService.sendMessage(data);
  }

  void sendUserData(Map<String, dynamic> data) {
    _userSocketService.sendMessage(data);
  }

  void closeConnections() {
    _profileSocketService.closeConnection();
    _userSocketService.closeConnection();
  }

  void resetState() {
    _userName = '...';
    _id = 0;
    _emailName = '...';
    _first_name = '...';
    _last_name = '...';
    _groups = '...';
    _job_title = '...';
    _phone_number = '...';
    _country = '...';
    _website = '...';
    _city_state = '...';
    _bio = '...';
    _profile_picture = null;
    _profile_caver = null;
    _membershipStatus = '';
    _article_count = 0;
    _follower_count = 0;
    _following_count = 0;
    notifyListeners();
  }

  Future<void> reconnectWebSockets() async {
    closeConnections();
    resetState();
    _initWebSocket();
  }
}
