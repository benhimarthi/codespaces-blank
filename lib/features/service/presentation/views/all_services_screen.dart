import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/service/domain/entities/category.dart';
import 'package:myapp/features/service/domain/entities/town.dart';
import 'package:myapp/features/service/presentation/cubit/service_cubit.dart';
import 'package:myapp/features/service/presentation/widgets/service_list_item.dart';
import '../../domain/entities/service.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({
    super.key,
    required this.initialCategory,
    required this.initialTown,
    required this.initialSearchQuery,
  });

  static const routeName = '/all-services';

  final ServiceCategory initialCategory;
  final Town? initialTown;
  final String initialSearchQuery;

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  late ServiceCategory _selectedCategory;
  late Town? _selectedTown;
  late String _searchQuery;
  final TextEditingController _searchController = TextEditingController();
  late List<Service> filteredServices;
  late bool displayAllServices;
  late List<Service> allServices;

  @override
  void initState() {
    super.initState();
    filteredServices = [];
    allServices = [];
    displayAllServices = true;
    _selectedCategory = widget.initialCategory;
    _selectedTown = widget.initialTown;
    _searchQuery = widget.initialSearchQuery;
    _searchController.text = _searchQuery;
    context.read<ServiceCubit>().getServices();
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
    return Scaffold(
      appBar: AppBar(title: const Text('All Services')),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Rechercher un service...',
                icon: Icon(Icons.search),
                //border: InputBorder.none,
              ),
            ),
          ),
          // Category Chips
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 65,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Builder(
                builder: (context) {
                  final myElement = ServiceCategory.values.map((category) {
                    return _buildCategoryChip(
                      context,
                      category.label,
                      _getIconForCategory(category),
                      _selectedCategory == category && !displayAllServices,
                      () {
                        setState(() {
                          _selectedCategory = category;
                          filteredServices = allServices;
                          displayAllServices = false;
                          _filterServices(filteredServices);
                        });
                      },
                    );
                  }).toList();
                  myElement.add(
                    _buildCategoryChip(
                      context,
                      'All',
                      Icons.all_inclusive,
                      displayAllServices,
                      () {
                        setState(() {
                          displayAllServices = true;
                          filteredServices = allServices;
                          _filterServices(filteredServices);
                        });
                      },
                    ),
                  );
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: myElement,
                  );
                },
              ),
            ),
          ),
          // Town Dropdown
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
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
          ),
          // Service List
          Expanded(
            child: BlocConsumer<ServiceCubit, ServiceState>(
              listener: (context, state) {
                if (state is ServicesLoaded) {
                  allServices = state.services;
                  filteredServices = state.services;
                  _filterServices(state.services);
                }
              },
              builder: (context, state) {
                if (state is GettingServices) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ServiceError) {
                  return Center(child: Text(state.message));
                }
                if (filteredServices.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ServiceListItem(
                          service: filteredServices[index],
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('Aucun service à afficher pour le moment.'),
                );
              },
            ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
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
        return Icons.cut;
      case ServiceCategory.touristicGuide:
        return Icons.map;
      case ServiceCategory.shop:
        return Icons.shopping_cart;
      case ServiceCategory.other:
        return Icons.more_horiz;
    }
  }
}
