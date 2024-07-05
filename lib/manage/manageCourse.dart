import 'package:flutter/material.dart';
import 'package:assets_elerning/manage/AddCourse.dart';
import 'package:assets_elerning/manage/deleteCourse.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Manage Data')),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.add),
                text: 'Add Data',
              ),
              Tab(
                icon: Icon(Icons.delete),
                text: 'Delete Data',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AddCoursePage(),
            DeleteCoursePage(),
          ],
        ),
      ),
    );
  }
}
