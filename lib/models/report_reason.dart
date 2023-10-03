import 'package:car_pool_project/services/networking.dart';
import 'package:prefs/prefs.dart';

class ReportReason {
  int? id;
  String? type;
  String? reason;

  ReportReason({
    this.id,
    this.type,
    this.reason,
  });

  static Future<List<ReportReason>?> getReportReasons() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('jwt') ?? "";
    NetworkHelper networkHelper = NetworkHelper('report_reasons', {});
    List<ReportReason> reportReasons = [];
    var json = await networkHelper.getData(token);
    if (json != null && json['error'] == false) {
      for (Map t in json['report_reasons']) {
        ReportReason reportReason = ReportReason(
          id: t['id'],
          type: t['type'],
          reason: t['reason'],
        );
        reportReasons.add(reportReason);
      }
      return reportReasons;
    }
    return null;
  }
}
