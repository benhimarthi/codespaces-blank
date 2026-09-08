import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:myapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myapp/features/auth/presentation/providers/user_provider.dart';
import 'package:myapp/features/home/presentation/views/home_screen.dart';
import 'package:myapp/features/imageService/presentation/image.carousel.dart';
import 'package:myapp/features/service/domain/entities/review.dart';
import 'package:myapp/features/service/domain/entities/service.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/serviceMetadata/presentation/pages/service_metadata_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'services_screen.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({super.key, required this.service});

  static const routeName = '/service-details';
  final Service service;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  late List<Review> myReviews = [];
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().getReviews(widget.service.id);
  }

  Future<void> callNumber(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> sendEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch email app';
    }
  }

  Future<void> openMapWithAddress(String address) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open Maps';
    }
  }

  void _showAddReviewDialog(BuildContext context) {
    double rating = 3;
    final commentController = TextEditingController();
    final user = context.read<UserProvider>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to post a review.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Write a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  rating = rating;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Enter your comment...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final review = Review(
                  id: const Uuid().v4(),
                  serviceId: widget.service.id,
                  userId: user.id,
                  comment: commentController.text,
                  rating: rating,
                  createdAt: DateTime.now(),
                );
                context.read<ServiceCubit>().addReview(review);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context),
        label: const Text('Write a Review'),
        icon: const Icon(Icons.edit),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            title: SizedBox(
              width: 200,
              child: Text(
                widget.service.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.service.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.service.town.label,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: Consumer<UserProvider>(
              builder:
                  (BuildContext context, UserProvider value, Widget? child) {
                    return IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: () {
                        value.user?.userType == 'Admin'
                            ? Navigator.of(
                                context,
                              ).pushNamed(ServicesScreen.routeName)
                            : Navigator.of(
                                context,
                              ).pushNamed(HomeScreen.routeName);
                      },
                    );
                  },
            ),
            actions: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is SignedIn && state.user.userType == 'admin') {
                    return IconButton(
                      icon: Icon(
                        Icons.bar_chart,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      tooltip: 'View Statistics',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ServiceMetadataPage(),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Chip(
                  label: Text(widget.service.category.label),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),
              ImageCarousel(imageUrls: widget.service.imageUrls),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(widget.service.description),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de contact',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            callNumber(widget.service.phoneNumber);
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.phone,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Téléphone'),
                            subtitle: Text(widget.service.phoneNumber),
                          ),
                        ),
                        const Divider(),
                        GestureDetector(
                          onTap: () {
                            sendEmail(widget.service.email);
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Email'),
                            subtitle: Text(widget.service.email),
                          ),
                        ),
                        const Divider(),
                        GestureDetector(
                          onTap: () =>
                              openMapWithAddress(widget.service.address),
                          child: ListTile(
                            leading: Icon(
                              Icons.location_city,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Adresse'),
                            subtitle: Text(widget.service.address),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Reviews',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is ReviewsLoaded) {
                    myReviews = state.reviews
                        .where(
                          (review) => review.serviceId == widget.service.id,
                        )
                        .toList();
                    print(myReviews);
                    if (myReviews.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No reviews yet.'),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.reviews.length,
                      itemBuilder: (context, index) {
                        final review = state.reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                RatingBarIndicator(
                                  rating: review.rating,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20.0,
                                  direction: Axis.horizontal,
                                ),
                                const Spacer(),
                                Text(
                                  '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            subtitle: Text(review.comment),
                          ),
                        );
                      },
                    );
                  } else if (state is ServiceError) {
                    return Center(child: Text(state.message));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
