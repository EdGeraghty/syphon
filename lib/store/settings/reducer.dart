import 'package:Tether/store/settings/chat-settings/actions.dart';
import 'package:Tether/store/settings/chat-settings/model.dart';

import './model.dart';
import './actions.dart';

SettingsStore settingsReducer(
    [SettingsStore state = const SettingsStore(), dynamic action]) {
  switch (action.runtimeType) {
    case SetPrimaryColor:
      return state.copyWith(
        primaryColor: action.color,
      );
    case SetRoomPrimaryColor:
      final chatSettings =
          Map<String, ChatSetting>.from(state.customChatSettings ?? Map());

      // Initialize chat settings if null
      if (chatSettings[action.roomId] == null) {
        chatSettings[action.roomId] = ChatSetting();
      }

      chatSettings[action.roomId] = chatSettings[action.roomId].copyWith(
        primaryColor: action.color,
      );
      return state.copyWith(
        customChatSettings: chatSettings,
      );
    case SetAccentColor:
      return state.copyWith(
        accentColor: action.color,
      );
    case SetLanguage:
      return state.copyWith(
        language: action.language,
      );
    case SetTheme:
      return state.copyWith(
        theme: action.theme,
      );
    case SetEnterSend:
      return state.copyWith(
        enterSend: action.enterSend,
      );
    case ToggleTypingIndicators:
      return state.copyWith(
        typingIndicators: !state.typingIndicators,
      );
    case ToggleReadReceipts:
      return state.copyWith(
        readReceipts: !state.readReceipts,
      );
    case ToggleMembershipEvents:
      return state.copyWith(
        membershipEventsEnabled: !state.membershipEventsEnabled,
      );
    case ToggleNotifications:
      return state.copyWith(
        notificationsEnabled: !state.notificationsEnabled,
      );
    default:
      return state;
  }
}