import '../models/grade.dart';
import '../models/subject.dart';

class StudentInfo {
  static const String fullName = 'Иванов Пётр';
  static const String role = 'Студент';
  static const String group = 'Группа CS-401';
  static const String initials = 'ИП';
  static const String term = 'Осенний семестр 2024';
}

DateTime _d(int y, int m, int day) => DateTime(y, m, day);

List<Subject> buildSubjects() => [
      Subject(
        id: 'algo',
        name: 'Алгоритмы и структуры данных',
        teacher: 'Проф. Смирнов А.В.',
        semester: 7,
        finalGrade: 5.0,
        status: SubjectStatus.passed,
        summary: const [
          (label: 'Экзамен', value: '95'),
          (label: 'Лаб. 1–5', value: '92'),
          (label: 'Проект', value: '98'),
        ],
        grades: [
          Grade(title: 'Экзамен', score: 95, date: _d(2024, 12, 20)),
          Grade(title: 'Лабораторная работа 1', score: 90, date: _d(2024, 9, 16)),
          Grade(title: 'Лабораторная работа 2', score: 93, date: _d(2024, 10, 1)),
          Grade(title: 'Лабораторная работа 3', score: 91, date: _d(2024, 10, 18)),
          Grade(title: 'Лабораторная работа 4', score: 94, date: _d(2024, 11, 5)),
          Grade(title: 'Лабораторная работа 5', score: 92, date: _d(2024, 11, 22)),
          Grade(title: 'Курсовой проект', score: 98, date: _d(2024, 12, 12)),
        ],
      ),
      Subject(
        id: 'db',
        name: 'Базы данных',
        teacher: 'Доц. Петрова Е.И.',
        semester: 7,
        finalGrade: 4.8,
        status: SubjectStatus.passed,
        isFavorite: true,
        summary: const [
          (label: 'Экзамен', value: '88'),
          (label: 'Лаб. 1–4', value: '90'),
          (label: 'Курсовая', value: '95'),
        ],
        grades: [
          Grade(title: 'Экзамен', score: 88, date: _d(2024, 12, 18)),
          Grade(title: 'Лабораторная работа 1', score: 87, date: _d(2024, 9, 22)),
          Grade(title: 'Лабораторная работа 2', score: 89, date: _d(2024, 10, 8)),
          Grade(title: 'Лабораторная работа 3', score: 92, date: _d(2024, 10, 22)),
          Grade(title: 'Лабораторная работа 4', score: 91, date: _d(2024, 11, 12)),
          Grade(title: 'Курсовая работа', score: 95, date: _d(2024, 12, 5)),
        ],
      ),
      Subject(
        id: 'web',
        name: 'Веб-разработка',
        teacher: 'Проф. Козлов М.С.',
        semester: 7,
        finalGrade: 4.5,
        status: SubjectStatus.passed,
        summary: const [
          (label: 'Тест', value: '82'),
          (label: 'Лаб. 1–6', value: '87'),
          (label: 'Проект', value: '90'),
        ],
        grades: [
          Grade(title: 'Тестирование', score: 82, date: _d(2024, 12, 20)),
          Grade(title: 'Лабораторная работа 1', score: 84, date: _d(2024, 9, 18)),
          Grade(title: 'Лабораторная работа 2', score: 85, date: _d(2024, 10, 2)),
          Grade(title: 'Лабораторная работа 3', score: 88, date: _d(2024, 10, 18)),
          Grade(title: 'Лабораторная работа 4', score: 86, date: _d(2024, 11, 1)),
          Grade(title: 'Лабораторная работа 5', score: 89, date: _d(2024, 11, 15)),
          Grade(title: 'Лабораторная работа 6', score: 90, date: _d(2024, 11, 29)),
          Grade(title: 'Итоговый проект', score: 90, date: _d(2024, 12, 14)),
        ],
      ),
      Subject(
        id: 'ml',
        name: 'Машинное обучение',
        teacher: 'Доц. Волкова О.П.',
        semester: 7,
        finalGrade: 4.2,
        status: SubjectStatus.passed,
        isFavorite: true,
        summary: const [
          (label: 'Экзамен', value: '78'),
          (label: 'Лаб. 1–4', value: '85'),
          (label: 'Проект', value: '88'),
        ],
        grades: [
          Grade(title: 'Экзамен', score: 78, date: _d(2024, 12, 19)),
          Grade(title: 'Лабораторная работа 1', score: 83, date: _d(2024, 9, 25)),
          Grade(title: 'Лабораторная работа 2', score: 85, date: _d(2024, 10, 12)),
          Grade(title: 'Лабораторная работа 3', score: 86, date: _d(2024, 10, 30)),
          Grade(title: 'Лабораторная работа 4', score: 87, date: _d(2024, 11, 18)),
          Grade(title: 'Проект', score: 88, date: _d(2024, 12, 9)),
        ],
      ),
      Subject(
        id: 'net',
        name: 'Сети и безопасность',
        teacher: 'Проф. Иванов Д.А.',
        semester: 7,
        finalGrade: 4.0,
        status: SubjectStatus.passed,
        summary: const [
          (label: 'Экзамен', value: '75'),
          (label: 'Лаб. 1–5', value: '80'),
          (label: 'Тест', value: '82'),
        ],
        grades: [
          Grade(title: 'Экзамен', score: 75, date: _d(2024, 12, 17)),
          Grade(title: 'Тестирование', score: 82, date: _d(2024, 12, 3)),
          Grade(title: 'Лабораторная работа 1', score: 78, date: _d(2024, 9, 20)),
          Grade(title: 'Лабораторная работа 2', score: 80, date: _d(2024, 10, 5)),
          Grade(title: 'Лабораторная работа 3', score: 81, date: _d(2024, 10, 21)),
          Grade(title: 'Лабораторная работа 4', score: 79, date: _d(2024, 11, 7)),
          Grade(title: 'Лабораторная работа 5', score: 82, date: _d(2024, 11, 24)),
        ],
      ),
      Subject(
        id: 'mobile',
        name: 'Мобильная разработка',
        teacher: 'Доц. Соколова Н.В.',
        semester: 7,
        finalGrade: 3.8,
        status: SubjectStatus.inProgress,
        summary: const [
          (label: 'Тест', value: '70'),
          (label: 'Лаб. 1–3', value: '75'),
          (label: 'Проект', value: '—'),
        ],
        grades: [
          Grade(title: 'Тестирование', score: 70, date: _d(2024, 12, 4)),
          Grade(title: 'Лабораторная работа 1', score: 73, date: _d(2024, 9, 28)),
          Grade(title: 'Лабораторная работа 2', score: 75, date: _d(2024, 10, 15)),
          Grade(title: 'Лабораторная работа 3', score: 77, date: _d(2024, 11, 2)),
          const Grade(title: 'Итоговый проект'),
        ],
      ),
    ];
