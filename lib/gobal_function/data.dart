class GlobalData {
  String googleApiKey() {
    return "AIzaSyCQ9A6QV8C8JRZvRFhfnSxp-pdSqh4vUKw";
  }

  String getMonth(int month) {
    List months = [
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค.",
    ];
    return months[month];
  }

  String getDay(String day) {
    String data = "";
    if (day == "Sun") {
      data = "อา.";
    } else if (day == "Mon") {
      data = "จ.";
    } else if (day == "Tue") {
      data = "อ.";
    } else if (day == "Wed") {
      data = "พ.";
    } else if (day == "Thu") {
      data = "พฤ.";
    } else if (day == "Fri") {
      data = "ศ.";
    } else if (day == "Sat") {
      data = "ส.";
    }
    return data;
  }
}
