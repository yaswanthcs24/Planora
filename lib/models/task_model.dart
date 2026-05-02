class Task {
  String  title;
  String  subject;
  String  priority;   // 'High' | 'Medium' | 'Low'
  double  hours;
  bool    isDone;
  DateTime? dueDate;

  Task({
    required this.title,
    required this.subject,
    required this.priority,
    required this.hours,
    this.isDone  = false,
    this.dueDate,
  });

  // For future JSON serialization with Node.js backend
  Map<String, dynamic> toJson() => {
    'title':    title,
    'subject':  subject,
    'priority': priority,
    'hours':    hours,
    'isDone':   isDone,
    'dueDate':  dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title:    json['title']    as String,
    subject:  json['subject']  as String,
    priority: json['priority'] as String,
    hours:    (json['hours'] as num).toDouble(),
    isDone:   json['isDone']  as bool,
    dueDate:  json['dueDate'] != null
                  ? DateTime.parse(json['dueDate'] as String)
                  : null,
  );
}

class Task {
  String? id;   // 🔥 ADD THIS

  String title;
  String subject;
  String priority;
  double hours;
  bool isDone;
  DateTime? dueDate;

  Task({
    this.id, // 🔥 ADD THIS
    required this.title,
    required this.subject,
    required this.priority,
    required this.hours,
    this.isDone = false,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'subject': subject,
    'priority': priority,
    'hours': hours,
    'isDone': isDone,
    'dueDate': dueDate?.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json, String id) => Task(
    id: id, // 🔥 IMPORTANT
    title: json['title'],
    subject: json['subject'],
    priority: json['priority'],
    hours: (json['hours'] as num).toDouble(),
    isDone: json['isDone'],
    dueDate: json['dueDate'] != null
        ? DateTime.parse(json['dueDate'])
        : null,
  );
}