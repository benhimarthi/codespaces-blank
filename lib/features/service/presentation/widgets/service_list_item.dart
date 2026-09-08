import 'package:flutter/material.dart';
import 'package:myapp/features/auth/presentation/providers/user_provider.dart';
import 'package:myapp/features/imageService/presentation/image.carousel.dart';
import 'package:myapp/features/service/domain/entities/service.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/views/edit_service_screen.dart';
import 'package:myapp/features/service/presentation/views/service_details_screen.dart';
import 'package:provider/provider.dart';

class ServiceListItem extends StatefulWidget {
  const ServiceListItem({super.key, required this.service});

  final Service service;

  @override
  State<ServiceListItem> createState() => _ServiceListItemState();
}

class _ServiceListItemState extends State<ServiceListItem> {
  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool isAdmin = userProvider.user?.userType == 'Admin';
        return GestureDetector(
          onTap: () {
            context.read<ServiceCubit>().init();
            Navigator.of(context).pushNamed(
              ServiceDetailsScreen.routeName,
              arguments: widget.service,
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            if (widget.service.subVersion.label.toLowerCase() ==
                                'premium')
                              ImageCarousel(
                                height: 120,
                                imageUrls: widget.service.imageUrls,
                              ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.service.town.label,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        //color: Colors.green,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 120,

                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.service.category.label,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (isAdmin)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.pushNamed(
                                      context,
                                      EditServiceScreen.routeName,
                                      arguments: widget.service,
                                    );
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete Service'),
                                        content: const Text(
                                          'Are you sure you want to delete this service?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              context
                                                  .read<ServiceCubit>()
                                                  .deleteService(
                                                    widget.service.id,
                                                  );
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                      const PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(widget.service.phoneNumber),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(widget.service.email),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
