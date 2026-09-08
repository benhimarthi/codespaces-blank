import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/service/domain/entities/category.dart';
import 'package:myapp/features/service/domain/entities/service.dart';
import 'package:myapp/features/service/domain/entities/subscription_version.dart';
import 'package:myapp/features/service/domain/entities/town.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/views/services_screen.dart';

import '../../../imageService/presentation/cubit/imageCubit.dart';
import '../../../imageService/presentation/cubit/imageState.dart';
import '../../../imageService/presentation/imageUploaderWidget.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key, required this.service});

  static const routeName = '/edit-service';
  final Service service;

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late ServiceCategory _selectedCategory;
  late Town _selectedTown;
  late SubscriptionVersion _selectedSubscription;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _emailController;
  final formKey = GlobalKey<FormState>();
  late List<String> myImages;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service.name);
    _descriptionController = TextEditingController(
      text: widget.service.description,
    );
    _selectedCategory = widget.service.category;
    _selectedTown = widget.service.town;
    _selectedSubscription = widget.service.subVersion;
    _addressController = TextEditingController(text: widget.service.address);
    _phoneNumberController = TextEditingController(
      text: widget.service.phoneNumber,
    );
    _emailController = TextEditingController(text: widget.service.email);
    myImages = widget.service.imageUrls;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _updateService() {
    if (formKey.currentState!.validate()) {
      final updatedService = widget.service.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        town: _selectedTown,
        subVersion: _selectedSubscription,
        address: _addressController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        imageUrls: myImages,
      );

      context.read<ServiceCubit>().updateService(updatedService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Service')),
      body: BlocListener<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service updated successfully')),
            );
            Navigator.of(context).pushNamed(ServicesScreen.routeName);
          } else if (state is ServiceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  BlocConsumer<Imagecubit, Imagestate>(
                    listener: (context, state) {
                      if (state is ImageLoaded) {
                        setState(() {
                          myImages.add(state.image);
                        });
                      }
                    },
                    builder: (context, state) {
                      return ImageUploaderWidget(displayUploadBtn: true);
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a service name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Service Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a service description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<ServiceCategory>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedCategory,
                    items: ServiceCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<Town>(
                    decoration: const InputDecoration(
                      labelText: 'Town',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedTown,
                    items: Town.values
                        .map(
                          (town) => DropdownMenuItem(
                            value: town,
                            child: Text(town.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTown = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a town';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<SubscriptionVersion>(
                    decoration: const InputDecoration(
                      labelText: 'Subscription',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedSubscription,
                    items: SubscriptionVersion.values
                        .map(
                          (sub) => DropdownMenuItem(
                            value: sub,
                            child: Text(sub.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubscription = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a subscription';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _updateService,
                    child: const Text('Update Service'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
