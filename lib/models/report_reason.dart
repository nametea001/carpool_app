import 'package:car_pool_project/services/networking.dart';

class ReportReason {
  int? id;
  String? type;
  String? reason;

  ReportReason({
    this.id,
    this.type,
    this.reason,
  });

  static Future<List<ReportReason>?> getReportReasons(
    String token,
  ) async {
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
