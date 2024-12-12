// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:stream_chat_flutter/src/poll/interactor/stream_poll_interactor.dart';
import 'package:stream_chat_flutter/src/stream_chat_configuration.dart';
import 'package:stream_chat_flutter/src/theme/stream_chat_theme.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  final currentUser = User(id: 'curr-user', name: 'Current User');

  final latestVotesByOption = {
    'option-1': [
      for (var i = 0; i < 3; i++)
        PollVote(
          userId: 'user-$i',
          user: User(id: 'user-$i', name: 'User $i'),
          optionId: 'option-1',
          createdAt: DateTime.now(),
        ),
    ],
    'option-2': [
      for (var i = 0; i < 2; i++)
        PollVote(
          userId: 'user-$i',
          user: User(id: 'user-$i', name: 'User $i'),
          optionId: 'option-2',
          createdAt: DateTime.now(),
        ),
    ],
    'option-3': [
      PollVote(
        user: currentUser,
        userId: currentUser.id,
        optionId: 'option-3',
        createdAt: DateTime.now(),
      ),
    ],
  };

  final voteCountsByOption = latestVotesByOption.map(
    (key, value) => MapEntry(key, value.length),
  );

  final latestAnswers = [
    PollVote(
      user: currentUser,
      userId: currentUser.id,
      answerText: 'I also like yellow',
      createdAt: DateTime.now(),
    ),
  ];

  final poll = Poll(
    id: 'poll-1',
    name: 'What is your favorite color?',
    createdBy: currentUser,
    allowUserSuggestedOptions: true,
    options: const [
      PollOption(id: 'option-1', text: 'Red'),
      PollOption(id: 'option-2', text: 'Blue'),
      PollOption(id: 'option-3', text: 'Green'),
    ],
    voteCount: voteCountsByOption.values.reduce((a, b) => a + b),
    voteCountsByOption: voteCountsByOption,
    latestVotesByOption: latestVotesByOption,
    allowAnswers: true,
    answersCount: latestAnswers.length,
    latestAnswers: latestAnswers,
    ownVotesAndAnswers: [
      ...latestAnswers,
      ...latestVotesByOption.values.expand((it) => it),
    ].where((it) => it.userId == currentUser.id).toList(),
  );

  for (final brightness in Brightness.values) {
    testGoldens(
      '[${brightness.name}] -> StreamPollInteractor should look fine',
      (tester) async {
        await tester.pumpWidgetBuilder(
          StreamPollInteractor(
            poll: poll,
            currentUser: currentUser,
          ),
          surfaceSize: const Size(412, 500),
          wrapper: (child) => _wrapWithMaterialApp(
            child,
            brightness: brightness,
          ),
        );

        await screenMatchesGolden(
          tester,
          'stream_poll_interactor_${brightness.name}',
        );
      },
    );

    testGoldens(
      '[${brightness.name}] -> StreamPollInteractor with closed poll should look fine',
      (tester) async {
        await tester.pumpWidgetBuilder(
          StreamPollInteractor(
            poll: poll.copyWith(
              isClosed: true,
            ),
            currentUser: currentUser,
          ),
          surfaceSize: const Size(412, 400),
          wrapper: (child) => _wrapWithMaterialApp(
            child,
            brightness: brightness,
          ),
        );

        await screenMatchesGolden(
          tester,
          'stream_poll_interactor_poll_closed_${brightness.name}',
        );
      },
    );
  }
}

Widget _wrapWithMaterialApp(
  Widget widget, {
  Brightness? brightness,
}) {
  return MaterialApp(
    home: StreamChatConfiguration(
      data: StreamChatConfigurationData(),
      child: StreamChatTheme(
        data: StreamChatThemeData(brightness: brightness),
        child: Builder(builder: (context) {
          final theme = StreamChatTheme.of(context);
          return Scaffold(
            backgroundColor: theme.colorTheme.appBg,
            body: Center(child: widget),
          );
        }),
      ),
    ),
  );
}
