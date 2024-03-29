import 'package:flutter/material.dart';
import 'package:chatify/constants/strings.dart';
import 'package:chatify/models/log.dart';
import 'package:chatify/resources/local_db/repository/log_repository.dart';
import 'package:chatify/screens/chatscreens/widgets/cached_image.dart';
import 'package:chatify/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:chatify/utils/utilities.dart';
import 'package:chatify/widgets/custom_tile.dart';

class LogListContainer extends StatefulWidget {
  @override
  _LogListContainerState createState() => _LogListContainerState();
}

class _LogListContainerState extends State<LogListContainer> {
  getIcon(String callStatus, double _iconSize) {
    Icon _icon;
    switch (callStatus) {
      case CALL_STATUS_DIALLED:
        _icon = Icon(
          Icons.call_made,
          size: _iconSize,
          color: Colors.green,
        );
        break;

      case CALL_STATUS_MISSED:
        _icon = Icon(
          Icons.call_missed,
          color: Colors.red,
          size: _iconSize,
        );
        break;

      default:
        _icon = Icon(
          Icons.call_received,
          size: _iconSize,
          color: Colors.grey,
        );
        break;
    }
    return Container(
      margin: EdgeInsets.only(right: 5),
      child: _icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: LogRepository.getLogs(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          final List<dynamic> logList = snapshot.data;
          if (logList.isNotEmpty) {
            return ListView.builder(
              itemCount: logList.length,
              itemBuilder: (context, i) {
                final Log _log = logList[i];
                final bool hasDialled = _log.callStatus == CALL_STATUS_DIALLED;
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                  child: CustomTile(
                    onTap: () => {},
                    leading: CachedImage(
                      hasDialled ? _log.receiverPic! : _log.callerPic!,
                      isRound: true,
                      radius: 45,
                      isTap: () {},
                    ),
                    mini: false,
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        title: Text(
                          Strings.deleteThisLog,
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                        content: Text(
                          Strings.confirmLogDeletion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        actions: [
                          TextButton(
                            child: Text(
                              Strings.yes,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              Navigator.maybePop(context);
                              await LogRepository.deleteLogs(i);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                          TextButton(
                            child: Text(
                              Strings.no,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0,
                                  color: Colors.black),
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                        hasDialled ? _log.receiverName! : _log.callerName!,
                        style: Theme.of(context).textTheme.bodyLarge),
                    icon: getIcon(_log.callStatus!, 15.0),
                    subtitle: Text(
                      Utils.formatDateString(_log.timestamp!),
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .backgroundColor,
                        fontSize: 13,
                      ),
                    ),
                    trailing: getIcon(_log.callStatus!, 30.0),
                  ),
                );
              },
            );
          }
          return QuietBox(
            heading: Strings.callLogsListHeading,
            subtitle: Strings.callsLogsListSubHeading,
          );
        }
        return QuietBox(
          heading: Strings.callLogsListHeading,
          subtitle: Strings.callsLogsListSubHeading,
        );
      },
    );
  }
}
