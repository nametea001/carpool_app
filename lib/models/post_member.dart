import 'dart:convert';
import 'package:car_pool_project/services/networking.dart';

class PostMember {
  int? id;
  int? postID;
  int? userID;

  PostMember({
    this.id,
    this.postID,
    this.userID,
  });

  static Future<List<PostMember>?> getPostMembers(
    String token,
  ) async {
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
    String token,
    int postID,
  ) async {
    NetworkHelper networkHelper = NetworkHelper("post_members/get_check_join", {
      "post_id": postID.toString(),
    });
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
}
