import 'package:flutter/material.dart';
import '../view_models/category_view_model.dart';
import '../widgets/category/category_results.dart';
import '../widgets/category/category_sidebar.dart';

/// Selection/search live in the ViewModel; scrolling belongs to this mounted tab.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.viewModel});

  final CategoryViewModel viewModel;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _contentController = ScrollController();

  void _selectCategory(String id) {
    widget.viewModel.select(id);
    if (_contentController.hasClients) _contentController.jumpTo(0);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CategorySidebar(
          categories: widget.viewModel.catalog.categories,
          selectedId: widget.viewModel.selectedId,
          onSelect: _selectCategory,
        ),
        Expanded(
          child: CategoryResults(
            title: widget.viewModel.selected.name,
            filters: widget.viewModel.matches,
            controller: _contentController,
          ),
        ),
      ],
    ),
  );
}
