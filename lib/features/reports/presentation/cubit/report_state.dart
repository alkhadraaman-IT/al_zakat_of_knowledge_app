import 'package:equatable/equatable.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportSubmitting extends ReportState {
  const ReportSubmitting();
}

class ReportSuccess extends ReportState {
  const ReportSuccess();
}

class ReportError extends ReportState {
  final String message;
  final String? code;

  const ReportError({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}