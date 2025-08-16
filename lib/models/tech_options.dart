class TechOptions {
  static const List<String> programmingLanguages = [
    'JavaScript',
    'TypeScript',
    'Python',
    'Java',
    'Go',
    'Rust',
    'Swift',
    'Kotlin',
    'C#',
    'PHP',
    'Ruby',
    'Scala',
    'Dart',
    'C++',
    'C',
    'R',
    'MATLAB',
    'Perl',
    'Haskell',
    'Elixir',
  ];

  static const List<String> frameworks = [
    'React',
    'Vue.js',
    'Angular',
    'Flutter',
    'Django',
    'Spring Boot',
    'Express.js',
    'Laravel',
    'Ruby on Rails',
    'ASP.NET',
    'FastAPI',
    'Gin',
    'Echo',
    'Fiber',
    'Actix',
    'Rocket',
    'Phoenix',
    'Play Framework',
    'ASP.NET Core',
    'Blazor',
  ];

  static const List<String> specialties = [
    'Web Development',
    'Mobile App Development',
    'AI/ML',
    'DevOps',
    'Data Science',
    'Backend Development',
    'Frontend Development',
    'Full Stack Development',
    'Cloud Computing',
    'Cybersecurity',
    'Game Development',
    'IoT Development',
    'Blockchain Development',
    'Embedded Systems',
    'System Administration',
    'Database Administration',
    'Network Engineering',
    'UI/UX Design',
    'Quality Assurance',
    'Project Management',
  ];

  static List<String> getFilteredLanguages(String query) {
    if (query.isEmpty) return programmingLanguages;
    return programmingLanguages
        .where((language) =>
            language.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<String> getFilteredFrameworks(String query) {
    if (query.isEmpty) return frameworks;
    return frameworks
        .where((framework) =>
            framework.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<String> getFilteredSpecialties(String query) {
    if (query.isEmpty) return specialties;
    return specialties
        .where((specialty) =>
            specialty.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
} 