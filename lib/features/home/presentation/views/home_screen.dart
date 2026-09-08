import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/core/theme/theme_provider.dart';
import 'package:myapp/features/auth/presentation/providers/user_provider.dart';
import 'package:myapp/features/auth/presentation/views/profile_screen.dart';
import 'package:myapp/features/auth/presentation/views/sign_in_screen.dart';
import 'package:myapp/features/home/presentation/views/privacy_policy_screen.dart';
import 'package:myapp/features/notifications/data/data_source/notification.data.service.dart';
import 'package:myapp/features/notifications/presentation/notification.icon.dart';
import 'package:myapp/features/service/domain/entities/category.dart';
import 'package:myapp/features/service/domain/entities/service.dart';
import 'package:myapp/features/service/domain/entities/town.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/views/all_services_screen.dart';
import 'package:myapp/features/service/presentation/views/reviewed_services_screen.dart';
import 'package:myapp/features/service/presentation/widgets/service_list_item.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ServiceCategory _selectedCategory = ServiceCategory.other;
  Town? _selectedTown;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late List<Service> filteredServices;
  late List<Service> allServices;
  late bool displayAllServices;

  @override
  void initState() {
    super.initState();
    filteredServices = [];
    allServices = [];
    displayAllServices = true;
    context.read<ServiceCubit>().getServices();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterServices(List<Service> services) {
    filteredServices.where((x) => x.status).toList();
    filteredServices = services.where((service) {
      final matchesCategory = service.category == _selectedCategory;
      final matchesTown =
          _selectedTown == null || service.town == _selectedTown;
      final matchesSearch = service.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      if (displayAllServices) {
        return matchesSearch && matchesTown;
      } else {
        return matchesCategory && matchesTown && matchesSearch;
      }
    }).toList();
    filteredServices.sort((a, b) {
      return a.createdAt.compareTo(b.createdAt);
    });
    filteredServices.sort((a, b) {
      int rank(String v) {
        if (v.toLowerCase() == 'premium') return 0;
        return 1;
      }

      return rank(a.subVersion.label).compareTo(rank(b.subVersion.label));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final themeProvider = context.watch<ThemeProvider>();

    // This ensures services are fetched if the cubit has been reset
    if (context.read<ServiceCubit>().state is ServiceInitial) {
      context.read<ServiceCubit>().getServices();
    }
    if (filteredServices.isEmpty &&
        context.read<ServiceCubit>().state is! ServicesLoaded) {
      context.read<ServiceCubit>().getServices();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (user != null)
              UserAccountsDrawerHeader(
                accountName: Text(user.name),
                accountEmail: Text(user.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 40.0),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            if (user != null)
              ListTile(
                leading: const Icon(Icons.reviews),
                title: const Text('My Reviewed Services'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(
                    context,
                  ).pushNamed(ReviewedServicesScreen.routeName);
                },
              ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Help'),
                    content: const Text(
                      'This is the help section. You can find information about the app here.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(user != null ? 'Sign Out' : 'Sign In'),
              onTap: () {
                Navigator.pop(context);
                if (user != null) {
                  // You would typically call your sign-out method here
                  // For now, just navigate to sign-in
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    SignInScreen.routeName,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamed(SignInScreen.routeName);
                }
              },
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu),
            ),
            //title: Text('Randoo', style: TextStyle(color: Colors.white)),
            actions: [
              /*IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
                onPressed: () {
                  context.read<ThemeProvider>().toggleTheme();
                },
              ),*/
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AllServicesScreen.routeName,
                    arguments: {
                      'category': _selectedCategory,
                      'town': _selectedTown,
                      'searchQuery': _searchQuery,
                    },
                  );
                },
              ),
              if (user != null)
                IconButton(
                  icon: Icon(
                    Icons.reviews,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed(ReviewedServicesScreen.routeName);
                  },
                ),
              if (user != null)
                NotificationIcon(
                  notificationService: NotificationDataService(user.id),
                ),
              IconButton(
                icon: Icon(
                  Icons.account_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 30,
                ),
                onPressed: () {
                  if (user != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  } else {
                    Navigator.of(context).pushNamed(SignInScreen.routeName);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 40,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'CAN 2025\nMaroc',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Votre annuaire complet des services au Maroc',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                /*const SizedBox(height: 20),
                PreferredSize(
                  preferredSize: const Size.fromHeight(60.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(51),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Rechercher un service...',
                            icon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),*/
                /*const SizedBox(height: 20),
                // Category Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: ServiceCategory.values.map((category) {
                      return _buildCategoryChip(
                        context,
                        category.label,
                        _getIconForCategory(category),
                        _selectedCategory == category && !displayAllServices,
                        () {
                          setState(() {
                            print(_selectedCategory);
                            _selectedCategory = category;
                            displayAllServices = false;
                            filteredServices = allServices;
                            _filterServices(filteredServices);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.48,
                  height: 80,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: _buildCategoryChip(
                    context,
                    "All",
                    Icons.category,
                    displayAllServices,
                    () {
                      setState(() {
                        displayAllServices = true;
                        filteredServices = allServices;
                        _filterServices(filteredServices);
                      });
                    },
                  ),
                ),
                // Town Dropdown
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Town>(
                        value: _selectedTown,
                        isExpanded: true,
                        hint: const Text('Toutes les villes'),
                        onChanged: (Town? newValue) {
                          setState(() {
                            _selectedTown = newValue;
                          });
                        },
                        items: Town.values.map((Town town) {
                          return DropdownMenuItem<Town>(
                            value: town,
                            child: Text(town.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),*/
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Services proposés',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          BlocConsumer<ServiceCubit, ServiceState>(
            listener: (context, state) {
              if (state is ServicesLoaded) {
                allServices = state.services;
                filteredServices = state.services;
                _filterServices(state.services);
              }
            },
            builder: (context, state) {
              if (state is GettingServices) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (state is ServiceError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(state.message)),
                );
              }
              if (filteredServices.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Aucun service trouvé.'),
                    ),
                  ),
                );
              }
              final servicesToShow = filteredServices.take(4).toList();
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == servicesToShow.length) {
                      if (filteredServices.length > 1) {
                        return Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AllServicesScreen.routeName,
                                arguments: {
                                  'category': _selectedCategory,
                                  'town': _selectedTown,
                                  'searchQuery': _searchQuery,
                                },
                              );
                            },
                            child: const Text('See More'),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: ServiceListItem(service: servicesToShow[index]),
                    );
                  },
                  childCount:
                      servicesToShow.length +
                      (filteredServices.length > 4 ? 1 : 0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 20,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.driver:
        return Icons.directions_car;
      case ServiceCategory.restaurant:
        return Icons.restaurant;
      case ServiceCategory.apartment:
        return Icons.home;
      case ServiceCategory.barberShop:
        return Icons.content_cut;
      case ServiceCategory.touristicGuide:
        return Icons.map;
      default:
        return Icons.category;
    }
  }
}
