import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/theme/theme_provider.dart';
import 'package:myapp/features/auth/presentation/providers/user_provider.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/views/create_service_screen.dart';
import 'package:myapp/features/service/presentation/widgets/service_list_item.dart';
import 'package:myapp/features/serviceMetadata/presentation/pages/service_metadata_page.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/views/sign_in_screen.dart';
import '../../domain/entities/service.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  late List<Service> myServices;
  @override
  void initState() {
    super.initState();
    myServices = [];
    context.read<ServiceCubit>().getServices();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserProvider>(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        leading: SizedBox(),
        actions: [
          if (user?.userType == 'Admin')
            IconButton(
              icon: const Icon(Icons.assessment),
              onPressed: () {
                Navigator.pushNamed(context, ServiceMetadataPage.routeName);
              },
              tooltip: 'Show Statistics',
            ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
        ],
      ),

      body: BlocConsumer<ServiceCubit, ServiceState>(
        listener: (context, state) {
          if (state is ServiceDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Service deleted successfully')),
            );
            context.read<ServiceCubit>().getServices();
          } else if (state is ServiceError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ServicesLoaded) {
            myServices = state.services;
          }
        },
        builder: (context, state) {
          if (state is GettingServices) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ServiceError) {
            return Center(child: Text(state.message));
          } else if (myServices.isNotEmpty) {
            return ListView.builder(
              itemCount: myServices.length,
              itemBuilder: (context, index) {
                final service = myServices[index];
                return ServiceListItem(service: service);
              },
            );
          }
          return const Center(child: Text('No services found.'));
        },
      ),
      floatingActionButton: SizedBox(
        height: 150,
        //color: Colors.green,
        child: Column(
          children: [
            FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, CreateServiceScreen.routeName);
              },
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 10),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is UserDeleted || state is SignedOut) {
                  context.read<UserProvider>().setUser(null);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    SignInScreen.routeName,
                    (route) => false,
                  );
                }
              },
              builder: (context, state) {
                return IconButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const SignOutEvent());
                  },
                  icon: const Icon(Icons.logout),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/**
 * 
 */
