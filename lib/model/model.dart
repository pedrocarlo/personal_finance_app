import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import '../tools/helper.dart';
import 'view.list.dart';

part 'model.g.dart';

const tableCartaoItau = SqfEntityTable(
    tableName: 'cartaoes',
    primaryKeyName: 'id',
    primaryKeyType: PrimaryKeyType.integer_auto_incremental,
    useSoftDeleting: false, // TODO see if soft Delete will be needed
    modelName: null,
    fields: [
      SqfEntityField('date', DbType.datetime),
      SqfEntityField('name', DbType.text),
      SqfEntityField('value', DbType.real),
      SqfEntityField('parcela', DbType.text),
      SqfEntityField('fatura', DbType.integer),
      SqfEntityField('card',
          DbType.text), // See if can have a limited value field with options
      SqfEntityField('emission', DbType.datetime),
      // TODO add ProductName that will display in form
    ]);

@SqfEntityBuilder(myDbModel)
const myDbModel = SqfEntityModel(
    // modelName: 'MyDbModel', // optional
    databaseName: 'account.db',
    password:
        null, // You can set a password if you want to use crypted database
    //(For more information: https://github.com/sqlcipher/sqlcipher)

    // put defined tables into the tables list.
    databaseTables: [tableCartaoItau],
    // You can define tables to generate add/edit view forms if you want to use Form Generator property
    // formTables: [tableProduct, tableCategory, tableTodo],
    // put defined sequences into the sequences list.
    // sequences: [seqIdentity],
    bundledDatabasePath:
        null // 'assets/sample.db' // This value is optional. When bundledDatabasePath is empty then EntityBase creats a new database when initializing the database
    );
