import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Dashboard_Content_D.dart';
import 'Process_Order_Content_D.dart';
import 'Inventory_Content_D.dart';
import 'Transaction_History_Content_D.dart';

class D_Dashboad_Page extends StatefulWidget {
  final String username;

  const D_Dashboad_Page({
    super.key,
    this.username = 'User_Name',
  });

  @override
  State<D_Dashboad_Page> createState() => _D_Dashboad_PageState();
}

class _D_Dashboad_PageState extends State<D_Dashboad_Page> {
  bool _isNavigationRailExpanded = false;
  int _selectedIndex = 0;

  final List<Widget> _mainContentPages = [
    DashboardContent(),
    ProcessOrderContentD(),
    InventoryContentD(),
    HistoryContentD(),
    const Center(child: Text('Transaction History Page')),
  ];

  double get _appIconSize => _isNavigationRailExpanded ? 100 : 50;
  double get _leadingSizedBoxHeight => _isNavigationRailExpanded ? 0 : 90;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/GradBG.png', fit: BoxFit.cover),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                _buildNavigationRail(),
                const VerticalDivider(thickness: 0.2, width: 1),
                Expanded(
                  child: ListView(
                    children: [
                      _buildCustomAppBar(),
                      _mainContentPages[_selectedIndex],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      extended: _isNavigationRailExpanded,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      backgroundColor: const Color.fromRGBO(150, 247, 164, 0.2),
      indicatorColor: const Color.fromRGBO(50, 206, 73, 1),
      leading: _buildNavigationRailLeading(),
      destinations: _buildNavigationRailDestinations(),
      trailing: _buildNavigationRailTrailing(),
      trailingAtBottom: true,
    );
  }

  Widget _buildNavigationRailLeading() {
    return Column(
      children: [
        IconButton(
          icon: Image.asset(
            'assets/app_icon.png',
            width: _appIconSize,
            height: _appIconSize,
          ),
          onPressed: () {},
        ),
        Visibility(
          visible: _isNavigationRailExpanded,
          child: const AutoSizeText(
            'POS SYSTEM',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: _leadingSizedBoxHeight),
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isNavigationRailExpanded = !_isNavigationRailExpanded;
            });
          },
        ),
      ],
    );
  }

  List<NavigationRailDestination> _buildNavigationRailDestinations() {
    return [
      NavigationRailDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home),
        label: const AutoSizeText('Dashboard'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.shopping_basket_outlined),
        selectedIcon: const Icon(Icons.shopping_basket),
        label: const AutoSizeText('Process Order'),
      ),
      NavigationRailDestination(
        icon: Image.asset(
          'assets/cube-outline.png',
          width: 23,
          height: 23,
        ),
        selectedIcon: Image.asset(
          'assets/3d-cube.png',
          width: 23,
          height: 23,
        ),
        label: const AutoSizeText('Inventory'),
      ),
      NavigationRailDestination(
        icon: const Icon(Icons.receipt_long_outlined),
        selectedIcon: const Icon(Icons.receipt_long),
        label: const AutoSizeText('Transaction History'),
      ),
    ];
  }

  Widget _buildNavigationRailTrailing() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(250, 0, 0, .5),
          ),
          child: IconButton(
            icon: const Icon(Icons.logout_sharp, color: Colors.white),
            onPressed: () {
              // Handle logout
            },
          ),
        ),
        const SizedBox(height: 4),
        const AutoSizeText(
          'Log Out',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    final List<String> appBarTitles = [
      '',
      'Process Order',
      'Inventory',
      'Transaction History',
      'Reports Analytics',
    ];

    return AppBar(
      title: AutoSizeText(
        appBarTitles[_selectedIndex],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 30,
          color: Colors.black,
        ),
      ),
      toolbarHeight: 70,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        Row(
          children: [
            const CircleAvatar(
              radius: 25,
            ),
            const SizedBox(width: 10),
            AutoSizeText(
               'Welcome, ${widget.username}!',// use username from login
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {
                print("Notification icon pressed!");
              },
            ),
            const SizedBox(width: 15),
          ],
        )
      ],
    );
  }
}
