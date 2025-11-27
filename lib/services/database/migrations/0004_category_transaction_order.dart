import 'package:sqflite/sqflite.dart';
import '../../../model/category_transaction.dart';
import '../migration_base.dart';

// Models

class CategoryTransactionOrder extends Migration {
  CategoryTransactionOrder()
      : super(
            version: 4, description: 'Add order to category transaction table');

  @override
  Future<void> up(Database db) async {
    await db.execute('''
      ALTER TABLE `$categoryTransactionTable` ADD COLUMN `${CategoryTransactionFields.order}` INTEGER;
      ''');
  }
}
