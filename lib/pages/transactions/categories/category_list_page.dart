import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/constants.dart';
import '../../../../model/category_transaction.dart';
import '../../../../providers/categories_provider.dart';
import '../../../ui/widgets/default_card.dart';
import '../../../ui/widgets/rounded_icon.dart';
import '../../../ui/device.dart';

class CategoryList extends ConsumerStatefulWidget {
  const CategoryList({super.key});

  @override
  ConsumerState<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends ConsumerState<CategoryList> {
  @override
  Widget build(BuildContext context) {
    final categorysList = ref.watch(categoriesProvider);

    // ref.listen è utile per azioni side-effect, ok lasciarlo
    ref.listen(selectedCategoryProvider, (_, __) {});

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(selectedCategoryProvider);
              Navigator.of(context).pushNamed('/add-category');
            },
            icon: const Icon(Icons.add_circle),
            splashRadius: 28,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: Sizes.xl, horizontal: Sizes.lg),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.all(Sizes.sm),
                    child: Icon(
                      Icons.list_alt,
                      size: 24.0,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: Sizes.md),
                  Text(
                    "Your categories",
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
            categorysList.when(
              data: (categorys) {
                // converto in una lista modificabile per il drag&drop
                final currentList = categorys.toList();

                return ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentList.length,

                  // Logica di riordinamento
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final item = currentList.removeAt(oldIndex);
                      currentList.insert(newIndex, item);
                    });

                    // Salva il nuovo ordine nel DB
                    ref.read(categoriesProvider.notifier).reorderCategories(currentList);
                  },

                  // stile durante drag&drop
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: Colors.transparent,
                      shadowColor: Colors.black.withOpacity(0.2),
                      child: child,
                    );
                  },

                  itemBuilder: (context, i) {
                    CategoryTransaction category = currentList[i];

                    return Container(
                      key: ValueKey(category.id),
                      margin: const EdgeInsets.only(bottom: Sizes.lg),
                      child: DefaultCard(
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state = category;
                          Navigator.of(context).pushNamed('/add-category');
                        },
                        child: Row(
                          children: [
                            // Icona di trascinamento (handle)
                            const Icon(Icons.drag_handle, color: Colors.grey),
                            const SizedBox(width: Sizes.md),

                            RoundedIcon(
                              icon: iconList[category.symbol],
                              backgroundColor: categoryColorListTheme[category.color],
                              size: 30,
                            ),
                            const SizedBox(width: Sizes.md),
                            Expanded( // Expanded evita overflow se il testo è lungo
                              child: Text(
                                category.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                    color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),
          ],
        ),
      ),
    );
  }
}