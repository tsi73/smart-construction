class ProjectMember {
  final String id;
  final String projectId;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;

  ProjectMember({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
  });
}

class ProjectInvitation {
  final String id;
  final String projectId;
  final String email;
  final String role;
  final String token;
  final String status;

  ProjectInvitation({
    required this.id,
    required this.projectId,
    required this.email,
    required this.role,
    required this.token,
    required this.status,
  });
}
