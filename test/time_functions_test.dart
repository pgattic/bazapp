import 'package:test/test.dart';
import 'package:bazapp/time_functions.dart';

void main() {
  group('TimeFunctions', () {
    test('getFormattedTime', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: '2:30 pm'
      expect(TimeFunctions.getFormattedTime(dateTime), '2:30 pm');
    });

    test('getFormattedDate', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: 'January 15'
      expect(TimeFunctions.getFormattedDate(dateTime), 'January 15');
    });

    test('getShortDate', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: 'Jan. 15'
      expect(TimeFunctions.getShortDate(dateTime), 'Jan. 15');
    });

    test('getFormattedDateWithYear', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: 'January 15 2024'
      expect(TimeFunctions.getFormattedDateWithYear(dateTime), 'January 15 2024');
    });

    test('yMMMMd', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: 'January 15 2024 at 2:30 pm'
      expect(TimeFunctions.yMMMMd(dateTime), 'January 15 2024 at 2:30 pm');
    });

    test('MMMMd', () {
      // Create a DateTime object for testing
      final dateTime = DateTime(2024, 1, 15, 14, 30);

      // Expected result: 'January 15 at 2:30 pm'
      expect(TimeFunctions.MMMMd(dateTime), 'January 15 at 2:30 pm');
    });

    test('getComfyDate', () {
      // Create a DateTime object for testing
      final dateTime = DateTime.now();

      // Test for Today, Yesterday, Tomorrow
      expect(TimeFunctions.getComfyDate(dateTime), 'Today');

      final yesterday = dateTime.subtract(Duration(days: 1));
      expect(TimeFunctions.getComfyDate(yesterday), 'Yesterday');

      final tomorrow = dateTime.add(Duration(days: 1));
      expect(TimeFunctions.getComfyDate(tomorrow), 'Tomorrow');

      // Test for general date
      final customDate = DateTime(2023, 1, 15, 14, 30);
      expect(TimeFunctions.getComfyDate(customDate), 'Jan. 15 2023');

      final sameYearDate = DateTime(DateTime.now().year, 1, 15, 14, 30);
      expect(TimeFunctions.getComfyDate(sameYearDate), 'Jan. 15');
    });

    test('getComfyDateTime', () {
      // Create a DateTime object for testing
      final dateTime = DateTime.now();

      // Expected result: 'Today at current time'
      expect(TimeFunctions.getComfyDateTime(dateTime), 'Today at ${TimeFunctions.getFormattedTime(dateTime)}');

      // Create a custom DateTime object for testing
      final customDateTime = DateTime(2023, 1, 15, 14, 30);

      // Expected result: 'Jan. 15 2023 at 2:30 pm'
      expect(TimeFunctions.getComfyDateTime(customDateTime), 'Jan. 15 2023 at 2:30 pm');

      // Test for the same year
      final sameYearDate = DateTime(DateTime.now().year, 1, 15, 14, 30);

      // Expected result: year omitted
      expect(TimeFunctions.getComfyDateTime(sameYearDate), 'Jan. 15 at 2:30 pm');
    });
  });
}
