class ReservationManager {
  String _employeeCode = '';
  bool _verifyEmployeeCode = false;
  DateTime _selectedDate = DateTime.now();
  bool _verifySelectedDate = false;
  String _employeeDesk = 'NOT';
  bool _verifyEmployeeDesk = false;
  String _employeeName = '';

  String get employeeCode => _employeeCode;

  set employeeCode(String value) {
    _employeeCode = value;
  }

  bool get verifyEmployeeCode => _verifyEmployeeCode;

  set verifyEmployeeCode(bool value) {
    _verifyEmployeeCode = value;
  }

  DateTime get selectedDate => _selectedDate;

  set selectedDate(DateTime value) {
    _selectedDate = value;
  }

  bool get verifySelectedDate => _verifySelectedDate;

  set verifySelectedDate(bool value) {
    _verifySelectedDate = value;
  }

  String get employeeDesk => _employeeDesk;

  set employeeDesk(String value) {
    _employeeDesk = value;
  }

  bool get verifyEmployeeDesk => _verifyEmployeeDesk;

  set verifyEmployeeDesk(bool value) {
    _verifyEmployeeDesk = value;
  }

  String get employeeName => _employeeName;

  set employeeName(String value) {
    _employeeName = value;
  }

  @override
  String toString() {
    return 'YourClass{_employeeCode: $_employeeCode, '
        '_verifyEmployeeCode: $_verifyEmployeeCode, '
        '_selectedDate: $_selectedDate, '
        '_verifySelectedDate: $_verifySelectedDate, '
        '_employeeDesk: $_employeeDesk, '
        '_verifyEmployeeDesk: $_verifyEmployeeDesk, '
        '_employeeName: $_employeeName}';
  }
}
