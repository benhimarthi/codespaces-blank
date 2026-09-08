import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/notifications/data/data_source/notification.data.service.dart';
import 'package:myapp/features/notifications/data/models/app.notification.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/views/service_details_screen.dart';
// For NotificationHandler (handleRedirection)

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications_view';

  final NotificationDataService notificationService;

  const NotificationsScreen({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: StreamBuilder<List<AppNotification>>(
        stream: notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          final notifications = snapshot.data!;

          return BlocConsumer<ServiceCubit, ServiceState>(
            listener: (context, state) {
              if (state is ServiceLoaded) {
                print("#####################################66666666666666");
                Navigator.pushNamed(
                  context,
                  ServiceDetailsScreen.routeName,
                  arguments: state.service,
                );
              }
            },
            builder: (context, state) {
              return ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = notifications[index];

                  return ListTile(
                    title: Text(n.title),
                    subtitle: Text(n.body),
                    trailing: n.read
                        ? null
                        : const Icon(
                            Icons.circle,
                            color: Colors.blue,
                            size: 10,
                          ),
                    onTap: () {
                      // Mark notification as read
                      notificationService.markAsRead(n.id);

                      // Redirect if serviceId exists
                      if (n.serviceId != null) {
                        print(
                          "###########################################ddddd ${n.serviceId}",
                        );
                        context.read<ServiceCubit>().getServiceById(
                          n.serviceId!,
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
