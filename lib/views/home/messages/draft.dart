import 'package:Tether/global/widgets/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'package:Tether/domain/index.dart';

enum DraftOptions { newGroup, markAllRead, inviteFriends, settings, help }

class Draft extends StatelessWidget {
  Draft({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w100)),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text('TE'),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              tooltip: 'Profile',
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              print('SEARCH STUB');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              print('SEARCH STUB');
            },
            tooltip: 'Search Messages',
          ),
          RoundedPopupMenu<DraftOptions>(
            onSelected: (DraftOptions result) {
              switch (result) {
                case DraftOptions.settings:
                  Navigator.pushNamed(context, '/settings');
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<DraftOptions>>[
              const PopupMenuItem<DraftOptions>(
                value: DraftOptions.newGroup,
                child: Text('New Group'),
              ),
              const PopupMenuItem<DraftOptions>(
                value: DraftOptions.markAllRead,
                child: Text('Mark All Read'),
              ),
              const PopupMenuItem<DraftOptions>(
                value: DraftOptions.inviteFriends,
                child: Text('Invite Friends'),
              ),
              const PopupMenuItem<DraftOptions>(
                value: DraftOptions.settings,
                child: Text('Settings'),
              ),
              const PopupMenuItem<DraftOptions>(
                value: DraftOptions.help,
                child: Text('Help'),
              ),
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            StoreConnector<AppState, int>(
              converter: (Store<AppState> store) => 0,
              builder: (context, count) {
                return Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.display1,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
