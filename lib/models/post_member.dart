import 'dart:convert';
import 'package:car_pool_project/models/user.dart';
import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class PostMember {
  int? id;
  int? postID;
  int? userID;
  User? user;

  PostMember({
    this.id,
    this.postID,
    this.userID,
    this.user,
  });

  static Future<List<PostMember>?> getPostMembers() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('post_members', {});
    List<PostMember> postMembers = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['postMembers']) {
        PostMember postMember = PostMember(
          id: t['id'],
          postID: t['post_id'],
          userID: t['user_id'],
        );
        postMembers.add(postMember);
      }
      return postMembers;
    }
    return null;
  }

  static Future<List<PostMember>?> getPostMembersForCheckJoin(
    int postID,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper("post_members/get_check_join", {
      "post_id": postID.toString(),
    });
    List<PostMember> postMembers = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['post_members']) {
        PostMember postMember = PostMember(
          id: t['id'],
          postID: t['post_id'],
          userID: t['user_id'],
        );
        postMembers.add(postMember);
      }
      return postMembers;
    }
    return null;
  }

  static Future<PostMember?> joinPost(int postID) async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper("post_members/join_post", {});
    var json = await networkHelper.postData(
      jsonEncode(<String, dynamic>{
        "post_id": postID,
      }),
      token,
    );
    if (json != null && json['error'] == false) {
      Map t = json['post_members'];
      PostMember postMember = PostMember(
        id: t['id'],
        postID: t['post_id'],
        userID: t['user_id'],
      );
      return postMember;
    }
    return null;
  }
}
