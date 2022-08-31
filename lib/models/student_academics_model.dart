class StudentAcademicsModel {
  final double cgpa;

  StudentAcademicsModel({
    required this.cgpa,
  });

  // Implement toString to make it easier to see information
  // when using the print statement.
  @override
  String toString() {
    return 'StudentAcademicsModel{cgpa: $cgpa}';
  }
}
