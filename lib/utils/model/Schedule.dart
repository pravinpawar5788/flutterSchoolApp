class ClassRoutine {
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String period;

  ClassRoutine({required this.startTime, required this.endTime, required this.subject, required this.room,required this.period});

  factory ClassRoutine.fromJson(Map<String, dynamic> json) {
    return ClassRoutine(
        startTime: json['start_time'],
        endTime: json['end_time'],
        subject: json['subject_name'],
        room: json['room_no'],
        period: json['period'],
    );
  }
}
