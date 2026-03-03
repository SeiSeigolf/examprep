// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sourceTypeMeta = const VerificationMeta(
    'sourceType',
  );
  @override
  late final GeneratedColumn<String> sourceType = GeneratedColumn<String>(
    'source_type',
    aliasedName,
    false,
    check: () =>
        sourceType.isIn(const ['lecture', 'past_exam', 'assignment', 'notes']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lecture'),
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    filePath,
    sourceType,
    fileSize,
    pageCount,
    title,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('source_type')) {
      context.handle(
        _sourceTypeMeta,
        sourceType.isAcceptableOrUnknown(data['source_type']!, _sourceTypeMeta),
      );
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      sourceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  final int id;
  final String fileName;
  final String filePath;
  final String sourceType;
  final int? fileSize;
  final int? pageCount;
  final String? title;
  final DateTime importedAt;
  const Source({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.sourceType,
    this.fileSize,
    this.pageCount,
    this.title,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['source_type'] = Variable<String>(sourceType);
    if (!nullToAbsent || fileSize != null) {
      map['file_size'] = Variable<int>(fileSize);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['imported_at'] = Variable<DateTime>(importedAt);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      fileName: Value(fileName),
      filePath: Value(filePath),
      sourceType: Value(sourceType),
      fileSize: fileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSize),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      importedAt: Value(importedAt),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<int>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sourceType: serializer.fromJson<String>(json['sourceType']),
      fileSize: serializer.fromJson<int?>(json['fileSize']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      title: serializer.fromJson<String?>(json['title']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'sourceType': serializer.toJson<String>(sourceType),
      'fileSize': serializer.toJson<int?>(fileSize),
      'pageCount': serializer.toJson<int?>(pageCount),
      'title': serializer.toJson<String?>(title),
      'importedAt': serializer.toJson<DateTime>(importedAt),
    };
  }

  Source copyWith({
    int? id,
    String? fileName,
    String? filePath,
    String? sourceType,
    Value<int?> fileSize = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> title = const Value.absent(),
    DateTime? importedAt,
  }) => Source(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    sourceType: sourceType ?? this.sourceType,
    fileSize: fileSize.present ? fileSize.value : this.fileSize,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    title: title.present ? title.value : this.title,
    importedAt: importedAt ?? this.importedAt,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sourceType: data.sourceType.present
          ? data.sourceType.value
          : this.sourceType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      title: data.title.present ? data.title.value : this.title,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('sourceType: $sourceType, ')
          ..write('fileSize: $fileSize, ')
          ..write('pageCount: $pageCount, ')
          ..write('title: $title, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fileName,
    filePath,
    sourceType,
    fileSize,
    pageCount,
    title,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.sourceType == this.sourceType &&
          other.fileSize == this.fileSize &&
          other.pageCount == this.pageCount &&
          other.title == this.title &&
          other.importedAt == this.importedAt);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<int> id;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> sourceType;
  final Value<int?> fileSize;
  final Value<int?> pageCount;
  final Value<String?> title;
  final Value<DateTime> importedAt;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sourceType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.title = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  SourcesCompanion.insert({
    this.id = const Value.absent(),
    required String fileName,
    required String filePath,
    this.sourceType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.title = const Value.absent(),
    this.importedAt = const Value.absent(),
  }) : fileName = Value(fileName),
       filePath = Value(filePath);
  static Insertable<Source> custom({
    Expression<int>? id,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? sourceType,
    Expression<int>? fileSize,
    Expression<int>? pageCount,
    Expression<String>? title,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (sourceType != null) 'source_type': sourceType,
      if (fileSize != null) 'file_size': fileSize,
      if (pageCount != null) 'page_count': pageCount,
      if (title != null) 'title': title,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  SourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String>? sourceType,
    Value<int?>? fileSize,
    Value<int?>? pageCount,
    Value<String?>? title,
    Value<DateTime>? importedAt,
  }) {
    return SourcesCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      sourceType: sourceType ?? this.sourceType,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      title: title ?? this.title,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sourceType.present) {
      map['source_type'] = Variable<String>(sourceType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('sourceType: $sourceType, ')
          ..write('fileSize: $fileSize, ')
          ..write('pageCount: $pageCount, ')
          ..write('title: $title, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $SourceSegmentsTable extends SourceSegments
    with TableInfo<$SourceSegmentsTable, SourceSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourceSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _segmentTypeMeta = const VerificationMeta(
    'segmentType',
  );
  @override
  late final GeneratedColumn<String> segmentType = GeneratedColumn<String>(
    'segment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('page'),
  );
  static const VerificationMeta _contentConfidenceMeta = const VerificationMeta(
    'contentConfidence',
  );
  @override
  late final GeneratedColumn<String> contentConfidence =
      GeneratedColumn<String>(
        'content_confidence',
        aliasedName,
        false,
        check: () => contentConfidence.isIn(const ['H', 'M', 'L']),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('M'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    pageNumber,
    content,
    segmentType,
    contentConfidence,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'source_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SourceSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_pageNumberMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('segment_type')) {
      context.handle(
        _segmentTypeMeta,
        segmentType.isAcceptableOrUnknown(
          data['segment_type']!,
          _segmentTypeMeta,
        ),
      );
    }
    if (data.containsKey('content_confidence')) {
      context.handle(
        _contentConfidenceMeta,
        contentConfidence.isAcceptableOrUnknown(
          data['content_confidence']!,
          _contentConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SourceSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SourceSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_id'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      segmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_type'],
      )!,
      contentConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_confidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SourceSegmentsTable createAlias(String alias) {
    return $SourceSegmentsTable(attachedDatabase, alias);
  }
}

class SourceSegment extends DataClass implements Insertable<SourceSegment> {
  final int id;
  final int sourceId;
  final int pageNumber;
  final String content;
  final String segmentType;
  final String contentConfidence;
  final DateTime createdAt;
  const SourceSegment({
    required this.id,
    required this.sourceId,
    required this.pageNumber,
    required this.content,
    required this.segmentType,
    required this.contentConfidence,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_id'] = Variable<int>(sourceId);
    map['page_number'] = Variable<int>(pageNumber);
    map['content'] = Variable<String>(content);
    map['segment_type'] = Variable<String>(segmentType);
    map['content_confidence'] = Variable<String>(contentConfidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SourceSegmentsCompanion toCompanion(bool nullToAbsent) {
    return SourceSegmentsCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      pageNumber: Value(pageNumber),
      content: Value(content),
      segmentType: Value(segmentType),
      contentConfidence: Value(contentConfidence),
      createdAt: Value(createdAt),
    );
  }

  factory SourceSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SourceSegment(
      id: serializer.fromJson<int>(json['id']),
      sourceId: serializer.fromJson<int>(json['sourceId']),
      pageNumber: serializer.fromJson<int>(json['pageNumber']),
      content: serializer.fromJson<String>(json['content']),
      segmentType: serializer.fromJson<String>(json['segmentType']),
      contentConfidence: serializer.fromJson<String>(json['contentConfidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceId': serializer.toJson<int>(sourceId),
      'pageNumber': serializer.toJson<int>(pageNumber),
      'content': serializer.toJson<String>(content),
      'segmentType': serializer.toJson<String>(segmentType),
      'contentConfidence': serializer.toJson<String>(contentConfidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SourceSegment copyWith({
    int? id,
    int? sourceId,
    int? pageNumber,
    String? content,
    String? segmentType,
    String? contentConfidence,
    DateTime? createdAt,
  }) => SourceSegment(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    pageNumber: pageNumber ?? this.pageNumber,
    content: content ?? this.content,
    segmentType: segmentType ?? this.segmentType,
    contentConfidence: contentConfidence ?? this.contentConfidence,
    createdAt: createdAt ?? this.createdAt,
  );
  SourceSegment copyWithCompanion(SourceSegmentsCompanion data) {
    return SourceSegment(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      content: data.content.present ? data.content.value : this.content,
      segmentType: data.segmentType.present
          ? data.segmentType.value
          : this.segmentType,
      contentConfidence: data.contentConfidence.present
          ? data.contentConfidence.value
          : this.contentConfidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SourceSegment(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('content: $content, ')
          ..write('segmentType: $segmentType, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceId,
    pageNumber,
    content,
    segmentType,
    contentConfidence,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SourceSegment &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.pageNumber == this.pageNumber &&
          other.content == this.content &&
          other.segmentType == this.segmentType &&
          other.contentConfidence == this.contentConfidence &&
          other.createdAt == this.createdAt);
}

class SourceSegmentsCompanion extends UpdateCompanion<SourceSegment> {
  final Value<int> id;
  final Value<int> sourceId;
  final Value<int> pageNumber;
  final Value<String> content;
  final Value<String> segmentType;
  final Value<String> contentConfidence;
  final Value<DateTime> createdAt;
  const SourceSegmentsCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.content = const Value.absent(),
    this.segmentType = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SourceSegmentsCompanion.insert({
    this.id = const Value.absent(),
    required int sourceId,
    required int pageNumber,
    this.content = const Value.absent(),
    this.segmentType = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : sourceId = Value(sourceId),
       pageNumber = Value(pageNumber);
  static Insertable<SourceSegment> custom({
    Expression<int>? id,
    Expression<int>? sourceId,
    Expression<int>? pageNumber,
    Expression<String>? content,
    Expression<String>? segmentType,
    Expression<String>? contentConfidence,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (content != null) 'content': content,
      if (segmentType != null) 'segment_type': segmentType,
      if (contentConfidence != null) 'content_confidence': contentConfidence,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SourceSegmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceId,
    Value<int>? pageNumber,
    Value<String>? content,
    Value<String>? segmentType,
    Value<String>? contentConfidence,
    Value<DateTime>? createdAt,
  }) {
    return SourceSegmentsCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      pageNumber: pageNumber ?? this.pageNumber,
      content: content ?? this.content,
      segmentType: segmentType ?? this.segmentType,
      contentConfidence: contentConfidence ?? this.contentConfidence,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (segmentType.present) {
      map['segment_type'] = Variable<String>(segmentType.value);
    }
    if (contentConfidence.present) {
      map['content_confidence'] = Variable<String>(contentConfidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourceSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('content: $content, ')
          ..write('segmentType: $segmentType, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExamUnitsTable extends ExamUnits
    with TableInfo<$ExamUnitsTable, ExamUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('定義'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceLevelMeta = const VerificationMeta(
    'confidenceLevel',
  );
  @override
  late final GeneratedColumn<String> confidenceLevel = GeneratedColumn<String>(
    'confidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _examConfidenceMeta = const VerificationMeta(
    'examConfidence',
  );
  @override
  late final GeneratedColumn<String> examConfidence = GeneratedColumn<String>(
    'exam_confidence',
    aliasedName,
    false,
    check: () => examConfidence.isIn(const ['H', 'M', 'L']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('M'),
  );
  static const VerificationMeta _auditStatusMeta = const VerificationMeta(
    'auditStatus',
  );
  @override
  late final GeneratedColumn<String> auditStatus = GeneratedColumn<String>(
    'audit_status',
    aliasedName,
    false,
    check: () => auditStatus.isIn(const [
      'Covered',
      'Partial',
      'Uncovered',
      'Conflict',
      'LowConfidence',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Uncovered'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    unitType,
    description,
    confidenceLevel,
    examConfidence,
    auditStatus,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('confidence_level')) {
      context.handle(
        _confidenceLevelMeta,
        confidenceLevel.isAcceptableOrUnknown(
          data['confidence_level']!,
          _confidenceLevelMeta,
        ),
      );
    }
    if (data.containsKey('exam_confidence')) {
      context.handle(
        _examConfidenceMeta,
        examConfidence.isAcceptableOrUnknown(
          data['exam_confidence']!,
          _examConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('audit_status')) {
      context.handle(
        _auditStatusMeta,
        auditStatus.isAcceptableOrUnknown(
          data['audit_status']!,
          _auditStatusMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      confidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_level'],
      )!,
      examConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_confidence'],
      )!,
      auditStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audit_status'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExamUnitsTable createAlias(String alias) {
    return $ExamUnitsTable(attachedDatabase, alias);
  }
}

class ExamUnit extends DataClass implements Insertable<ExamUnit> {
  final int id;
  final String title;
  final String unitType;
  final String? description;
  final String confidenceLevel;
  final String examConfidence;
  final String auditStatus;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExamUnit({
    required this.id,
    required this.title,
    required this.unitType,
    this.description,
    required this.confidenceLevel,
    required this.examConfidence,
    required this.auditStatus,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['unit_type'] = Variable<String>(unitType);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['confidence_level'] = Variable<String>(confidenceLevel);
    map['exam_confidence'] = Variable<String>(examConfidence);
    map['audit_status'] = Variable<String>(auditStatus);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExamUnitsCompanion toCompanion(bool nullToAbsent) {
    return ExamUnitsCompanion(
      id: Value(id),
      title: Value(title),
      unitType: Value(unitType),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      confidenceLevel: Value(confidenceLevel),
      examConfidence: Value(examConfidence),
      auditStatus: Value(auditStatus),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExamUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamUnit(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      unitType: serializer.fromJson<String>(json['unitType']),
      description: serializer.fromJson<String?>(json['description']),
      confidenceLevel: serializer.fromJson<String>(json['confidenceLevel']),
      examConfidence: serializer.fromJson<String>(json['examConfidence']),
      auditStatus: serializer.fromJson<String>(json['auditStatus']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'unitType': serializer.toJson<String>(unitType),
      'description': serializer.toJson<String?>(description),
      'confidenceLevel': serializer.toJson<String>(confidenceLevel),
      'examConfidence': serializer.toJson<String>(examConfidence),
      'auditStatus': serializer.toJson<String>(auditStatus),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExamUnit copyWith({
    int? id,
    String? title,
    String? unitType,
    Value<String?> description = const Value.absent(),
    String? confidenceLevel,
    String? examConfidence,
    String? auditStatus,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExamUnit(
    id: id ?? this.id,
    title: title ?? this.title,
    unitType: unitType ?? this.unitType,
    description: description.present ? description.value : this.description,
    confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    examConfidence: examConfidence ?? this.examConfidence,
    auditStatus: auditStatus ?? this.auditStatus,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExamUnit copyWithCompanion(ExamUnitsCompanion data) {
    return ExamUnit(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      description: data.description.present
          ? data.description.value
          : this.description,
      confidenceLevel: data.confidenceLevel.present
          ? data.confidenceLevel.value
          : this.confidenceLevel,
      examConfidence: data.examConfidence.present
          ? data.examConfidence.value
          : this.examConfidence,
      auditStatus: data.auditStatus.present
          ? data.auditStatus.value
          : this.auditStatus,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamUnit(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('unitType: $unitType, ')
          ..write('description: $description, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('examConfidence: $examConfidence, ')
          ..write('auditStatus: $auditStatus, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    unitType,
    description,
    confidenceLevel,
    examConfidence,
    auditStatus,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamUnit &&
          other.id == this.id &&
          other.title == this.title &&
          other.unitType == this.unitType &&
          other.description == this.description &&
          other.confidenceLevel == this.confidenceLevel &&
          other.examConfidence == this.examConfidence &&
          other.auditStatus == this.auditStatus &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExamUnitsCompanion extends UpdateCompanion<ExamUnit> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> unitType;
  final Value<String?> description;
  final Value<String> confidenceLevel;
  final Value<String> examConfidence;
  final Value<String> auditStatus;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ExamUnitsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.unitType = const Value.absent(),
    this.description = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.examConfidence = const Value.absent(),
    this.auditStatus = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ExamUnitsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.unitType = const Value.absent(),
    this.description = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.examConfidence = const Value.absent(),
    this.auditStatus = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ExamUnit> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? unitType,
    Expression<String>? description,
    Expression<String>? confidenceLevel,
    Expression<String>? examConfidence,
    Expression<String>? auditStatus,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (unitType != null) 'unit_type': unitType,
      if (description != null) 'description': description,
      if (confidenceLevel != null) 'confidence_level': confidenceLevel,
      if (examConfidence != null) 'exam_confidence': examConfidence,
      if (auditStatus != null) 'audit_status': auditStatus,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ExamUnitsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? unitType,
    Value<String?>? description,
    Value<String>? confidenceLevel,
    Value<String>? examConfidence,
    Value<String>? auditStatus,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ExamUnitsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      unitType: unitType ?? this.unitType,
      description: description ?? this.description,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      examConfidence: examConfidence ?? this.examConfidence,
      auditStatus: auditStatus ?? this.auditStatus,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (confidenceLevel.present) {
      map['confidence_level'] = Variable<String>(confidenceLevel.value);
    }
    if (examConfidence.present) {
      map['exam_confidence'] = Variable<String>(examConfidence.value);
    }
    if (auditStatus.present) {
      map['audit_status'] = Variable<String>(auditStatus.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamUnitsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('unitType: $unitType, ')
          ..write('description: $description, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('examConfidence: $examConfidence, ')
          ..write('auditStatus: $auditStatus, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ClaimsTable extends Claims with TableInfo<$ClaimsTable, Claim> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClaimsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examUnitIdMeta = const VerificationMeta(
    'examUnitId',
  );
  @override
  late final GeneratedColumn<int> examUnitId = GeneratedColumn<int>(
    'exam_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentConfidenceMeta = const VerificationMeta(
    'contentConfidence',
  );
  @override
  late final GeneratedColumn<String> contentConfidence =
      GeneratedColumn<String>(
        'content_confidence',
        aliasedName,
        false,
        check: () => contentConfidence.isIn(const ['H', 'M', 'L']),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('M'),
      );
  static const VerificationMeta _confidenceLevelMeta = const VerificationMeta(
    'confidenceLevel',
  );
  @override
  late final GeneratedColumn<String> confidenceLevel = GeneratedColumn<String>(
    'confidence_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medium'),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examUnitId,
    content,
    contentConfidence,
    confidenceLevel,
    createdBy,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'claims';
  @override
  VerificationContext validateIntegrity(
    Insertable<Claim> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_unit_id')) {
      context.handle(
        _examUnitIdMeta,
        examUnitId.isAcceptableOrUnknown(
          data['exam_unit_id']!,
          _examUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examUnitIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_confidence')) {
      context.handle(
        _contentConfidenceMeta,
        contentConfidence.isAcceptableOrUnknown(
          data['content_confidence']!,
          _contentConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('confidence_level')) {
      context.handle(
        _confidenceLevelMeta,
        confidenceLevel.isAcceptableOrUnknown(
          data['confidence_level']!,
          _confidenceLevelMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Claim map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Claim(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_unit_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      contentConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_confidence'],
      )!,
      confidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_level'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClaimsTable createAlias(String alias) {
    return $ClaimsTable(attachedDatabase, alias);
  }
}

class Claim extends DataClass implements Insertable<Claim> {
  final int id;
  final int examUnitId;
  final String content;
  final String contentConfidence;
  final String confidenceLevel;
  final String createdBy;
  final DateTime createdAt;
  const Claim({
    required this.id,
    required this.examUnitId,
    required this.content,
    required this.contentConfidence,
    required this.confidenceLevel,
    required this.createdBy,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_unit_id'] = Variable<int>(examUnitId);
    map['content'] = Variable<String>(content);
    map['content_confidence'] = Variable<String>(contentConfidence);
    map['confidence_level'] = Variable<String>(confidenceLevel);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClaimsCompanion toCompanion(bool nullToAbsent) {
    return ClaimsCompanion(
      id: Value(id),
      examUnitId: Value(examUnitId),
      content: Value(content),
      contentConfidence: Value(contentConfidence),
      confidenceLevel: Value(confidenceLevel),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
    );
  }

  factory Claim.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Claim(
      id: serializer.fromJson<int>(json['id']),
      examUnitId: serializer.fromJson<int>(json['examUnitId']),
      content: serializer.fromJson<String>(json['content']),
      contentConfidence: serializer.fromJson<String>(json['contentConfidence']),
      confidenceLevel: serializer.fromJson<String>(json['confidenceLevel']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examUnitId': serializer.toJson<int>(examUnitId),
      'content': serializer.toJson<String>(content),
      'contentConfidence': serializer.toJson<String>(contentConfidence),
      'confidenceLevel': serializer.toJson<String>(confidenceLevel),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Claim copyWith({
    int? id,
    int? examUnitId,
    String? content,
    String? contentConfidence,
    String? confidenceLevel,
    String? createdBy,
    DateTime? createdAt,
  }) => Claim(
    id: id ?? this.id,
    examUnitId: examUnitId ?? this.examUnitId,
    content: content ?? this.content,
    contentConfidence: contentConfidence ?? this.contentConfidence,
    confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
  );
  Claim copyWithCompanion(ClaimsCompanion data) {
    return Claim(
      id: data.id.present ? data.id.value : this.id,
      examUnitId: data.examUnitId.present
          ? data.examUnitId.value
          : this.examUnitId,
      content: data.content.present ? data.content.value : this.content,
      contentConfidence: data.contentConfidence.present
          ? data.contentConfidence.value
          : this.contentConfidence,
      confidenceLevel: data.confidenceLevel.present
          ? data.confidenceLevel.value
          : this.confidenceLevel,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Claim(')
          ..write('id: $id, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('content: $content, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examUnitId,
    content,
    contentConfidence,
    confidenceLevel,
    createdBy,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Claim &&
          other.id == this.id &&
          other.examUnitId == this.examUnitId &&
          other.content == this.content &&
          other.contentConfidence == this.contentConfidence &&
          other.confidenceLevel == this.confidenceLevel &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt);
}

class ClaimsCompanion extends UpdateCompanion<Claim> {
  final Value<int> id;
  final Value<int> examUnitId;
  final Value<String> content;
  final Value<String> contentConfidence;
  final Value<String> confidenceLevel;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  const ClaimsCompanion({
    this.id = const Value.absent(),
    this.examUnitId = const Value.absent(),
    this.content = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClaimsCompanion.insert({
    this.id = const Value.absent(),
    required int examUnitId,
    required String content,
    this.contentConfidence = const Value.absent(),
    this.confidenceLevel = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : examUnitId = Value(examUnitId),
       content = Value(content);
  static Insertable<Claim> custom({
    Expression<int>? id,
    Expression<int>? examUnitId,
    Expression<String>? content,
    Expression<String>? contentConfidence,
    Expression<String>? confidenceLevel,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examUnitId != null) 'exam_unit_id': examUnitId,
      if (content != null) 'content': content,
      if (contentConfidence != null) 'content_confidence': contentConfidence,
      if (confidenceLevel != null) 'confidence_level': confidenceLevel,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClaimsCompanion copyWith({
    Value<int>? id,
    Value<int>? examUnitId,
    Value<String>? content,
    Value<String>? contentConfidence,
    Value<String>? confidenceLevel,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
  }) {
    return ClaimsCompanion(
      id: id ?? this.id,
      examUnitId: examUnitId ?? this.examUnitId,
      content: content ?? this.content,
      contentConfidence: contentConfidence ?? this.contentConfidence,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examUnitId.present) {
      map['exam_unit_id'] = Variable<int>(examUnitId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentConfidence.present) {
      map['content_confidence'] = Variable<String>(contentConfidence.value);
    }
    if (confidenceLevel.present) {
      map['confidence_level'] = Variable<String>(confidenceLevel.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClaimsCompanion(')
          ..write('id: $id, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('content: $content, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('confidenceLevel: $confidenceLevel, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EvidenceLinksTable extends EvidenceLinks
    with TableInfo<$EvidenceLinksTable, EvidenceLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidenceLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<int> claimId = GeneratedColumn<int>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceSegmentIdMeta = const VerificationMeta(
    'sourceSegmentId',
  );
  @override
  late final GeneratedColumn<int> sourceSegmentId = GeneratedColumn<int>(
    'source_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    claimId,
    sourceSegmentId,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidenceLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('source_segment_id')) {
      context.handle(
        _sourceSegmentIdMeta,
        sourceSegmentId.isAcceptableOrUnknown(
          data['source_segment_id']!,
          _sourceSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSegmentIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {claimId, sourceSegmentId},
  ];
  @override
  EvidenceLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidenceLink(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claim_id'],
      )!,
      sourceSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_segment_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EvidenceLinksTable createAlias(String alias) {
    return $EvidenceLinksTable(attachedDatabase, alias);
  }
}

class EvidenceLink extends DataClass implements Insertable<EvidenceLink> {
  final int id;
  final int claimId;
  final int sourceSegmentId;
  final String? note;
  final DateTime createdAt;
  const EvidenceLink({
    required this.id,
    required this.claimId,
    required this.sourceSegmentId,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['claim_id'] = Variable<int>(claimId);
    map['source_segment_id'] = Variable<int>(sourceSegmentId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EvidenceLinksCompanion toCompanion(bool nullToAbsent) {
    return EvidenceLinksCompanion(
      id: Value(id),
      claimId: Value(claimId),
      sourceSegmentId: Value(sourceSegmentId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory EvidenceLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidenceLink(
      id: serializer.fromJson<int>(json['id']),
      claimId: serializer.fromJson<int>(json['claimId']),
      sourceSegmentId: serializer.fromJson<int>(json['sourceSegmentId']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claimId': serializer.toJson<int>(claimId),
      'sourceSegmentId': serializer.toJson<int>(sourceSegmentId),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EvidenceLink copyWith({
    int? id,
    int? claimId,
    int? sourceSegmentId,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => EvidenceLink(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  EvidenceLink copyWithCompanion(EvidenceLinksCompanion data) {
    return EvidenceLink(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      sourceSegmentId: data.sourceSegmentId.present
          ? data.sourceSegmentId.value
          : this.sourceSegmentId,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceLink(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, claimId, sourceSegmentId, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidenceLink &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.sourceSegmentId == this.sourceSegmentId &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class EvidenceLinksCompanion extends UpdateCompanion<EvidenceLink> {
  final Value<int> id;
  final Value<int> claimId;
  final Value<int> sourceSegmentId;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const EvidenceLinksCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.sourceSegmentId = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EvidenceLinksCompanion.insert({
    this.id = const Value.absent(),
    required int claimId,
    required int sourceSegmentId,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : claimId = Value(claimId),
       sourceSegmentId = Value(sourceSegmentId);
  static Insertable<EvidenceLink> custom({
    Expression<int>? id,
    Expression<int>? claimId,
    Expression<int>? sourceSegmentId,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (sourceSegmentId != null) 'source_segment_id': sourceSegmentId,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EvidenceLinksCompanion copyWith({
    Value<int>? id,
    Value<int>? claimId,
    Value<int>? sourceSegmentId,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return EvidenceLinksCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<int>(claimId.value);
    }
    if (sourceSegmentId.present) {
      map['source_segment_id'] = Variable<int>(sourceSegmentId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidenceLinksCompanion(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AuditsTable extends Audits with TableInfo<$AuditsTable, Audit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceSegmentIdMeta = const VerificationMeta(
    'sourceSegmentId',
  );
  @override
  late final GeneratedColumn<int> sourceSegmentId = GeneratedColumn<int>(
    'source_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _examUnitIdMeta = const VerificationMeta(
    'examUnitId',
  );
  @override
  late final GeneratedColumn<int> examUnitId = GeneratedColumn<int>(
    'exam_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(const [
      'Covered',
      'Partial',
      'Uncovered',
      'Conflict',
      'LowConfidence',
    ]),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentConfidenceMeta = const VerificationMeta(
    'contentConfidence',
  );
  @override
  late final GeneratedColumn<String> contentConfidence =
      GeneratedColumn<String>(
        'content_confidence',
        aliasedName,
        false,
        check: () => contentConfidence.isIn(const ['H', 'M', 'L']),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('M'),
      );
  static const VerificationMeta _examConfidenceMeta = const VerificationMeta(
    'examConfidence',
  );
  @override
  late final GeneratedColumn<String> examConfidence = GeneratedColumn<String>(
    'exam_confidence',
    aliasedName,
    false,
    check: () => examConfidence.isIn(const ['H', 'M', 'L']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('M'),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceSegmentId,
    examUnitId,
    status,
    contentConfidence,
    examConfidence,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Audit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_segment_id')) {
      context.handle(
        _sourceSegmentIdMeta,
        sourceSegmentId.isAcceptableOrUnknown(
          data['source_segment_id']!,
          _sourceSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSegmentIdMeta);
    }
    if (data.containsKey('exam_unit_id')) {
      context.handle(
        _examUnitIdMeta,
        examUnitId.isAcceptableOrUnknown(
          data['exam_unit_id']!,
          _examUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examUnitIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('content_confidence')) {
      context.handle(
        _contentConfidenceMeta,
        contentConfidence.isAcceptableOrUnknown(
          data['content_confidence']!,
          _contentConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('exam_confidence')) {
      context.handle(
        _examConfidenceMeta,
        examConfidence.isAcceptableOrUnknown(
          data['exam_confidence']!,
          _examConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sourceSegmentId, examUnitId},
  ];
  @override
  Audit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Audit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_segment_id'],
      )!,
      examUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_unit_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      contentConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_confidence'],
      )!,
      examConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_confidence'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AuditsTable createAlias(String alias) {
    return $AuditsTable(attachedDatabase, alias);
  }
}

class Audit extends DataClass implements Insertable<Audit> {
  final int id;
  final int sourceSegmentId;
  final int examUnitId;
  final String status;
  final String contentConfidence;
  final String examConfidence;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Audit({
    required this.id,
    required this.sourceSegmentId,
    required this.examUnitId,
    required this.status,
    required this.contentConfidence,
    required this.examConfidence,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_segment_id'] = Variable<int>(sourceSegmentId);
    map['exam_unit_id'] = Variable<int>(examUnitId);
    map['status'] = Variable<String>(status);
    map['content_confidence'] = Variable<String>(contentConfidence);
    map['exam_confidence'] = Variable<String>(examConfidence);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AuditsCompanion toCompanion(bool nullToAbsent) {
    return AuditsCompanion(
      id: Value(id),
      sourceSegmentId: Value(sourceSegmentId),
      examUnitId: Value(examUnitId),
      status: Value(status),
      contentConfidence: Value(contentConfidence),
      examConfidence: Value(examConfidence),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Audit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Audit(
      id: serializer.fromJson<int>(json['id']),
      sourceSegmentId: serializer.fromJson<int>(json['sourceSegmentId']),
      examUnitId: serializer.fromJson<int>(json['examUnitId']),
      status: serializer.fromJson<String>(json['status']),
      contentConfidence: serializer.fromJson<String>(json['contentConfidence']),
      examConfidence: serializer.fromJson<String>(json['examConfidence']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceSegmentId': serializer.toJson<int>(sourceSegmentId),
      'examUnitId': serializer.toJson<int>(examUnitId),
      'status': serializer.toJson<String>(status),
      'contentConfidence': serializer.toJson<String>(contentConfidence),
      'examConfidence': serializer.toJson<String>(examConfidence),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Audit copyWith({
    int? id,
    int? sourceSegmentId,
    int? examUnitId,
    String? status,
    String? contentConfidence,
    String? examConfidence,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Audit(
    id: id ?? this.id,
    sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
    examUnitId: examUnitId ?? this.examUnitId,
    status: status ?? this.status,
    contentConfidence: contentConfidence ?? this.contentConfidence,
    examConfidence: examConfidence ?? this.examConfidence,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Audit copyWithCompanion(AuditsCompanion data) {
    return Audit(
      id: data.id.present ? data.id.value : this.id,
      sourceSegmentId: data.sourceSegmentId.present
          ? data.sourceSegmentId.value
          : this.sourceSegmentId,
      examUnitId: data.examUnitId.present
          ? data.examUnitId.value
          : this.examUnitId,
      status: data.status.present ? data.status.value : this.status,
      contentConfidence: data.contentConfidence.present
          ? data.contentConfidence.value
          : this.contentConfidence,
      examConfidence: data.examConfidence.present
          ? data.examConfidence.value
          : this.examConfidence,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Audit(')
          ..write('id: $id, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('status: $status, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('examConfidence: $examConfidence, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceSegmentId,
    examUnitId,
    status,
    contentConfidence,
    examConfidence,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Audit &&
          other.id == this.id &&
          other.sourceSegmentId == this.sourceSegmentId &&
          other.examUnitId == this.examUnitId &&
          other.status == this.status &&
          other.contentConfidence == this.contentConfidence &&
          other.examConfidence == this.examConfidence &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AuditsCompanion extends UpdateCompanion<Audit> {
  final Value<int> id;
  final Value<int> sourceSegmentId;
  final Value<int> examUnitId;
  final Value<String> status;
  final Value<String> contentConfidence;
  final Value<String> examConfidence;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AuditsCompanion({
    this.id = const Value.absent(),
    this.sourceSegmentId = const Value.absent(),
    this.examUnitId = const Value.absent(),
    this.status = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.examConfidence = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AuditsCompanion.insert({
    this.id = const Value.absent(),
    required int sourceSegmentId,
    required int examUnitId,
    required String status,
    this.contentConfidence = const Value.absent(),
    this.examConfidence = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : sourceSegmentId = Value(sourceSegmentId),
       examUnitId = Value(examUnitId),
       status = Value(status);
  static Insertable<Audit> custom({
    Expression<int>? id,
    Expression<int>? sourceSegmentId,
    Expression<int>? examUnitId,
    Expression<String>? status,
    Expression<String>? contentConfidence,
    Expression<String>? examConfidence,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceSegmentId != null) 'source_segment_id': sourceSegmentId,
      if (examUnitId != null) 'exam_unit_id': examUnitId,
      if (status != null) 'status': status,
      if (contentConfidence != null) 'content_confidence': contentConfidence,
      if (examConfidence != null) 'exam_confidence': examConfidence,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AuditsCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceSegmentId,
    Value<int>? examUnitId,
    Value<String>? status,
    Value<String>? contentConfidence,
    Value<String>? examConfidence,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AuditsCompanion(
      id: id ?? this.id,
      sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
      examUnitId: examUnitId ?? this.examUnitId,
      status: status ?? this.status,
      contentConfidence: contentConfidence ?? this.contentConfidence,
      examConfidence: examConfidence ?? this.examConfidence,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceSegmentId.present) {
      map['source_segment_id'] = Variable<int>(sourceSegmentId.value);
    }
    if (examUnitId.present) {
      map['exam_unit_id'] = Variable<int>(examUnitId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (contentConfidence.present) {
      map['content_confidence'] = Variable<String>(contentConfidence.value);
    }
    if (examConfidence.present) {
      map['exam_confidence'] = Variable<String>(examConfidence.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditsCompanion(')
          ..write('id: $id, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('status: $status, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('examConfidence: $examConfidence, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ConflictsTable extends Conflicts
    with TableInfo<$ConflictsTable, Conflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceSegmentIdMeta = const VerificationMeta(
    'sourceSegmentId',
  );
  @override
  late final GeneratedColumn<int> sourceSegmentId = GeneratedColumn<int>(
    'source_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _examUnitIdMeta = const VerificationMeta(
    'examUnitId',
  );
  @override
  late final GeneratedColumn<int> examUnitId = GeneratedColumn<int>(
    'exam_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<int> claimId = GeneratedColumn<int>(
    'claim_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _auditIdMeta = const VerificationMeta(
    'auditId',
  );
  @override
  late final GeneratedColumn<int> auditId = GeneratedColumn<int>(
    'audit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES audits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(const ['open', 'resolved', 'dismissed']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolutionNoteMeta = const VerificationMeta(
    'resolutionNote',
  );
  @override
  late final GeneratedColumn<String> resolutionNote = GeneratedColumn<String>(
    'resolution_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceSegmentId,
    examUnitId,
    claimId,
    auditId,
    status,
    reason,
    resolutionNote,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_segment_id')) {
      context.handle(
        _sourceSegmentIdMeta,
        sourceSegmentId.isAcceptableOrUnknown(
          data['source_segment_id']!,
          _sourceSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSegmentIdMeta);
    }
    if (data.containsKey('exam_unit_id')) {
      context.handle(
        _examUnitIdMeta,
        examUnitId.isAcceptableOrUnknown(
          data['exam_unit_id']!,
          _examUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examUnitIdMeta);
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    }
    if (data.containsKey('audit_id')) {
      context.handle(
        _auditIdMeta,
        auditId.isAcceptableOrUnknown(data['audit_id']!, _auditIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('resolution_note')) {
      context.handle(
        _resolutionNoteMeta,
        resolutionNote.isAcceptableOrUnknown(
          data['resolution_note']!,
          _resolutionNoteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_segment_id'],
      )!,
      examUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_unit_id'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claim_id'],
      ),
      auditId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audit_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      resolutionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $ConflictsTable createAlias(String alias) {
    return $ConflictsTable(attachedDatabase, alias);
  }
}

class Conflict extends DataClass implements Insertable<Conflict> {
  final int id;
  final int sourceSegmentId;
  final int examUnitId;
  final int? claimId;
  final int? auditId;
  final String status;
  final String? reason;
  final String? resolutionNote;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const Conflict({
    required this.id,
    required this.sourceSegmentId,
    required this.examUnitId,
    this.claimId,
    this.auditId,
    required this.status,
    this.reason,
    this.resolutionNote,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_segment_id'] = Variable<int>(sourceSegmentId);
    map['exam_unit_id'] = Variable<int>(examUnitId);
    if (!nullToAbsent || claimId != null) {
      map['claim_id'] = Variable<int>(claimId);
    }
    if (!nullToAbsent || auditId != null) {
      map['audit_id'] = Variable<int>(auditId);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || resolutionNote != null) {
      map['resolution_note'] = Variable<String>(resolutionNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  ConflictsCompanion toCompanion(bool nullToAbsent) {
    return ConflictsCompanion(
      id: Value(id),
      sourceSegmentId: Value(sourceSegmentId),
      examUnitId: Value(examUnitId),
      claimId: claimId == null && nullToAbsent
          ? const Value.absent()
          : Value(claimId),
      auditId: auditId == null && nullToAbsent
          ? const Value.absent()
          : Value(auditId),
      status: Value(status),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      resolutionNote: resolutionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionNote),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory Conflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conflict(
      id: serializer.fromJson<int>(json['id']),
      sourceSegmentId: serializer.fromJson<int>(json['sourceSegmentId']),
      examUnitId: serializer.fromJson<int>(json['examUnitId']),
      claimId: serializer.fromJson<int?>(json['claimId']),
      auditId: serializer.fromJson<int?>(json['auditId']),
      status: serializer.fromJson<String>(json['status']),
      reason: serializer.fromJson<String?>(json['reason']),
      resolutionNote: serializer.fromJson<String?>(json['resolutionNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceSegmentId': serializer.toJson<int>(sourceSegmentId),
      'examUnitId': serializer.toJson<int>(examUnitId),
      'claimId': serializer.toJson<int?>(claimId),
      'auditId': serializer.toJson<int?>(auditId),
      'status': serializer.toJson<String>(status),
      'reason': serializer.toJson<String?>(reason),
      'resolutionNote': serializer.toJson<String?>(resolutionNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  Conflict copyWith({
    int? id,
    int? sourceSegmentId,
    int? examUnitId,
    Value<int?> claimId = const Value.absent(),
    Value<int?> auditId = const Value.absent(),
    String? status,
    Value<String?> reason = const Value.absent(),
    Value<String?> resolutionNote = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => Conflict(
    id: id ?? this.id,
    sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
    examUnitId: examUnitId ?? this.examUnitId,
    claimId: claimId.present ? claimId.value : this.claimId,
    auditId: auditId.present ? auditId.value : this.auditId,
    status: status ?? this.status,
    reason: reason.present ? reason.value : this.reason,
    resolutionNote: resolutionNote.present
        ? resolutionNote.value
        : this.resolutionNote,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  Conflict copyWithCompanion(ConflictsCompanion data) {
    return Conflict(
      id: data.id.present ? data.id.value : this.id,
      sourceSegmentId: data.sourceSegmentId.present
          ? data.sourceSegmentId.value
          : this.sourceSegmentId,
      examUnitId: data.examUnitId.present
          ? data.examUnitId.value
          : this.examUnitId,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      auditId: data.auditId.present ? data.auditId.value : this.auditId,
      status: data.status.present ? data.status.value : this.status,
      reason: data.reason.present ? data.reason.value : this.reason,
      resolutionNote: data.resolutionNote.present
          ? data.resolutionNote.value
          : this.resolutionNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conflict(')
          ..write('id: $id, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('claimId: $claimId, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('resolutionNote: $resolutionNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceSegmentId,
    examUnitId,
    claimId,
    auditId,
    status,
    reason,
    resolutionNote,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conflict &&
          other.id == this.id &&
          other.sourceSegmentId == this.sourceSegmentId &&
          other.examUnitId == this.examUnitId &&
          other.claimId == this.claimId &&
          other.auditId == this.auditId &&
          other.status == this.status &&
          other.reason == this.reason &&
          other.resolutionNote == this.resolutionNote &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class ConflictsCompanion extends UpdateCompanion<Conflict> {
  final Value<int> id;
  final Value<int> sourceSegmentId;
  final Value<int> examUnitId;
  final Value<int?> claimId;
  final Value<int?> auditId;
  final Value<String> status;
  final Value<String?> reason;
  final Value<String?> resolutionNote;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  const ConflictsCompanion({
    this.id = const Value.absent(),
    this.sourceSegmentId = const Value.absent(),
    this.examUnitId = const Value.absent(),
    this.claimId = const Value.absent(),
    this.auditId = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolutionNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  ConflictsCompanion.insert({
    this.id = const Value.absent(),
    required int sourceSegmentId,
    required int examUnitId,
    this.claimId = const Value.absent(),
    this.auditId = const Value.absent(),
    this.status = const Value.absent(),
    this.reason = const Value.absent(),
    this.resolutionNote = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  }) : sourceSegmentId = Value(sourceSegmentId),
       examUnitId = Value(examUnitId);
  static Insertable<Conflict> custom({
    Expression<int>? id,
    Expression<int>? sourceSegmentId,
    Expression<int>? examUnitId,
    Expression<int>? claimId,
    Expression<int>? auditId,
    Expression<String>? status,
    Expression<String>? reason,
    Expression<String>? resolutionNote,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceSegmentId != null) 'source_segment_id': sourceSegmentId,
      if (examUnitId != null) 'exam_unit_id': examUnitId,
      if (claimId != null) 'claim_id': claimId,
      if (auditId != null) 'audit_id': auditId,
      if (status != null) 'status': status,
      if (reason != null) 'reason': reason,
      if (resolutionNote != null) 'resolution_note': resolutionNote,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  ConflictsCompanion copyWith({
    Value<int>? id,
    Value<int>? sourceSegmentId,
    Value<int>? examUnitId,
    Value<int?>? claimId,
    Value<int?>? auditId,
    Value<String>? status,
    Value<String?>? reason,
    Value<String?>? resolutionNote,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
  }) {
    return ConflictsCompanion(
      id: id ?? this.id,
      sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
      examUnitId: examUnitId ?? this.examUnitId,
      claimId: claimId ?? this.claimId,
      auditId: auditId ?? this.auditId,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      resolutionNote: resolutionNote ?? this.resolutionNote,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceSegmentId.present) {
      map['source_segment_id'] = Variable<int>(sourceSegmentId.value);
    }
    if (examUnitId.present) {
      map['exam_unit_id'] = Variable<int>(examUnitId.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<int>(claimId.value);
    }
    if (auditId.present) {
      map['audit_id'] = Variable<int>(auditId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (resolutionNote.present) {
      map['resolution_note'] = Variable<String>(resolutionNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictsCompanion(')
          ..write('id: $id, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('claimId: $claimId, ')
          ..write('auditId: $auditId, ')
          ..write('status: $status, ')
          ..write('reason: $reason, ')
          ..write('resolutionNote: $resolutionNote, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $StudyMethodsTable extends StudyMethods
    with TableInfo<$StudyMethodsTable, StudyMethod> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    check: () => unitType.isIn(const ['定義', '機序', '鑑別', '画像所見', 'その他']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _problemFormatMeta = const VerificationMeta(
    'problemFormat',
  );
  @override
  late final GeneratedColumn<String> problemFormat = GeneratedColumn<String>(
    'problem_format',
    aliasedName,
    false,
    check: () => problemFormat.isIn(const ['選択肢', '穴埋め', '記述', '画像問題', '計算']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _methodNameMeta = const VerificationMeta(
    'methodName',
  );
  @override
  late final GeneratedColumn<String> methodName = GeneratedColumn<String>(
    'method_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    unitType,
    problemFormat,
    methodName,
    description,
    estimatedMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_methods';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyMethod> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('problem_format')) {
      context.handle(
        _problemFormatMeta,
        problemFormat.isAcceptableOrUnknown(
          data['problem_format']!,
          _problemFormatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_problemFormatMeta);
    }
    if (data.containsKey('method_name')) {
      context.handle(
        _methodNameMeta,
        methodName.isAcceptableOrUnknown(data['method_name']!, _methodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_methodNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_estimatedMinutesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyMethod map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyMethod(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      problemFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem_format'],
      )!,
      methodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
    );
  }

  @override
  $StudyMethodsTable createAlias(String alias) {
    return $StudyMethodsTable(attachedDatabase, alias);
  }
}

class StudyMethod extends DataClass implements Insertable<StudyMethod> {
  final int id;
  final String unitType;
  final String problemFormat;
  final String methodName;
  final String description;
  final int estimatedMinutes;
  const StudyMethod({
    required this.id,
    required this.unitType,
    required this.problemFormat,
    required this.methodName,
    required this.description,
    required this.estimatedMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['unit_type'] = Variable<String>(unitType);
    map['problem_format'] = Variable<String>(problemFormat);
    map['method_name'] = Variable<String>(methodName);
    map['description'] = Variable<String>(description);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    return map;
  }

  StudyMethodsCompanion toCompanion(bool nullToAbsent) {
    return StudyMethodsCompanion(
      id: Value(id),
      unitType: Value(unitType),
      problemFormat: Value(problemFormat),
      methodName: Value(methodName),
      description: Value(description),
      estimatedMinutes: Value(estimatedMinutes),
    );
  }

  factory StudyMethod.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyMethod(
      id: serializer.fromJson<int>(json['id']),
      unitType: serializer.fromJson<String>(json['unitType']),
      problemFormat: serializer.fromJson<String>(json['problemFormat']),
      methodName: serializer.fromJson<String>(json['methodName']),
      description: serializer.fromJson<String>(json['description']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'unitType': serializer.toJson<String>(unitType),
      'problemFormat': serializer.toJson<String>(problemFormat),
      'methodName': serializer.toJson<String>(methodName),
      'description': serializer.toJson<String>(description),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
    };
  }

  StudyMethod copyWith({
    int? id,
    String? unitType,
    String? problemFormat,
    String? methodName,
    String? description,
    int? estimatedMinutes,
  }) => StudyMethod(
    id: id ?? this.id,
    unitType: unitType ?? this.unitType,
    problemFormat: problemFormat ?? this.problemFormat,
    methodName: methodName ?? this.methodName,
    description: description ?? this.description,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
  );
  StudyMethod copyWithCompanion(StudyMethodsCompanion data) {
    return StudyMethod(
      id: data.id.present ? data.id.value : this.id,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      problemFormat: data.problemFormat.present
          ? data.problemFormat.value
          : this.problemFormat,
      methodName: data.methodName.present
          ? data.methodName.value
          : this.methodName,
      description: data.description.present
          ? data.description.value
          : this.description,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyMethod(')
          ..write('id: $id, ')
          ..write('unitType: $unitType, ')
          ..write('problemFormat: $problemFormat, ')
          ..write('methodName: $methodName, ')
          ..write('description: $description, ')
          ..write('estimatedMinutes: $estimatedMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    unitType,
    problemFormat,
    methodName,
    description,
    estimatedMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyMethod &&
          other.id == this.id &&
          other.unitType == this.unitType &&
          other.problemFormat == this.problemFormat &&
          other.methodName == this.methodName &&
          other.description == this.description &&
          other.estimatedMinutes == this.estimatedMinutes);
}

class StudyMethodsCompanion extends UpdateCompanion<StudyMethod> {
  final Value<int> id;
  final Value<String> unitType;
  final Value<String> problemFormat;
  final Value<String> methodName;
  final Value<String> description;
  final Value<int> estimatedMinutes;
  const StudyMethodsCompanion({
    this.id = const Value.absent(),
    this.unitType = const Value.absent(),
    this.problemFormat = const Value.absent(),
    this.methodName = const Value.absent(),
    this.description = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
  });
  StudyMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String unitType,
    required String problemFormat,
    required String methodName,
    required String description,
    required int estimatedMinutes,
  }) : unitType = Value(unitType),
       problemFormat = Value(problemFormat),
       methodName = Value(methodName),
       description = Value(description),
       estimatedMinutes = Value(estimatedMinutes);
  static Insertable<StudyMethod> custom({
    Expression<int>? id,
    Expression<String>? unitType,
    Expression<String>? problemFormat,
    Expression<String>? methodName,
    Expression<String>? description,
    Expression<int>? estimatedMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (unitType != null) 'unit_type': unitType,
      if (problemFormat != null) 'problem_format': problemFormat,
      if (methodName != null) 'method_name': methodName,
      if (description != null) 'description': description,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
    });
  }

  StudyMethodsCompanion copyWith({
    Value<int>? id,
    Value<String>? unitType,
    Value<String>? problemFormat,
    Value<String>? methodName,
    Value<String>? description,
    Value<int>? estimatedMinutes,
  }) {
    return StudyMethodsCompanion(
      id: id ?? this.id,
      unitType: unitType ?? this.unitType,
      problemFormat: problemFormat ?? this.problemFormat,
      methodName: methodName ?? this.methodName,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (problemFormat.present) {
      map['problem_format'] = Variable<String>(problemFormat.value);
    }
    if (methodName.present) {
      map['method_name'] = Variable<String>(methodName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyMethodsCompanion(')
          ..write('id: $id, ')
          ..write('unitType: $unitType, ')
          ..write('problemFormat: $problemFormat, ')
          ..write('methodName: $methodName, ')
          ..write('description: $description, ')
          ..write('estimatedMinutes: $estimatedMinutes')
          ..write(')'))
        .toString();
  }
}

class $UnitStatsTable extends UnitStats
    with TableInfo<$UnitStatsTable, UnitStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _examUnitIdMeta = const VerificationMeta(
    'examUnitId',
  );
  @override
  late final GeneratedColumn<int> examUnitId = GeneratedColumn<int>(
    'exam_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceCountMeta = const VerificationMeta(
    'sourceCount',
  );
  @override
  late final GeneratedColumn<int> sourceCount = GeneratedColumn<int>(
    'source_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _segmentCountMeta = const VerificationMeta(
    'segmentCount',
  );
  @override
  late final GeneratedColumn<int> segmentCount = GeneratedColumn<int>(
    'segment_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _claimCountMeta = const VerificationMeta(
    'claimCount',
  );
  @override
  late final GeneratedColumn<int> claimCount = GeneratedColumn<int>(
    'claim_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _evidenceCountMeta = const VerificationMeta(
    'evidenceCount',
  );
  @override
  late final GeneratedColumn<int> evidenceCount = GeneratedColumn<int>(
    'evidence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _conflictCountMeta = const VerificationMeta(
    'conflictCount',
  );
  @override
  late final GeneratedColumn<int> conflictCount = GeneratedColumn<int>(
    'conflict_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pointWeightMeta = const VerificationMeta(
    'pointWeight',
  );
  @override
  late final GeneratedColumn<int> pointWeight = GeneratedColumn<int>(
    'point_weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _frequencyManualOverrideMeta =
      const VerificationMeta('frequencyManualOverride');
  @override
  late final GeneratedColumn<bool> frequencyManualOverride =
      GeneratedColumn<bool>(
        'frequency_manual_override',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("frequency_manual_override" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _lastAuditedAtMeta = const VerificationMeta(
    'lastAuditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAuditedAt =
      GeneratedColumn<DateTime>(
        'last_audited_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examUnitId,
    sourceCount,
    segmentCount,
    claimCount,
    evidenceCount,
    conflictCount,
    pointWeight,
    frequency,
    frequencyManualOverride,
    lastAuditedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitStat> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_unit_id')) {
      context.handle(
        _examUnitIdMeta,
        examUnitId.isAcceptableOrUnknown(
          data['exam_unit_id']!,
          _examUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examUnitIdMeta);
    }
    if (data.containsKey('source_count')) {
      context.handle(
        _sourceCountMeta,
        sourceCount.isAcceptableOrUnknown(
          data['source_count']!,
          _sourceCountMeta,
        ),
      );
    }
    if (data.containsKey('segment_count')) {
      context.handle(
        _segmentCountMeta,
        segmentCount.isAcceptableOrUnknown(
          data['segment_count']!,
          _segmentCountMeta,
        ),
      );
    }
    if (data.containsKey('claim_count')) {
      context.handle(
        _claimCountMeta,
        claimCount.isAcceptableOrUnknown(data['claim_count']!, _claimCountMeta),
      );
    }
    if (data.containsKey('evidence_count')) {
      context.handle(
        _evidenceCountMeta,
        evidenceCount.isAcceptableOrUnknown(
          data['evidence_count']!,
          _evidenceCountMeta,
        ),
      );
    }
    if (data.containsKey('conflict_count')) {
      context.handle(
        _conflictCountMeta,
        conflictCount.isAcceptableOrUnknown(
          data['conflict_count']!,
          _conflictCountMeta,
        ),
      );
    }
    if (data.containsKey('point_weight')) {
      context.handle(
        _pointWeightMeta,
        pointWeight.isAcceptableOrUnknown(
          data['point_weight']!,
          _pointWeightMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('frequency_manual_override')) {
      context.handle(
        _frequencyManualOverrideMeta,
        frequencyManualOverride.isAcceptableOrUnknown(
          data['frequency_manual_override']!,
          _frequencyManualOverrideMeta,
        ),
      );
    }
    if (data.containsKey('last_audited_at')) {
      context.handle(
        _lastAuditedAtMeta,
        lastAuditedAt.isAcceptableOrUnknown(
          data['last_audited_at']!,
          _lastAuditedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {examUnitId},
  ];
  @override
  UnitStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitStat(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_unit_id'],
      )!,
      sourceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_count'],
      )!,
      segmentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}segment_count'],
      )!,
      claimCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claim_count'],
      )!,
      evidenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evidence_count'],
      )!,
      conflictCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conflict_count'],
      )!,
      pointWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_weight'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      )!,
      frequencyManualOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}frequency_manual_override'],
      )!,
      lastAuditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_audited_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UnitStatsTable createAlias(String alias) {
    return $UnitStatsTable(attachedDatabase, alias);
  }
}

class UnitStat extends DataClass implements Insertable<UnitStat> {
  final int id;
  final int examUnitId;
  final int sourceCount;
  final int segmentCount;
  final int claimCount;
  final int evidenceCount;
  final int conflictCount;
  final int pointWeight;
  final int frequency;
  final bool frequencyManualOverride;
  final DateTime? lastAuditedAt;
  final DateTime updatedAt;
  const UnitStat({
    required this.id,
    required this.examUnitId,
    required this.sourceCount,
    required this.segmentCount,
    required this.claimCount,
    required this.evidenceCount,
    required this.conflictCount,
    required this.pointWeight,
    required this.frequency,
    required this.frequencyManualOverride,
    this.lastAuditedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_unit_id'] = Variable<int>(examUnitId);
    map['source_count'] = Variable<int>(sourceCount);
    map['segment_count'] = Variable<int>(segmentCount);
    map['claim_count'] = Variable<int>(claimCount);
    map['evidence_count'] = Variable<int>(evidenceCount);
    map['conflict_count'] = Variable<int>(conflictCount);
    map['point_weight'] = Variable<int>(pointWeight);
    map['frequency'] = Variable<int>(frequency);
    map['frequency_manual_override'] = Variable<bool>(frequencyManualOverride);
    if (!nullToAbsent || lastAuditedAt != null) {
      map['last_audited_at'] = Variable<DateTime>(lastAuditedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UnitStatsCompanion toCompanion(bool nullToAbsent) {
    return UnitStatsCompanion(
      id: Value(id),
      examUnitId: Value(examUnitId),
      sourceCount: Value(sourceCount),
      segmentCount: Value(segmentCount),
      claimCount: Value(claimCount),
      evidenceCount: Value(evidenceCount),
      conflictCount: Value(conflictCount),
      pointWeight: Value(pointWeight),
      frequency: Value(frequency),
      frequencyManualOverride: Value(frequencyManualOverride),
      lastAuditedAt: lastAuditedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAuditedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UnitStat.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitStat(
      id: serializer.fromJson<int>(json['id']),
      examUnitId: serializer.fromJson<int>(json['examUnitId']),
      sourceCount: serializer.fromJson<int>(json['sourceCount']),
      segmentCount: serializer.fromJson<int>(json['segmentCount']),
      claimCount: serializer.fromJson<int>(json['claimCount']),
      evidenceCount: serializer.fromJson<int>(json['evidenceCount']),
      conflictCount: serializer.fromJson<int>(json['conflictCount']),
      pointWeight: serializer.fromJson<int>(json['pointWeight']),
      frequency: serializer.fromJson<int>(json['frequency']),
      frequencyManualOverride: serializer.fromJson<bool>(
        json['frequencyManualOverride'],
      ),
      lastAuditedAt: serializer.fromJson<DateTime?>(json['lastAuditedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examUnitId': serializer.toJson<int>(examUnitId),
      'sourceCount': serializer.toJson<int>(sourceCount),
      'segmentCount': serializer.toJson<int>(segmentCount),
      'claimCount': serializer.toJson<int>(claimCount),
      'evidenceCount': serializer.toJson<int>(evidenceCount),
      'conflictCount': serializer.toJson<int>(conflictCount),
      'pointWeight': serializer.toJson<int>(pointWeight),
      'frequency': serializer.toJson<int>(frequency),
      'frequencyManualOverride': serializer.toJson<bool>(
        frequencyManualOverride,
      ),
      'lastAuditedAt': serializer.toJson<DateTime?>(lastAuditedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UnitStat copyWith({
    int? id,
    int? examUnitId,
    int? sourceCount,
    int? segmentCount,
    int? claimCount,
    int? evidenceCount,
    int? conflictCount,
    int? pointWeight,
    int? frequency,
    bool? frequencyManualOverride,
    Value<DateTime?> lastAuditedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => UnitStat(
    id: id ?? this.id,
    examUnitId: examUnitId ?? this.examUnitId,
    sourceCount: sourceCount ?? this.sourceCount,
    segmentCount: segmentCount ?? this.segmentCount,
    claimCount: claimCount ?? this.claimCount,
    evidenceCount: evidenceCount ?? this.evidenceCount,
    conflictCount: conflictCount ?? this.conflictCount,
    pointWeight: pointWeight ?? this.pointWeight,
    frequency: frequency ?? this.frequency,
    frequencyManualOverride:
        frequencyManualOverride ?? this.frequencyManualOverride,
    lastAuditedAt: lastAuditedAt.present
        ? lastAuditedAt.value
        : this.lastAuditedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UnitStat copyWithCompanion(UnitStatsCompanion data) {
    return UnitStat(
      id: data.id.present ? data.id.value : this.id,
      examUnitId: data.examUnitId.present
          ? data.examUnitId.value
          : this.examUnitId,
      sourceCount: data.sourceCount.present
          ? data.sourceCount.value
          : this.sourceCount,
      segmentCount: data.segmentCount.present
          ? data.segmentCount.value
          : this.segmentCount,
      claimCount: data.claimCount.present
          ? data.claimCount.value
          : this.claimCount,
      evidenceCount: data.evidenceCount.present
          ? data.evidenceCount.value
          : this.evidenceCount,
      conflictCount: data.conflictCount.present
          ? data.conflictCount.value
          : this.conflictCount,
      pointWeight: data.pointWeight.present
          ? data.pointWeight.value
          : this.pointWeight,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      frequencyManualOverride: data.frequencyManualOverride.present
          ? data.frequencyManualOverride.value
          : this.frequencyManualOverride,
      lastAuditedAt: data.lastAuditedAt.present
          ? data.lastAuditedAt.value
          : this.lastAuditedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitStat(')
          ..write('id: $id, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('sourceCount: $sourceCount, ')
          ..write('segmentCount: $segmentCount, ')
          ..write('claimCount: $claimCount, ')
          ..write('evidenceCount: $evidenceCount, ')
          ..write('conflictCount: $conflictCount, ')
          ..write('pointWeight: $pointWeight, ')
          ..write('frequency: $frequency, ')
          ..write('frequencyManualOverride: $frequencyManualOverride, ')
          ..write('lastAuditedAt: $lastAuditedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examUnitId,
    sourceCount,
    segmentCount,
    claimCount,
    evidenceCount,
    conflictCount,
    pointWeight,
    frequency,
    frequencyManualOverride,
    lastAuditedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitStat &&
          other.id == this.id &&
          other.examUnitId == this.examUnitId &&
          other.sourceCount == this.sourceCount &&
          other.segmentCount == this.segmentCount &&
          other.claimCount == this.claimCount &&
          other.evidenceCount == this.evidenceCount &&
          other.conflictCount == this.conflictCount &&
          other.pointWeight == this.pointWeight &&
          other.frequency == this.frequency &&
          other.frequencyManualOverride == this.frequencyManualOverride &&
          other.lastAuditedAt == this.lastAuditedAt &&
          other.updatedAt == this.updatedAt);
}

class UnitStatsCompanion extends UpdateCompanion<UnitStat> {
  final Value<int> id;
  final Value<int> examUnitId;
  final Value<int> sourceCount;
  final Value<int> segmentCount;
  final Value<int> claimCount;
  final Value<int> evidenceCount;
  final Value<int> conflictCount;
  final Value<int> pointWeight;
  final Value<int> frequency;
  final Value<bool> frequencyManualOverride;
  final Value<DateTime?> lastAuditedAt;
  final Value<DateTime> updatedAt;
  const UnitStatsCompanion({
    this.id = const Value.absent(),
    this.examUnitId = const Value.absent(),
    this.sourceCount = const Value.absent(),
    this.segmentCount = const Value.absent(),
    this.claimCount = const Value.absent(),
    this.evidenceCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.pointWeight = const Value.absent(),
    this.frequency = const Value.absent(),
    this.frequencyManualOverride = const Value.absent(),
    this.lastAuditedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UnitStatsCompanion.insert({
    this.id = const Value.absent(),
    required int examUnitId,
    this.sourceCount = const Value.absent(),
    this.segmentCount = const Value.absent(),
    this.claimCount = const Value.absent(),
    this.evidenceCount = const Value.absent(),
    this.conflictCount = const Value.absent(),
    this.pointWeight = const Value.absent(),
    this.frequency = const Value.absent(),
    this.frequencyManualOverride = const Value.absent(),
    this.lastAuditedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : examUnitId = Value(examUnitId);
  static Insertable<UnitStat> custom({
    Expression<int>? id,
    Expression<int>? examUnitId,
    Expression<int>? sourceCount,
    Expression<int>? segmentCount,
    Expression<int>? claimCount,
    Expression<int>? evidenceCount,
    Expression<int>? conflictCount,
    Expression<int>? pointWeight,
    Expression<int>? frequency,
    Expression<bool>? frequencyManualOverride,
    Expression<DateTime>? lastAuditedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examUnitId != null) 'exam_unit_id': examUnitId,
      if (sourceCount != null) 'source_count': sourceCount,
      if (segmentCount != null) 'segment_count': segmentCount,
      if (claimCount != null) 'claim_count': claimCount,
      if (evidenceCount != null) 'evidence_count': evidenceCount,
      if (conflictCount != null) 'conflict_count': conflictCount,
      if (pointWeight != null) 'point_weight': pointWeight,
      if (frequency != null) 'frequency': frequency,
      if (frequencyManualOverride != null)
        'frequency_manual_override': frequencyManualOverride,
      if (lastAuditedAt != null) 'last_audited_at': lastAuditedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UnitStatsCompanion copyWith({
    Value<int>? id,
    Value<int>? examUnitId,
    Value<int>? sourceCount,
    Value<int>? segmentCount,
    Value<int>? claimCount,
    Value<int>? evidenceCount,
    Value<int>? conflictCount,
    Value<int>? pointWeight,
    Value<int>? frequency,
    Value<bool>? frequencyManualOverride,
    Value<DateTime?>? lastAuditedAt,
    Value<DateTime>? updatedAt,
  }) {
    return UnitStatsCompanion(
      id: id ?? this.id,
      examUnitId: examUnitId ?? this.examUnitId,
      sourceCount: sourceCount ?? this.sourceCount,
      segmentCount: segmentCount ?? this.segmentCount,
      claimCount: claimCount ?? this.claimCount,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      conflictCount: conflictCount ?? this.conflictCount,
      pointWeight: pointWeight ?? this.pointWeight,
      frequency: frequency ?? this.frequency,
      frequencyManualOverride:
          frequencyManualOverride ?? this.frequencyManualOverride,
      lastAuditedAt: lastAuditedAt ?? this.lastAuditedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examUnitId.present) {
      map['exam_unit_id'] = Variable<int>(examUnitId.value);
    }
    if (sourceCount.present) {
      map['source_count'] = Variable<int>(sourceCount.value);
    }
    if (segmentCount.present) {
      map['segment_count'] = Variable<int>(segmentCount.value);
    }
    if (claimCount.present) {
      map['claim_count'] = Variable<int>(claimCount.value);
    }
    if (evidenceCount.present) {
      map['evidence_count'] = Variable<int>(evidenceCount.value);
    }
    if (conflictCount.present) {
      map['conflict_count'] = Variable<int>(conflictCount.value);
    }
    if (pointWeight.present) {
      map['point_weight'] = Variable<int>(pointWeight.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (frequencyManualOverride.present) {
      map['frequency_manual_override'] = Variable<bool>(
        frequencyManualOverride.value,
      );
    }
    if (lastAuditedAt.present) {
      map['last_audited_at'] = Variable<DateTime>(lastAuditedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitStatsCompanion(')
          ..write('id: $id, ')
          ..write('examUnitId: $examUnitId, ')
          ..write('sourceCount: $sourceCount, ')
          ..write('segmentCount: $segmentCount, ')
          ..write('claimCount: $claimCount, ')
          ..write('evidenceCount: $evidenceCount, ')
          ..write('conflictCount: $conflictCount, ')
          ..write('pointWeight: $pointWeight, ')
          ..write('frequency: $frequency, ')
          ..write('frequencyManualOverride: $frequencyManualOverride, ')
          ..write('lastAuditedAt: $lastAuditedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $EvidencePacksTable extends EvidencePacks
    with TableInfo<$EvidencePacksTable, EvidencePack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidencePacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _claimIdMeta = const VerificationMeta(
    'claimId',
  );
  @override
  late final GeneratedColumn<int> claimId = GeneratedColumn<int>(
    'claim_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES claims (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentConfidenceMeta = const VerificationMeta(
    'contentConfidence',
  );
  @override
  late final GeneratedColumn<String> contentConfidence =
      GeneratedColumn<String>(
        'content_confidence',
        aliasedName,
        false,
        check: () => contentConfidence.isIn(const ['H', 'M', 'L']),
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('M'),
      );
  static const VerificationMeta _examConfidenceMeta = const VerificationMeta(
    'examConfidence',
  );
  @override
  late final GeneratedColumn<String> examConfidence = GeneratedColumn<String>(
    'exam_confidence',
    aliasedName,
    false,
    check: () => examConfidence.isIn(const ['H', 'M', 'L']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('M'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    claimId,
    createdAt,
    updatedAt,
    summary,
    contentConfidence,
    examConfidence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidencePack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('claim_id')) {
      context.handle(
        _claimIdMeta,
        claimId.isAcceptableOrUnknown(data['claim_id']!, _claimIdMeta),
      );
    } else if (isInserting) {
      context.missing(_claimIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('content_confidence')) {
      context.handle(
        _contentConfidenceMeta,
        contentConfidence.isAcceptableOrUnknown(
          data['content_confidence']!,
          _contentConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('exam_confidence')) {
      context.handle(
        _examConfidenceMeta,
        examConfidence.isAcceptableOrUnknown(
          data['exam_confidence']!,
          _examConfidenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {claimId},
  ];
  @override
  EvidencePack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidencePack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      claimId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claim_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      contentConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_confidence'],
      )!,
      examConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_confidence'],
      )!,
    );
  }

  @override
  $EvidencePacksTable createAlias(String alias) {
    return $EvidencePacksTable(attachedDatabase, alias);
  }
}

class EvidencePack extends DataClass implements Insertable<EvidencePack> {
  final int id;
  final int claimId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? summary;
  final String contentConfidence;
  final String examConfidence;
  const EvidencePack({
    required this.id,
    required this.claimId,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    required this.contentConfidence,
    required this.examConfidence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['claim_id'] = Variable<int>(claimId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['content_confidence'] = Variable<String>(contentConfidence);
    map['exam_confidence'] = Variable<String>(examConfidence);
    return map;
  }

  EvidencePacksCompanion toCompanion(bool nullToAbsent) {
    return EvidencePacksCompanion(
      id: Value(id),
      claimId: Value(claimId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      contentConfidence: Value(contentConfidence),
      examConfidence: Value(examConfidence),
    );
  }

  factory EvidencePack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidencePack(
      id: serializer.fromJson<int>(json['id']),
      claimId: serializer.fromJson<int>(json['claimId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      summary: serializer.fromJson<String?>(json['summary']),
      contentConfidence: serializer.fromJson<String>(json['contentConfidence']),
      examConfidence: serializer.fromJson<String>(json['examConfidence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'claimId': serializer.toJson<int>(claimId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'summary': serializer.toJson<String?>(summary),
      'contentConfidence': serializer.toJson<String>(contentConfidence),
      'examConfidence': serializer.toJson<String>(examConfidence),
    };
  }

  EvidencePack copyWith({
    int? id,
    int? claimId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> summary = const Value.absent(),
    String? contentConfidence,
    String? examConfidence,
  }) => EvidencePack(
    id: id ?? this.id,
    claimId: claimId ?? this.claimId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    summary: summary.present ? summary.value : this.summary,
    contentConfidence: contentConfidence ?? this.contentConfidence,
    examConfidence: examConfidence ?? this.examConfidence,
  );
  EvidencePack copyWithCompanion(EvidencePacksCompanion data) {
    return EvidencePack(
      id: data.id.present ? data.id.value : this.id,
      claimId: data.claimId.present ? data.claimId.value : this.claimId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      contentConfidence: data.contentConfidence.present
          ? data.contentConfidence.value
          : this.contentConfidence,
      examConfidence: data.examConfidence.present
          ? data.examConfidence.value
          : this.examConfidence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidencePack(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('summary: $summary, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('examConfidence: $examConfidence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    claimId,
    createdAt,
    updatedAt,
    summary,
    contentConfidence,
    examConfidence,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidencePack &&
          other.id == this.id &&
          other.claimId == this.claimId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.summary == this.summary &&
          other.contentConfidence == this.contentConfidence &&
          other.examConfidence == this.examConfidence);
}

class EvidencePacksCompanion extends UpdateCompanion<EvidencePack> {
  final Value<int> id;
  final Value<int> claimId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> summary;
  final Value<String> contentConfidence;
  final Value<String> examConfidence;
  const EvidencePacksCompanion({
    this.id = const Value.absent(),
    this.claimId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.examConfidence = const Value.absent(),
  });
  EvidencePacksCompanion.insert({
    this.id = const Value.absent(),
    required int claimId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentConfidence = const Value.absent(),
    this.examConfidence = const Value.absent(),
  }) : claimId = Value(claimId);
  static Insertable<EvidencePack> custom({
    Expression<int>? id,
    Expression<int>? claimId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? summary,
    Expression<String>? contentConfidence,
    Expression<String>? examConfidence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (claimId != null) 'claim_id': claimId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (summary != null) 'summary': summary,
      if (contentConfidence != null) 'content_confidence': contentConfidence,
      if (examConfidence != null) 'exam_confidence': examConfidence,
    });
  }

  EvidencePacksCompanion copyWith({
    Value<int>? id,
    Value<int>? claimId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? summary,
    Value<String>? contentConfidence,
    Value<String>? examConfidence,
  }) {
    return EvidencePacksCompanion(
      id: id ?? this.id,
      claimId: claimId ?? this.claimId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      contentConfidence: contentConfidence ?? this.contentConfidence,
      examConfidence: examConfidence ?? this.examConfidence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (claimId.present) {
      map['claim_id'] = Variable<int>(claimId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (contentConfidence.present) {
      map['content_confidence'] = Variable<String>(contentConfidence.value);
    }
    if (examConfidence.present) {
      map['exam_confidence'] = Variable<String>(examConfidence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidencePacksCompanion(')
          ..write('id: $id, ')
          ..write('claimId: $claimId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('summary: $summary, ')
          ..write('contentConfidence: $contentConfidence, ')
          ..write('examConfidence: $examConfidence')
          ..write(')'))
        .toString();
  }
}

class $EvidencePackItemsTable extends EvidencePackItems
    with TableInfo<$EvidencePackItemsTable, EvidencePackItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvidencePackItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _evidencePackIdMeta = const VerificationMeta(
    'evidencePackId',
  );
  @override
  late final GeneratedColumn<int> evidencePackId = GeneratedColumn<int>(
    'evidence_pack_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES evidence_packs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourceSegmentIdMeta = const VerificationMeta(
    'sourceSegmentId',
  );
  @override
  late final GeneratedColumn<int> sourceSegmentId = GeneratedColumn<int>(
    'source_segment_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES source_segments (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snippetMeta = const VerificationMeta(
    'snippet',
  );
  @override
  late final GeneratedColumn<String> snippet = GeneratedColumn<String>(
    'snippet',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    evidencePackId,
    sourceSegmentId,
    pageNumber,
    snippet,
    weight,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evidence_pack_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvidencePackItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('evidence_pack_id')) {
      context.handle(
        _evidencePackIdMeta,
        evidencePackId.isAcceptableOrUnknown(
          data['evidence_pack_id']!,
          _evidencePackIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidencePackIdMeta);
    }
    if (data.containsKey('source_segment_id')) {
      context.handle(
        _sourceSegmentIdMeta,
        sourceSegmentId.isAcceptableOrUnknown(
          data['source_segment_id']!,
          _sourceSegmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceSegmentIdMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    }
    if (data.containsKey('snippet')) {
      context.handle(
        _snippetMeta,
        snippet.isAcceptableOrUnknown(data['snippet']!, _snippetMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {evidencePackId, sourceSegmentId},
  ];
  @override
  EvidencePackItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvidencePackItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      evidencePackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evidence_pack_id'],
      )!,
      sourceSegmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_segment_id'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      ),
      snippet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snippet'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EvidencePackItemsTable createAlias(String alias) {
    return $EvidencePackItemsTable(attachedDatabase, alias);
  }
}

class EvidencePackItem extends DataClass
    implements Insertable<EvidencePackItem> {
  final int id;
  final int evidencePackId;
  final int sourceSegmentId;
  final int? pageNumber;
  final String? snippet;
  final int weight;
  final DateTime createdAt;
  const EvidencePackItem({
    required this.id,
    required this.evidencePackId,
    required this.sourceSegmentId,
    this.pageNumber,
    this.snippet,
    required this.weight,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['evidence_pack_id'] = Variable<int>(evidencePackId);
    map['source_segment_id'] = Variable<int>(sourceSegmentId);
    if (!nullToAbsent || pageNumber != null) {
      map['page_number'] = Variable<int>(pageNumber);
    }
    if (!nullToAbsent || snippet != null) {
      map['snippet'] = Variable<String>(snippet);
    }
    map['weight'] = Variable<int>(weight);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EvidencePackItemsCompanion toCompanion(bool nullToAbsent) {
    return EvidencePackItemsCompanion(
      id: Value(id),
      evidencePackId: Value(evidencePackId),
      sourceSegmentId: Value(sourceSegmentId),
      pageNumber: pageNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNumber),
      snippet: snippet == null && nullToAbsent
          ? const Value.absent()
          : Value(snippet),
      weight: Value(weight),
      createdAt: Value(createdAt),
    );
  }

  factory EvidencePackItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvidencePackItem(
      id: serializer.fromJson<int>(json['id']),
      evidencePackId: serializer.fromJson<int>(json['evidencePackId']),
      sourceSegmentId: serializer.fromJson<int>(json['sourceSegmentId']),
      pageNumber: serializer.fromJson<int?>(json['pageNumber']),
      snippet: serializer.fromJson<String?>(json['snippet']),
      weight: serializer.fromJson<int>(json['weight']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'evidencePackId': serializer.toJson<int>(evidencePackId),
      'sourceSegmentId': serializer.toJson<int>(sourceSegmentId),
      'pageNumber': serializer.toJson<int?>(pageNumber),
      'snippet': serializer.toJson<String?>(snippet),
      'weight': serializer.toJson<int>(weight),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  EvidencePackItem copyWith({
    int? id,
    int? evidencePackId,
    int? sourceSegmentId,
    Value<int?> pageNumber = const Value.absent(),
    Value<String?> snippet = const Value.absent(),
    int? weight,
    DateTime? createdAt,
  }) => EvidencePackItem(
    id: id ?? this.id,
    evidencePackId: evidencePackId ?? this.evidencePackId,
    sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
    pageNumber: pageNumber.present ? pageNumber.value : this.pageNumber,
    snippet: snippet.present ? snippet.value : this.snippet,
    weight: weight ?? this.weight,
    createdAt: createdAt ?? this.createdAt,
  );
  EvidencePackItem copyWithCompanion(EvidencePackItemsCompanion data) {
    return EvidencePackItem(
      id: data.id.present ? data.id.value : this.id,
      evidencePackId: data.evidencePackId.present
          ? data.evidencePackId.value
          : this.evidencePackId,
      sourceSegmentId: data.sourceSegmentId.present
          ? data.sourceSegmentId.value
          : this.sourceSegmentId,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      snippet: data.snippet.present ? data.snippet.value : this.snippet,
      weight: data.weight.present ? data.weight.value : this.weight,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvidencePackItem(')
          ..write('id: $id, ')
          ..write('evidencePackId: $evidencePackId, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('snippet: $snippet, ')
          ..write('weight: $weight, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    evidencePackId,
    sourceSegmentId,
    pageNumber,
    snippet,
    weight,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvidencePackItem &&
          other.id == this.id &&
          other.evidencePackId == this.evidencePackId &&
          other.sourceSegmentId == this.sourceSegmentId &&
          other.pageNumber == this.pageNumber &&
          other.snippet == this.snippet &&
          other.weight == this.weight &&
          other.createdAt == this.createdAt);
}

class EvidencePackItemsCompanion extends UpdateCompanion<EvidencePackItem> {
  final Value<int> id;
  final Value<int> evidencePackId;
  final Value<int> sourceSegmentId;
  final Value<int?> pageNumber;
  final Value<String?> snippet;
  final Value<int> weight;
  final Value<DateTime> createdAt;
  const EvidencePackItemsCompanion({
    this.id = const Value.absent(),
    this.evidencePackId = const Value.absent(),
    this.sourceSegmentId = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.snippet = const Value.absent(),
    this.weight = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EvidencePackItemsCompanion.insert({
    this.id = const Value.absent(),
    required int evidencePackId,
    required int sourceSegmentId,
    this.pageNumber = const Value.absent(),
    this.snippet = const Value.absent(),
    this.weight = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : evidencePackId = Value(evidencePackId),
       sourceSegmentId = Value(sourceSegmentId);
  static Insertable<EvidencePackItem> custom({
    Expression<int>? id,
    Expression<int>? evidencePackId,
    Expression<int>? sourceSegmentId,
    Expression<int>? pageNumber,
    Expression<String>? snippet,
    Expression<int>? weight,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (evidencePackId != null) 'evidence_pack_id': evidencePackId,
      if (sourceSegmentId != null) 'source_segment_id': sourceSegmentId,
      if (pageNumber != null) 'page_number': pageNumber,
      if (snippet != null) 'snippet': snippet,
      if (weight != null) 'weight': weight,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EvidencePackItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? evidencePackId,
    Value<int>? sourceSegmentId,
    Value<int?>? pageNumber,
    Value<String?>? snippet,
    Value<int>? weight,
    Value<DateTime>? createdAt,
  }) {
    return EvidencePackItemsCompanion(
      id: id ?? this.id,
      evidencePackId: evidencePackId ?? this.evidencePackId,
      sourceSegmentId: sourceSegmentId ?? this.sourceSegmentId,
      pageNumber: pageNumber ?? this.pageNumber,
      snippet: snippet ?? this.snippet,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (evidencePackId.present) {
      map['evidence_pack_id'] = Variable<int>(evidencePackId.value);
    }
    if (sourceSegmentId.present) {
      map['source_segment_id'] = Variable<int>(sourceSegmentId.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (snippet.present) {
      map['snippet'] = Variable<String>(snippet.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvidencePackItemsCompanion(')
          ..write('id: $id, ')
          ..write('evidencePackId: $evidencePackId, ')
          ..write('sourceSegmentId: $sourceSegmentId, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('snippet: $snippet, ')
          ..write('weight: $weight, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UnitMergeHistoryTable extends UnitMergeHistory
    with TableInfo<$UnitMergeHistoryTable, UnitMergeHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitMergeHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_units (id) ON DELETE NO ACTION',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mergedAtMeta = const VerificationMeta(
    'mergedAt',
  );
  @override
  late final GeneratedColumn<DateTime> mergedAt = GeneratedColumn<DateTime>(
    'merged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _movedClaimIdsMeta = const VerificationMeta(
    'movedClaimIds',
  );
  @override
  late final GeneratedColumn<String> movedClaimIds = GeneratedColumn<String>(
    'moved_claim_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childTitleMeta = const VerificationMeta(
    'childTitle',
  );
  @override
  late final GeneratedColumn<String> childTitle = GeneratedColumn<String>(
    'child_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childUnitTypeMeta = const VerificationMeta(
    'childUnitType',
  );
  @override
  late final GeneratedColumn<String> childUnitType = GeneratedColumn<String>(
    'child_unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('定義'),
  );
  static const VerificationMeta _childDescriptionMeta = const VerificationMeta(
    'childDescription',
  );
  @override
  late final GeneratedColumn<String> childDescription = GeneratedColumn<String>(
    'child_description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _childConfidenceLevelMeta =
      const VerificationMeta('childConfidenceLevel');
  @override
  late final GeneratedColumn<String> childConfidenceLevel =
      GeneratedColumn<String>(
        'child_confidence_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('medium'),
      );
  static const VerificationMeta _childExamConfidenceMeta =
      const VerificationMeta('childExamConfidence');
  @override
  late final GeneratedColumn<String> childExamConfidence =
      GeneratedColumn<String>(
        'child_exam_confidence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('M'),
      );
  static const VerificationMeta _childAuditStatusMeta = const VerificationMeta(
    'childAuditStatus',
  );
  @override
  late final GeneratedColumn<String> childAuditStatus = GeneratedColumn<String>(
    'child_audit_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Uncovered'),
  );
  static const VerificationMeta _childSortOrderMeta = const VerificationMeta(
    'childSortOrder',
  );
  @override
  late final GeneratedColumn<int> childSortOrder = GeneratedColumn<int>(
    'child_sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _undoneAtMeta = const VerificationMeta(
    'undoneAt',
  );
  @override
  late final GeneratedColumn<DateTime> undoneAt = GeneratedColumn<DateTime>(
    'undone_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    childId,
    mergedAt,
    movedClaimIds,
    childTitle,
    childUnitType,
    childDescription,
    childConfidenceLevel,
    childExamConfidence,
    childAuditStatus,
    childSortOrder,
    undoneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'unit_merge_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<UnitMergeHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('merged_at')) {
      context.handle(
        _mergedAtMeta,
        mergedAt.isAcceptableOrUnknown(data['merged_at']!, _mergedAtMeta),
      );
    }
    if (data.containsKey('moved_claim_ids')) {
      context.handle(
        _movedClaimIdsMeta,
        movedClaimIds.isAcceptableOrUnknown(
          data['moved_claim_ids']!,
          _movedClaimIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movedClaimIdsMeta);
    }
    if (data.containsKey('child_title')) {
      context.handle(
        _childTitleMeta,
        childTitle.isAcceptableOrUnknown(data['child_title']!, _childTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_childTitleMeta);
    }
    if (data.containsKey('child_unit_type')) {
      context.handle(
        _childUnitTypeMeta,
        childUnitType.isAcceptableOrUnknown(
          data['child_unit_type']!,
          _childUnitTypeMeta,
        ),
      );
    }
    if (data.containsKey('child_description')) {
      context.handle(
        _childDescriptionMeta,
        childDescription.isAcceptableOrUnknown(
          data['child_description']!,
          _childDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('child_confidence_level')) {
      context.handle(
        _childConfidenceLevelMeta,
        childConfidenceLevel.isAcceptableOrUnknown(
          data['child_confidence_level']!,
          _childConfidenceLevelMeta,
        ),
      );
    }
    if (data.containsKey('child_exam_confidence')) {
      context.handle(
        _childExamConfidenceMeta,
        childExamConfidence.isAcceptableOrUnknown(
          data['child_exam_confidence']!,
          _childExamConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('child_audit_status')) {
      context.handle(
        _childAuditStatusMeta,
        childAuditStatus.isAcceptableOrUnknown(
          data['child_audit_status']!,
          _childAuditStatusMeta,
        ),
      );
    }
    if (data.containsKey('child_sort_order')) {
      context.handle(
        _childSortOrderMeta,
        childSortOrder.isAcceptableOrUnknown(
          data['child_sort_order']!,
          _childSortOrderMeta,
        ),
      );
    }
    if (data.containsKey('undone_at')) {
      context.handle(
        _undoneAtMeta,
        undoneAt.isAcceptableOrUnknown(data['undone_at']!, _undoneAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitMergeHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitMergeHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      mergedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}merged_at'],
      )!,
      movedClaimIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moved_claim_ids'],
      )!,
      childTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_title'],
      )!,
      childUnitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_unit_type'],
      )!,
      childDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_description'],
      ),
      childConfidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_confidence_level'],
      )!,
      childExamConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_exam_confidence'],
      )!,
      childAuditStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_audit_status'],
      )!,
      childSortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_sort_order'],
      )!,
      undoneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}undone_at'],
      ),
    );
  }

  @override
  $UnitMergeHistoryTable createAlias(String alias) {
    return $UnitMergeHistoryTable(attachedDatabase, alias);
  }
}

class UnitMergeHistoryData extends DataClass
    implements Insertable<UnitMergeHistoryData> {
  final int id;
  final int parentId;
  final int childId;
  final DateTime mergedAt;
  final String movedClaimIds;
  final String childTitle;
  final String childUnitType;
  final String? childDescription;
  final String childConfidenceLevel;
  final String childExamConfidence;
  final String childAuditStatus;
  final int childSortOrder;
  final DateTime? undoneAt;
  const UnitMergeHistoryData({
    required this.id,
    required this.parentId,
    required this.childId,
    required this.mergedAt,
    required this.movedClaimIds,
    required this.childTitle,
    required this.childUnitType,
    this.childDescription,
    required this.childConfidenceLevel,
    required this.childExamConfidence,
    required this.childAuditStatus,
    required this.childSortOrder,
    this.undoneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['parent_id'] = Variable<int>(parentId);
    map['child_id'] = Variable<int>(childId);
    map['merged_at'] = Variable<DateTime>(mergedAt);
    map['moved_claim_ids'] = Variable<String>(movedClaimIds);
    map['child_title'] = Variable<String>(childTitle);
    map['child_unit_type'] = Variable<String>(childUnitType);
    if (!nullToAbsent || childDescription != null) {
      map['child_description'] = Variable<String>(childDescription);
    }
    map['child_confidence_level'] = Variable<String>(childConfidenceLevel);
    map['child_exam_confidence'] = Variable<String>(childExamConfidence);
    map['child_audit_status'] = Variable<String>(childAuditStatus);
    map['child_sort_order'] = Variable<int>(childSortOrder);
    if (!nullToAbsent || undoneAt != null) {
      map['undone_at'] = Variable<DateTime>(undoneAt);
    }
    return map;
  }

  UnitMergeHistoryCompanion toCompanion(bool nullToAbsent) {
    return UnitMergeHistoryCompanion(
      id: Value(id),
      parentId: Value(parentId),
      childId: Value(childId),
      mergedAt: Value(mergedAt),
      movedClaimIds: Value(movedClaimIds),
      childTitle: Value(childTitle),
      childUnitType: Value(childUnitType),
      childDescription: childDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(childDescription),
      childConfidenceLevel: Value(childConfidenceLevel),
      childExamConfidence: Value(childExamConfidence),
      childAuditStatus: Value(childAuditStatus),
      childSortOrder: Value(childSortOrder),
      undoneAt: undoneAt == null && nullToAbsent
          ? const Value.absent()
          : Value(undoneAt),
    );
  }

  factory UnitMergeHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitMergeHistoryData(
      id: serializer.fromJson<int>(json['id']),
      parentId: serializer.fromJson<int>(json['parentId']),
      childId: serializer.fromJson<int>(json['childId']),
      mergedAt: serializer.fromJson<DateTime>(json['mergedAt']),
      movedClaimIds: serializer.fromJson<String>(json['movedClaimIds']),
      childTitle: serializer.fromJson<String>(json['childTitle']),
      childUnitType: serializer.fromJson<String>(json['childUnitType']),
      childDescription: serializer.fromJson<String?>(json['childDescription']),
      childConfidenceLevel: serializer.fromJson<String>(
        json['childConfidenceLevel'],
      ),
      childExamConfidence: serializer.fromJson<String>(
        json['childExamConfidence'],
      ),
      childAuditStatus: serializer.fromJson<String>(json['childAuditStatus']),
      childSortOrder: serializer.fromJson<int>(json['childSortOrder']),
      undoneAt: serializer.fromJson<DateTime?>(json['undoneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parentId': serializer.toJson<int>(parentId),
      'childId': serializer.toJson<int>(childId),
      'mergedAt': serializer.toJson<DateTime>(mergedAt),
      'movedClaimIds': serializer.toJson<String>(movedClaimIds),
      'childTitle': serializer.toJson<String>(childTitle),
      'childUnitType': serializer.toJson<String>(childUnitType),
      'childDescription': serializer.toJson<String?>(childDescription),
      'childConfidenceLevel': serializer.toJson<String>(childConfidenceLevel),
      'childExamConfidence': serializer.toJson<String>(childExamConfidence),
      'childAuditStatus': serializer.toJson<String>(childAuditStatus),
      'childSortOrder': serializer.toJson<int>(childSortOrder),
      'undoneAt': serializer.toJson<DateTime?>(undoneAt),
    };
  }

  UnitMergeHistoryData copyWith({
    int? id,
    int? parentId,
    int? childId,
    DateTime? mergedAt,
    String? movedClaimIds,
    String? childTitle,
    String? childUnitType,
    Value<String?> childDescription = const Value.absent(),
    String? childConfidenceLevel,
    String? childExamConfidence,
    String? childAuditStatus,
    int? childSortOrder,
    Value<DateTime?> undoneAt = const Value.absent(),
  }) => UnitMergeHistoryData(
    id: id ?? this.id,
    parentId: parentId ?? this.parentId,
    childId: childId ?? this.childId,
    mergedAt: mergedAt ?? this.mergedAt,
    movedClaimIds: movedClaimIds ?? this.movedClaimIds,
    childTitle: childTitle ?? this.childTitle,
    childUnitType: childUnitType ?? this.childUnitType,
    childDescription: childDescription.present
        ? childDescription.value
        : this.childDescription,
    childConfidenceLevel: childConfidenceLevel ?? this.childConfidenceLevel,
    childExamConfidence: childExamConfidence ?? this.childExamConfidence,
    childAuditStatus: childAuditStatus ?? this.childAuditStatus,
    childSortOrder: childSortOrder ?? this.childSortOrder,
    undoneAt: undoneAt.present ? undoneAt.value : this.undoneAt,
  );
  UnitMergeHistoryData copyWithCompanion(UnitMergeHistoryCompanion data) {
    return UnitMergeHistoryData(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      childId: data.childId.present ? data.childId.value : this.childId,
      mergedAt: data.mergedAt.present ? data.mergedAt.value : this.mergedAt,
      movedClaimIds: data.movedClaimIds.present
          ? data.movedClaimIds.value
          : this.movedClaimIds,
      childTitle: data.childTitle.present
          ? data.childTitle.value
          : this.childTitle,
      childUnitType: data.childUnitType.present
          ? data.childUnitType.value
          : this.childUnitType,
      childDescription: data.childDescription.present
          ? data.childDescription.value
          : this.childDescription,
      childConfidenceLevel: data.childConfidenceLevel.present
          ? data.childConfidenceLevel.value
          : this.childConfidenceLevel,
      childExamConfidence: data.childExamConfidence.present
          ? data.childExamConfidence.value
          : this.childExamConfidence,
      childAuditStatus: data.childAuditStatus.present
          ? data.childAuditStatus.value
          : this.childAuditStatus,
      childSortOrder: data.childSortOrder.present
          ? data.childSortOrder.value
          : this.childSortOrder,
      undoneAt: data.undoneAt.present ? data.undoneAt.value : this.undoneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitMergeHistoryData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('childId: $childId, ')
          ..write('mergedAt: $mergedAt, ')
          ..write('movedClaimIds: $movedClaimIds, ')
          ..write('childTitle: $childTitle, ')
          ..write('childUnitType: $childUnitType, ')
          ..write('childDescription: $childDescription, ')
          ..write('childConfidenceLevel: $childConfidenceLevel, ')
          ..write('childExamConfidence: $childExamConfidence, ')
          ..write('childAuditStatus: $childAuditStatus, ')
          ..write('childSortOrder: $childSortOrder, ')
          ..write('undoneAt: $undoneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    childId,
    mergedAt,
    movedClaimIds,
    childTitle,
    childUnitType,
    childDescription,
    childConfidenceLevel,
    childExamConfidence,
    childAuditStatus,
    childSortOrder,
    undoneAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitMergeHistoryData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.childId == this.childId &&
          other.mergedAt == this.mergedAt &&
          other.movedClaimIds == this.movedClaimIds &&
          other.childTitle == this.childTitle &&
          other.childUnitType == this.childUnitType &&
          other.childDescription == this.childDescription &&
          other.childConfidenceLevel == this.childConfidenceLevel &&
          other.childExamConfidence == this.childExamConfidence &&
          other.childAuditStatus == this.childAuditStatus &&
          other.childSortOrder == this.childSortOrder &&
          other.undoneAt == this.undoneAt);
}

class UnitMergeHistoryCompanion extends UpdateCompanion<UnitMergeHistoryData> {
  final Value<int> id;
  final Value<int> parentId;
  final Value<int> childId;
  final Value<DateTime> mergedAt;
  final Value<String> movedClaimIds;
  final Value<String> childTitle;
  final Value<String> childUnitType;
  final Value<String?> childDescription;
  final Value<String> childConfidenceLevel;
  final Value<String> childExamConfidence;
  final Value<String> childAuditStatus;
  final Value<int> childSortOrder;
  final Value<DateTime?> undoneAt;
  const UnitMergeHistoryCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.childId = const Value.absent(),
    this.mergedAt = const Value.absent(),
    this.movedClaimIds = const Value.absent(),
    this.childTitle = const Value.absent(),
    this.childUnitType = const Value.absent(),
    this.childDescription = const Value.absent(),
    this.childConfidenceLevel = const Value.absent(),
    this.childExamConfidence = const Value.absent(),
    this.childAuditStatus = const Value.absent(),
    this.childSortOrder = const Value.absent(),
    this.undoneAt = const Value.absent(),
  });
  UnitMergeHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int parentId,
    required int childId,
    this.mergedAt = const Value.absent(),
    required String movedClaimIds,
    required String childTitle,
    this.childUnitType = const Value.absent(),
    this.childDescription = const Value.absent(),
    this.childConfidenceLevel = const Value.absent(),
    this.childExamConfidence = const Value.absent(),
    this.childAuditStatus = const Value.absent(),
    this.childSortOrder = const Value.absent(),
    this.undoneAt = const Value.absent(),
  }) : parentId = Value(parentId),
       childId = Value(childId),
       movedClaimIds = Value(movedClaimIds),
       childTitle = Value(childTitle);
  static Insertable<UnitMergeHistoryData> custom({
    Expression<int>? id,
    Expression<int>? parentId,
    Expression<int>? childId,
    Expression<DateTime>? mergedAt,
    Expression<String>? movedClaimIds,
    Expression<String>? childTitle,
    Expression<String>? childUnitType,
    Expression<String>? childDescription,
    Expression<String>? childConfidenceLevel,
    Expression<String>? childExamConfidence,
    Expression<String>? childAuditStatus,
    Expression<int>? childSortOrder,
    Expression<DateTime>? undoneAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (childId != null) 'child_id': childId,
      if (mergedAt != null) 'merged_at': mergedAt,
      if (movedClaimIds != null) 'moved_claim_ids': movedClaimIds,
      if (childTitle != null) 'child_title': childTitle,
      if (childUnitType != null) 'child_unit_type': childUnitType,
      if (childDescription != null) 'child_description': childDescription,
      if (childConfidenceLevel != null)
        'child_confidence_level': childConfidenceLevel,
      if (childExamConfidence != null)
        'child_exam_confidence': childExamConfidence,
      if (childAuditStatus != null) 'child_audit_status': childAuditStatus,
      if (childSortOrder != null) 'child_sort_order': childSortOrder,
      if (undoneAt != null) 'undone_at': undoneAt,
    });
  }

  UnitMergeHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? parentId,
    Value<int>? childId,
    Value<DateTime>? mergedAt,
    Value<String>? movedClaimIds,
    Value<String>? childTitle,
    Value<String>? childUnitType,
    Value<String?>? childDescription,
    Value<String>? childConfidenceLevel,
    Value<String>? childExamConfidence,
    Value<String>? childAuditStatus,
    Value<int>? childSortOrder,
    Value<DateTime?>? undoneAt,
  }) {
    return UnitMergeHistoryCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      childId: childId ?? this.childId,
      mergedAt: mergedAt ?? this.mergedAt,
      movedClaimIds: movedClaimIds ?? this.movedClaimIds,
      childTitle: childTitle ?? this.childTitle,
      childUnitType: childUnitType ?? this.childUnitType,
      childDescription: childDescription ?? this.childDescription,
      childConfidenceLevel: childConfidenceLevel ?? this.childConfidenceLevel,
      childExamConfidence: childExamConfidence ?? this.childExamConfidence,
      childAuditStatus: childAuditStatus ?? this.childAuditStatus,
      childSortOrder: childSortOrder ?? this.childSortOrder,
      undoneAt: undoneAt ?? this.undoneAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (mergedAt.present) {
      map['merged_at'] = Variable<DateTime>(mergedAt.value);
    }
    if (movedClaimIds.present) {
      map['moved_claim_ids'] = Variable<String>(movedClaimIds.value);
    }
    if (childTitle.present) {
      map['child_title'] = Variable<String>(childTitle.value);
    }
    if (childUnitType.present) {
      map['child_unit_type'] = Variable<String>(childUnitType.value);
    }
    if (childDescription.present) {
      map['child_description'] = Variable<String>(childDescription.value);
    }
    if (childConfidenceLevel.present) {
      map['child_confidence_level'] = Variable<String>(
        childConfidenceLevel.value,
      );
    }
    if (childExamConfidence.present) {
      map['child_exam_confidence'] = Variable<String>(
        childExamConfidence.value,
      );
    }
    if (childAuditStatus.present) {
      map['child_audit_status'] = Variable<String>(childAuditStatus.value);
    }
    if (childSortOrder.present) {
      map['child_sort_order'] = Variable<int>(childSortOrder.value);
    }
    if (undoneAt.present) {
      map['undone_at'] = Variable<DateTime>(undoneAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitMergeHistoryCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('childId: $childId, ')
          ..write('mergedAt: $mergedAt, ')
          ..write('movedClaimIds: $movedClaimIds, ')
          ..write('childTitle: $childTitle, ')
          ..write('childUnitType: $childUnitType, ')
          ..write('childDescription: $childDescription, ')
          ..write('childConfidenceLevel: $childConfidenceLevel, ')
          ..write('childExamConfidence: $childExamConfidence, ')
          ..write('childAuditStatus: $childAuditStatus, ')
          ..write('childSortOrder: $childSortOrder, ')
          ..write('undoneAt: $undoneAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $SourceSegmentsTable sourceSegments = $SourceSegmentsTable(this);
  late final $ExamUnitsTable examUnits = $ExamUnitsTable(this);
  late final $ClaimsTable claims = $ClaimsTable(this);
  late final $EvidenceLinksTable evidenceLinks = $EvidenceLinksTable(this);
  late final $AuditsTable audits = $AuditsTable(this);
  late final $ConflictsTable conflicts = $ConflictsTable(this);
  late final $StudyMethodsTable studyMethods = $StudyMethodsTable(this);
  late final $UnitStatsTable unitStats = $UnitStatsTable(this);
  late final $EvidencePacksTable evidencePacks = $EvidencePacksTable(this);
  late final $EvidencePackItemsTable evidencePackItems =
      $EvidencePackItemsTable(this);
  late final $UnitMergeHistoryTable unitMergeHistory = $UnitMergeHistoryTable(
    this,
  );
  late final SourcesDao sourcesDao = SourcesDao(this as AppDatabase);
  late final ExamUnitsDao examUnitsDao = ExamUnitsDao(this as AppDatabase);
  late final ClaimsDao claimsDao = ClaimsDao(this as AppDatabase);
  late final AuditDao auditDao = AuditDao(this as AppDatabase);
  late final DashboardDao dashboardDao = DashboardDao(this as AppDatabase);
  late final SearchDao searchDao = SearchDao(this as AppDatabase);
  late final StudyMethodsDao studyMethodsDao = StudyMethodsDao(
    this as AppDatabase,
  );
  late final EvidencePacksDao evidencePacksDao = EvidencePacksDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sources,
    sourceSegments,
    examUnits,
    claims,
    evidenceLinks,
    audits,
    conflicts,
    studyMethods,
    unitStats,
    evidencePacks,
    evidencePackItems,
    unitMergeHistory,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sources',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('source_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('claims', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'source_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'source_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('audits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('audits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'source_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'audits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('conflicts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exam_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('unit_stats', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'claims',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_packs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'evidence_packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_pack_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'source_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evidence_pack_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SourcesTableCreateCompanionBuilder =
    SourcesCompanion Function({
      Value<int> id,
      required String fileName,
      required String filePath,
      Value<String> sourceType,
      Value<int?> fileSize,
      Value<int?> pageCount,
      Value<String?> title,
      Value<DateTime> importedAt,
    });
typedef $$SourcesTableUpdateCompanionBuilder =
    SourcesCompanion Function({
      Value<int> id,
      Value<String> fileName,
      Value<String> filePath,
      Value<String> sourceType,
      Value<int?> fileSize,
      Value<int?> pageCount,
      Value<String?> title,
      Value<DateTime> importedAt,
    });

final class $$SourcesTableReferences
    extends BaseReferences<_$AppDatabase, $SourcesTable, Source> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SourceSegmentsTable, List<SourceSegment>>
  _sourceSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sourceSegments,
    aliasName: $_aliasNameGenerator(db.sources.id, db.sourceSegments.sourceId),
  );

  $$SourceSegmentsTableProcessedTableManager get sourceSegmentsRefs {
    final manager = $$SourceSegmentsTableTableManager(
      $_db,
      $_db.sourceSegments,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sourceSegmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sourceSegmentsRefs(
    Expression<bool> Function($$SourceSegmentsTableFilterComposer f) f,
  ) {
    final $$SourceSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get sourceType => $composableBuilder(
    column: $table.sourceType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> sourceSegmentsRefs<T extends Object>(
    Expression<T> Function($$SourceSegmentsTableAnnotationComposer a) f,
  ) {
    final $$SourceSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourcesTable,
          Source,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (Source, $$SourcesTableReferences),
          Source,
          PrefetchHooks Function({bool sourceSegmentsRefs})
        > {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> sourceType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                fileName: fileName,
                filePath: filePath,
                sourceType: sourceType,
                fileSize: fileSize,
                pageCount: pageCount,
                title: title,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fileName,
                required String filePath,
                Value<String> sourceType = const Value.absent(),
                Value<int?> fileSize = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                fileName: fileName,
                filePath: filePath,
                sourceType: sourceType,
                fileSize: fileSize,
                pageCount: pageCount,
                title: title,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sourceSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sourceSegmentsRefs) db.sourceSegments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sourceSegmentsRefs)
                    await $_getPrefetchedData<
                      Source,
                      $SourcesTable,
                      SourceSegment
                    >(
                      currentTable: table,
                      referencedTable: $$SourcesTableReferences
                          ._sourceSegmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$SourcesTableReferences(
                        db,
                        table,
                        p0,
                      ).sourceSegmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourcesTable,
      Source,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (Source, $$SourcesTableReferences),
      Source,
      PrefetchHooks Function({bool sourceSegmentsRefs})
    >;
typedef $$SourceSegmentsTableCreateCompanionBuilder =
    SourceSegmentsCompanion Function({
      Value<int> id,
      required int sourceId,
      required int pageNumber,
      Value<String> content,
      Value<String> segmentType,
      Value<String> contentConfidence,
      Value<DateTime> createdAt,
    });
typedef $$SourceSegmentsTableUpdateCompanionBuilder =
    SourceSegmentsCompanion Function({
      Value<int> id,
      Value<int> sourceId,
      Value<int> pageNumber,
      Value<String> content,
      Value<String> segmentType,
      Value<String> contentConfidence,
      Value<DateTime> createdAt,
    });

final class $$SourceSegmentsTableReferences
    extends BaseReferences<_$AppDatabase, $SourceSegmentsTable, SourceSegment> {
  $$SourceSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SourcesTable _sourceIdTable(_$AppDatabase db) =>
      db.sources.createAlias(
        $_aliasNameGenerator(db.sourceSegments.sourceId, db.sources.id),
      );

  $$SourcesTableProcessedTableManager get sourceId {
    final $_column = $_itemColumn<int>('source_id')!;

    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EvidenceLinksTable, List<EvidenceLink>>
  _evidenceLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.evidenceLinks,
    aliasName: $_aliasNameGenerator(
      db.sourceSegments.id,
      db.evidenceLinks.sourceSegmentId,
    ),
  );

  $$EvidenceLinksTableProcessedTableManager get evidenceLinksRefs {
    final manager = $$EvidenceLinksTableTableManager(
      $_db,
      $_db.evidenceLinks,
    ).filter((f) => f.sourceSegmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenceLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditsTable, List<Audit>> _auditsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.audits,
    aliasName: $_aliasNameGenerator(
      db.sourceSegments.id,
      db.audits.sourceSegmentId,
    ),
  );

  $$AuditsTableProcessedTableManager get auditsRefs {
    final manager = $$AuditsTableTableManager(
      $_db,
      $_db.audits,
    ).filter((f) => f.sourceSegmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConflictsTable, List<Conflict>>
  _conflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conflicts,
    aliasName: $_aliasNameGenerator(
      db.sourceSegments.id,
      db.conflicts.sourceSegmentId,
    ),
  );

  $$ConflictsTableProcessedTableManager get conflictsRefs {
    final manager = $$ConflictsTableTableManager(
      $_db,
      $_db.conflicts,
    ).filter((f) => f.sourceSegmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidencePackItemsTable, List<EvidencePackItem>>
  _evidencePackItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidencePackItems,
        aliasName: $_aliasNameGenerator(
          db.sourceSegments.id,
          db.evidencePackItems.sourceSegmentId,
        ),
      );

  $$EvidencePackItemsTableProcessedTableManager get evidencePackItemsRefs {
    final manager = $$EvidencePackItemsTableTableManager(
      $_db,
      $_db.evidencePackItems,
    ).filter((f) => f.sourceSegmentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidencePackItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourceSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SourceSegmentsTable> {
  $$SourceSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentType => $composableBuilder(
    column: $table.segmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> evidenceLinksRefs(
    Expression<bool> Function($$EvidenceLinksTableFilterComposer f) f,
  ) {
    final $$EvidenceLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceLinks,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceLinksTableFilterComposer(
            $db: $db,
            $table: $db.evidenceLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditsRefs(
    Expression<bool> Function($$AuditsTableFilterComposer f) f,
  ) {
    final $$AuditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableFilterComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conflictsRefs(
    Expression<bool> Function($$ConflictsTableFilterComposer f) f,
  ) {
    final $$ConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableFilterComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidencePackItemsRefs(
    Expression<bool> Function($$EvidencePackItemsTableFilterComposer f) f,
  ) {
    final $$EvidencePackItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencePackItems,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePackItemsTableFilterComposer(
            $db: $db,
            $table: $db.evidencePackItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourceSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SourceSegmentsTable> {
  $$SourceSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentType => $composableBuilder(
    column: $table.segmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SourceSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourceSegmentsTable> {
  $$SourceSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get segmentType => $composableBuilder(
    column: $table.segmentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> evidenceLinksRefs<T extends Object>(
    Expression<T> Function($$EvidenceLinksTableAnnotationComposer a) f,
  ) {
    final $$EvidenceLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceLinks,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditsRefs<T extends Object>(
    Expression<T> Function($$AuditsTableAnnotationComposer a) f,
  ) {
    final $$AuditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableAnnotationComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conflictsRefs<T extends Object>(
    Expression<T> Function($$ConflictsTableAnnotationComposer a) f,
  ) {
    final $$ConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.sourceSegmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidencePackItemsRefs<T extends Object>(
    Expression<T> Function($$EvidencePackItemsTableAnnotationComposer a) f,
  ) {
    final $$EvidencePackItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidencePackItems,
          getReferencedColumn: (t) => t.sourceSegmentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidencePackItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.evidencePackItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SourceSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SourceSegmentsTable,
          SourceSegment,
          $$SourceSegmentsTableFilterComposer,
          $$SourceSegmentsTableOrderingComposer,
          $$SourceSegmentsTableAnnotationComposer,
          $$SourceSegmentsTableCreateCompanionBuilder,
          $$SourceSegmentsTableUpdateCompanionBuilder,
          (SourceSegment, $$SourceSegmentsTableReferences),
          SourceSegment,
          PrefetchHooks Function({
            bool sourceId,
            bool evidenceLinksRefs,
            bool auditsRefs,
            bool conflictsRefs,
            bool evidencePackItemsRefs,
          })
        > {
  $$SourceSegmentsTableTableManager(
    _$AppDatabase db,
    $SourceSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourceSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourceSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourceSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceId = const Value.absent(),
                Value<int> pageNumber = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> segmentType = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SourceSegmentsCompanion(
                id: id,
                sourceId: sourceId,
                pageNumber: pageNumber,
                content: content,
                segmentType: segmentType,
                contentConfidence: contentConfidence,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceId,
                required int pageNumber,
                Value<String> content = const Value.absent(),
                Value<String> segmentType = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SourceSegmentsCompanion.insert(
                id: id,
                sourceId: sourceId,
                pageNumber: pageNumber,
                content: content,
                segmentType: segmentType,
                contentConfidence: contentConfidence,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourceSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceId = false,
                evidenceLinksRefs = false,
                auditsRefs = false,
                conflictsRefs = false,
                evidencePackItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (evidenceLinksRefs) db.evidenceLinks,
                    if (auditsRefs) db.audits,
                    if (conflictsRefs) db.conflicts,
                    if (evidencePackItemsRefs) db.evidencePackItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable:
                                        $$SourceSegmentsTableReferences
                                            ._sourceIdTable(db),
                                    referencedColumn:
                                        $$SourceSegmentsTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (evidenceLinksRefs)
                        await $_getPrefetchedData<
                          SourceSegment,
                          $SourceSegmentsTable,
                          EvidenceLink
                        >(
                          currentTable: table,
                          referencedTable: $$SourceSegmentsTableReferences
                              ._evidenceLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditsRefs)
                        await $_getPrefetchedData<
                          SourceSegment,
                          $SourceSegmentsTable,
                          Audit
                        >(
                          currentTable: table,
                          referencedTable: $$SourceSegmentsTableReferences
                              ._auditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).auditsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conflictsRefs)
                        await $_getPrefetchedData<
                          SourceSegment,
                          $SourceSegmentsTable,
                          Conflict
                        >(
                          currentTable: table,
                          referencedTable: $$SourceSegmentsTableReferences
                              ._conflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).conflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidencePackItemsRefs)
                        await $_getPrefetchedData<
                          SourceSegment,
                          $SourceSegmentsTable,
                          EvidencePackItem
                        >(
                          currentTable: table,
                          referencedTable: $$SourceSegmentsTableReferences
                              ._evidencePackItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SourceSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidencePackItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceSegmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SourceSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SourceSegmentsTable,
      SourceSegment,
      $$SourceSegmentsTableFilterComposer,
      $$SourceSegmentsTableOrderingComposer,
      $$SourceSegmentsTableAnnotationComposer,
      $$SourceSegmentsTableCreateCompanionBuilder,
      $$SourceSegmentsTableUpdateCompanionBuilder,
      (SourceSegment, $$SourceSegmentsTableReferences),
      SourceSegment,
      PrefetchHooks Function({
        bool sourceId,
        bool evidenceLinksRefs,
        bool auditsRefs,
        bool conflictsRefs,
        bool evidencePackItemsRefs,
      })
    >;
typedef $$ExamUnitsTableCreateCompanionBuilder =
    ExamUnitsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> unitType,
      Value<String?> description,
      Value<String> confidenceLevel,
      Value<String> examConfidence,
      Value<String> auditStatus,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ExamUnitsTableUpdateCompanionBuilder =
    ExamUnitsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> unitType,
      Value<String?> description,
      Value<String> confidenceLevel,
      Value<String> examConfidence,
      Value<String> auditStatus,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ExamUnitsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamUnitsTable, ExamUnit> {
  $$ExamUnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClaimsTable, List<Claim>> _claimsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.claims,
    aliasName: $_aliasNameGenerator(db.examUnits.id, db.claims.examUnitId),
  );

  $$ClaimsTableProcessedTableManager get claimsRefs {
    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.examUnitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_claimsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AuditsTable, List<Audit>> _auditsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.audits,
    aliasName: $_aliasNameGenerator(db.examUnits.id, db.audits.examUnitId),
  );

  $$AuditsTableProcessedTableManager get auditsRefs {
    final manager = $$AuditsTableTableManager(
      $_db,
      $_db.audits,
    ).filter((f) => f.examUnitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConflictsTable, List<Conflict>>
  _conflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conflicts,
    aliasName: $_aliasNameGenerator(db.examUnits.id, db.conflicts.examUnitId),
  );

  $$ConflictsTableProcessedTableManager get conflictsRefs {
    final manager = $$ConflictsTableTableManager(
      $_db,
      $_db.conflicts,
    ).filter((f) => f.examUnitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UnitStatsTable, List<UnitStat>>
  _unitStatsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.unitStats,
    aliasName: $_aliasNameGenerator(db.examUnits.id, db.unitStats.examUnitId),
  );

  $$UnitStatsTableProcessedTableManager get unitStatsRefs {
    final manager = $$UnitStatsTableTableManager(
      $_db,
      $_db.unitStats,
    ).filter((f) => f.examUnitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_unitStatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UnitMergeHistoryTable, List<UnitMergeHistoryData>>
  _unitMergeHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.unitMergeHistory,
    aliasName: $_aliasNameGenerator(
      db.examUnits.id,
      db.unitMergeHistory.parentId,
    ),
  );

  $$UnitMergeHistoryTableProcessedTableManager get unitMergeHistoryRefs {
    final manager = $$UnitMergeHistoryTableTableManager(
      $_db,
      $_db.unitMergeHistory,
    ).filter((f) => f.parentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _unitMergeHistoryRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamUnitsTable> {
  $$ExamUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get auditStatus => $composableBuilder(
    column: $table.auditStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> claimsRefs(
    Expression<bool> Function($$ClaimsTableFilterComposer f) f,
  ) {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auditsRefs(
    Expression<bool> Function($$AuditsTableFilterComposer f) f,
  ) {
    final $$AuditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableFilterComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conflictsRefs(
    Expression<bool> Function($$ConflictsTableFilterComposer f) f,
  ) {
    final $$ConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableFilterComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unitStatsRefs(
    Expression<bool> Function($$UnitStatsTableFilterComposer f) f,
  ) {
    final $$UnitStatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unitStats,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitStatsTableFilterComposer(
            $db: $db,
            $table: $db.unitStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> unitMergeHistoryRefs(
    Expression<bool> Function($$UnitMergeHistoryTableFilterComposer f) f,
  ) {
    final $$UnitMergeHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unitMergeHistory,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitMergeHistoryTableFilterComposer(
            $db: $db,
            $table: $db.unitMergeHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamUnitsTable> {
  $$ExamUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get auditStatus => $composableBuilder(
    column: $table.auditStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamUnitsTable> {
  $$ExamUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get auditStatus => $composableBuilder(
    column: $table.auditStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> claimsRefs<T extends Object>(
    Expression<T> Function($$ClaimsTableAnnotationComposer a) f,
  ) {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auditsRefs<T extends Object>(
    Expression<T> Function($$AuditsTableAnnotationComposer a) f,
  ) {
    final $$AuditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableAnnotationComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conflictsRefs<T extends Object>(
    Expression<T> Function($$ConflictsTableAnnotationComposer a) f,
  ) {
    final $$ConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> unitStatsRefs<T extends Object>(
    Expression<T> Function($$UnitStatsTableAnnotationComposer a) f,
  ) {
    final $$UnitStatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unitStats,
      getReferencedColumn: (t) => t.examUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitStatsTableAnnotationComposer(
            $db: $db,
            $table: $db.unitStats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> unitMergeHistoryRefs<T extends Object>(
    Expression<T> Function($$UnitMergeHistoryTableAnnotationComposer a) f,
  ) {
    final $$UnitMergeHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.unitMergeHistory,
      getReferencedColumn: (t) => t.parentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UnitMergeHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.unitMergeHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamUnitsTable,
          ExamUnit,
          $$ExamUnitsTableFilterComposer,
          $$ExamUnitsTableOrderingComposer,
          $$ExamUnitsTableAnnotationComposer,
          $$ExamUnitsTableCreateCompanionBuilder,
          $$ExamUnitsTableUpdateCompanionBuilder,
          (ExamUnit, $$ExamUnitsTableReferences),
          ExamUnit,
          PrefetchHooks Function({
            bool claimsRefs,
            bool auditsRefs,
            bool conflictsRefs,
            bool unitStatsRefs,
            bool unitMergeHistoryRefs,
          })
        > {
  $$ExamUnitsTableTableManager(_$AppDatabase db, $ExamUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> confidenceLevel = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
                Value<String> auditStatus = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExamUnitsCompanion(
                id: id,
                title: title,
                unitType: unitType,
                description: description,
                confidenceLevel: confidenceLevel,
                examConfidence: examConfidence,
                auditStatus: auditStatus,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> unitType = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> confidenceLevel = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
                Value<String> auditStatus = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ExamUnitsCompanion.insert(
                id: id,
                title: title,
                unitType: unitType,
                description: description,
                confidenceLevel: confidenceLevel,
                examConfidence: examConfidence,
                auditStatus: auditStatus,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExamUnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                claimsRefs = false,
                auditsRefs = false,
                conflictsRefs = false,
                unitStatsRefs = false,
                unitMergeHistoryRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (claimsRefs) db.claims,
                    if (auditsRefs) db.audits,
                    if (conflictsRefs) db.conflicts,
                    if (unitStatsRefs) db.unitStats,
                    if (unitMergeHistoryRefs) db.unitMergeHistory,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (claimsRefs)
                        await $_getPrefetchedData<
                          ExamUnit,
                          $ExamUnitsTable,
                          Claim
                        >(
                          currentTable: table,
                          referencedTable: $$ExamUnitsTableReferences
                              ._claimsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).claimsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auditsRefs)
                        await $_getPrefetchedData<
                          ExamUnit,
                          $ExamUnitsTable,
                          Audit
                        >(
                          currentTable: table,
                          referencedTable: $$ExamUnitsTableReferences
                              ._auditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).auditsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conflictsRefs)
                        await $_getPrefetchedData<
                          ExamUnit,
                          $ExamUnitsTable,
                          Conflict
                        >(
                          currentTable: table,
                          referencedTable: $$ExamUnitsTableReferences
                              ._conflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).conflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (unitStatsRefs)
                        await $_getPrefetchedData<
                          ExamUnit,
                          $ExamUnitsTable,
                          UnitStat
                        >(
                          currentTable: table,
                          referencedTable: $$ExamUnitsTableReferences
                              ._unitStatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).unitStatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (unitMergeHistoryRefs)
                        await $_getPrefetchedData<
                          ExamUnit,
                          $ExamUnitsTable,
                          UnitMergeHistoryData
                        >(
                          currentTable: table,
                          referencedTable: $$ExamUnitsTableReferences
                              ._unitMergeHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).unitMergeHistoryRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.parentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExamUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamUnitsTable,
      ExamUnit,
      $$ExamUnitsTableFilterComposer,
      $$ExamUnitsTableOrderingComposer,
      $$ExamUnitsTableAnnotationComposer,
      $$ExamUnitsTableCreateCompanionBuilder,
      $$ExamUnitsTableUpdateCompanionBuilder,
      (ExamUnit, $$ExamUnitsTableReferences),
      ExamUnit,
      PrefetchHooks Function({
        bool claimsRefs,
        bool auditsRefs,
        bool conflictsRefs,
        bool unitStatsRefs,
        bool unitMergeHistoryRefs,
      })
    >;
typedef $$ClaimsTableCreateCompanionBuilder =
    ClaimsCompanion Function({
      Value<int> id,
      required int examUnitId,
      required String content,
      Value<String> contentConfidence,
      Value<String> confidenceLevel,
      Value<String> createdBy,
      Value<DateTime> createdAt,
    });
typedef $$ClaimsTableUpdateCompanionBuilder =
    ClaimsCompanion Function({
      Value<int> id,
      Value<int> examUnitId,
      Value<String> content,
      Value<String> contentConfidence,
      Value<String> confidenceLevel,
      Value<String> createdBy,
      Value<DateTime> createdAt,
    });

final class $$ClaimsTableReferences
    extends BaseReferences<_$AppDatabase, $ClaimsTable, Claim> {
  $$ClaimsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamUnitsTable _examUnitIdTable(_$AppDatabase db) => db.examUnits
      .createAlias($_aliasNameGenerator(db.claims.examUnitId, db.examUnits.id));

  $$ExamUnitsTableProcessedTableManager get examUnitId {
    final $_column = $_itemColumn<int>('exam_unit_id')!;

    final manager = $$ExamUnitsTableTableManager(
      $_db,
      $_db.examUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EvidenceLinksTable, List<EvidenceLink>>
  _evidenceLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.evidenceLinks,
    aliasName: $_aliasNameGenerator(db.claims.id, db.evidenceLinks.claimId),
  );

  $$EvidenceLinksTableProcessedTableManager get evidenceLinksRefs {
    final manager = $$EvidenceLinksTableTableManager(
      $_db,
      $_db.evidenceLinks,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidenceLinksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ConflictsTable, List<Conflict>>
  _conflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conflicts,
    aliasName: $_aliasNameGenerator(db.claims.id, db.conflicts.claimId),
  );

  $$ConflictsTableProcessedTableManager get conflictsRefs {
    final manager = $$ConflictsTableTableManager(
      $_db,
      $_db.conflicts,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EvidencePacksTable, List<EvidencePack>>
  _evidencePacksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.evidencePacks,
    aliasName: $_aliasNameGenerator(db.claims.id, db.evidencePacks.claimId),
  );

  $$EvidencePacksTableProcessedTableManager get evidencePacksRefs {
    final manager = $$EvidencePacksTableTableManager(
      $_db,
      $_db.evidencePacks,
    ).filter((f) => f.claimId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_evidencePacksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClaimsTableFilterComposer
    extends Composer<_$AppDatabase, $ClaimsTable> {
  $$ClaimsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamUnitsTableFilterComposer get examUnitId {
    final $$ExamUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableFilterComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> evidenceLinksRefs(
    Expression<bool> Function($$EvidenceLinksTableFilterComposer f) f,
  ) {
    final $$EvidenceLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceLinks,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceLinksTableFilterComposer(
            $db: $db,
            $table: $db.evidenceLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> conflictsRefs(
    Expression<bool> Function($$ConflictsTableFilterComposer f) f,
  ) {
    final $$ConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableFilterComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> evidencePacksRefs(
    Expression<bool> Function($$EvidencePacksTableFilterComposer f) f,
  ) {
    final $$EvidencePacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencePacks,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePacksTableFilterComposer(
            $db: $db,
            $table: $db.evidencePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClaimsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClaimsTable> {
  $$ClaimsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamUnitsTableOrderingComposer get examUnitId {
    final $$ExamUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClaimsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClaimsTable> {
  $$ClaimsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceLevel => $composableBuilder(
    column: $table.confidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExamUnitsTableAnnotationComposer get examUnitId {
    final $$ExamUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> evidenceLinksRefs<T extends Object>(
    Expression<T> Function($$EvidenceLinksTableAnnotationComposer a) f,
  ) {
    final $$EvidenceLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidenceLinks,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidenceLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.evidenceLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> conflictsRefs<T extends Object>(
    Expression<T> Function($$ConflictsTableAnnotationComposer a) f,
  ) {
    final $$ConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> evidencePacksRefs<T extends Object>(
    Expression<T> Function($$EvidencePacksTableAnnotationComposer a) f,
  ) {
    final $$EvidencePacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencePacks,
      getReferencedColumn: (t) => t.claimId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePacksTableAnnotationComposer(
            $db: $db,
            $table: $db.evidencePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClaimsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClaimsTable,
          Claim,
          $$ClaimsTableFilterComposer,
          $$ClaimsTableOrderingComposer,
          $$ClaimsTableAnnotationComposer,
          $$ClaimsTableCreateCompanionBuilder,
          $$ClaimsTableUpdateCompanionBuilder,
          (Claim, $$ClaimsTableReferences),
          Claim,
          PrefetchHooks Function({
            bool examUnitId,
            bool evidenceLinksRefs,
            bool conflictsRefs,
            bool evidencePacksRefs,
          })
        > {
  $$ClaimsTableTableManager(_$AppDatabase db, $ClaimsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClaimsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClaimsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClaimsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examUnitId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<String> confidenceLevel = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimsCompanion(
                id: id,
                examUnitId: examUnitId,
                content: content,
                contentConfidence: contentConfidence,
                confidenceLevel: confidenceLevel,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examUnitId,
                required String content,
                Value<String> contentConfidence = const Value.absent(),
                Value<String> confidenceLevel = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClaimsCompanion.insert(
                id: id,
                examUnitId: examUnitId,
                content: content,
                contentConfidence: contentConfidence,
                confidenceLevel: confidenceLevel,
                createdBy: createdBy,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ClaimsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                examUnitId = false,
                evidenceLinksRefs = false,
                conflictsRefs = false,
                evidencePacksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (evidenceLinksRefs) db.evidenceLinks,
                    if (conflictsRefs) db.conflicts,
                    if (evidencePacksRefs) db.evidencePacks,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (examUnitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.examUnitId,
                                    referencedTable: $$ClaimsTableReferences
                                        ._examUnitIdTable(db),
                                    referencedColumn: $$ClaimsTableReferences
                                        ._examUnitIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (evidenceLinksRefs)
                        await $_getPrefetchedData<
                          Claim,
                          $ClaimsTable,
                          EvidenceLink
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._evidenceLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidenceLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claimId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (conflictsRefs)
                        await $_getPrefetchedData<
                          Claim,
                          $ClaimsTable,
                          Conflict
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._conflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).conflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claimId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (evidencePacksRefs)
                        await $_getPrefetchedData<
                          Claim,
                          $ClaimsTable,
                          EvidencePack
                        >(
                          currentTable: table,
                          referencedTable: $$ClaimsTableReferences
                              ._evidencePacksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClaimsTableReferences(
                                db,
                                table,
                                p0,
                              ).evidencePacksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.claimId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClaimsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClaimsTable,
      Claim,
      $$ClaimsTableFilterComposer,
      $$ClaimsTableOrderingComposer,
      $$ClaimsTableAnnotationComposer,
      $$ClaimsTableCreateCompanionBuilder,
      $$ClaimsTableUpdateCompanionBuilder,
      (Claim, $$ClaimsTableReferences),
      Claim,
      PrefetchHooks Function({
        bool examUnitId,
        bool evidenceLinksRefs,
        bool conflictsRefs,
        bool evidencePacksRefs,
      })
    >;
typedef $$EvidenceLinksTableCreateCompanionBuilder =
    EvidenceLinksCompanion Function({
      Value<int> id,
      required int claimId,
      required int sourceSegmentId,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$EvidenceLinksTableUpdateCompanionBuilder =
    EvidenceLinksCompanion Function({
      Value<int> id,
      Value<int> claimId,
      Value<int> sourceSegmentId,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$EvidenceLinksTableReferences
    extends BaseReferences<_$AppDatabase, $EvidenceLinksTable, EvidenceLink> {
  $$EvidenceLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClaimsTable _claimIdTable(_$AppDatabase db) => db.claims.createAlias(
    $_aliasNameGenerator(db.evidenceLinks.claimId, db.claims.id),
  );

  $$ClaimsTableProcessedTableManager get claimId {
    final $_column = $_itemColumn<int>('claim_id')!;

    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceSegmentsTable _sourceSegmentIdTable(_$AppDatabase db) =>
      db.sourceSegments.createAlias(
        $_aliasNameGenerator(
          db.evidenceLinks.sourceSegmentId,
          db.sourceSegments.id,
        ),
      );

  $$SourceSegmentsTableProcessedTableManager get sourceSegmentId {
    final $_column = $_itemColumn<int>('source_segment_id')!;

    final manager = $$SourceSegmentsTableTableManager(
      $_db,
      $_db.sourceSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidenceLinksTableFilterComposer
    extends Composer<_$AppDatabase, $EvidenceLinksTable> {
  $$EvidenceLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableFilterComposer get sourceSegmentId {
    final $$SourceSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidenceLinksTable> {
  $$EvidenceLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableOrderingComposer get sourceSegmentId {
    final $$SourceSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidenceLinksTable> {
  $$EvidenceLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableAnnotationComposer get sourceSegmentId {
    final $$SourceSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidenceLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidenceLinksTable,
          EvidenceLink,
          $$EvidenceLinksTableFilterComposer,
          $$EvidenceLinksTableOrderingComposer,
          $$EvidenceLinksTableAnnotationComposer,
          $$EvidenceLinksTableCreateCompanionBuilder,
          $$EvidenceLinksTableUpdateCompanionBuilder,
          (EvidenceLink, $$EvidenceLinksTableReferences),
          EvidenceLink,
          PrefetchHooks Function({bool claimId, bool sourceSegmentId})
        > {
  $$EvidenceLinksTableTableManager(_$AppDatabase db, $EvidenceLinksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidenceLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidenceLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidenceLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> claimId = const Value.absent(),
                Value<int> sourceSegmentId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidenceLinksCompanion(
                id: id,
                claimId: claimId,
                sourceSegmentId: sourceSegmentId,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int claimId,
                required int sourceSegmentId,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidenceLinksCompanion.insert(
                id: id,
                claimId: claimId,
                sourceSegmentId: sourceSegmentId,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidenceLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({claimId = false, sourceSegmentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (claimId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.claimId,
                                referencedTable: $$EvidenceLinksTableReferences
                                    ._claimIdTable(db),
                                referencedColumn: $$EvidenceLinksTableReferences
                                    ._claimIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sourceSegmentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sourceSegmentId,
                                referencedTable: $$EvidenceLinksTableReferences
                                    ._sourceSegmentIdTable(db),
                                referencedColumn: $$EvidenceLinksTableReferences
                                    ._sourceSegmentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EvidenceLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidenceLinksTable,
      EvidenceLink,
      $$EvidenceLinksTableFilterComposer,
      $$EvidenceLinksTableOrderingComposer,
      $$EvidenceLinksTableAnnotationComposer,
      $$EvidenceLinksTableCreateCompanionBuilder,
      $$EvidenceLinksTableUpdateCompanionBuilder,
      (EvidenceLink, $$EvidenceLinksTableReferences),
      EvidenceLink,
      PrefetchHooks Function({bool claimId, bool sourceSegmentId})
    >;
typedef $$AuditsTableCreateCompanionBuilder =
    AuditsCompanion Function({
      Value<int> id,
      required int sourceSegmentId,
      required int examUnitId,
      required String status,
      Value<String> contentConfidence,
      Value<String> examConfidence,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AuditsTableUpdateCompanionBuilder =
    AuditsCompanion Function({
      Value<int> id,
      Value<int> sourceSegmentId,
      Value<int> examUnitId,
      Value<String> status,
      Value<String> contentConfidence,
      Value<String> examConfidence,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AuditsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditsTable, Audit> {
  $$AuditsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourceSegmentsTable _sourceSegmentIdTable(_$AppDatabase db) =>
      db.sourceSegments.createAlias(
        $_aliasNameGenerator(db.audits.sourceSegmentId, db.sourceSegments.id),
      );

  $$SourceSegmentsTableProcessedTableManager get sourceSegmentId {
    final $_column = $_itemColumn<int>('source_segment_id')!;

    final manager = $$SourceSegmentsTableTableManager(
      $_db,
      $_db.sourceSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExamUnitsTable _examUnitIdTable(_$AppDatabase db) => db.examUnits
      .createAlias($_aliasNameGenerator(db.audits.examUnitId, db.examUnits.id));

  $$ExamUnitsTableProcessedTableManager get examUnitId {
    final $_column = $_itemColumn<int>('exam_unit_id')!;

    final manager = $$ExamUnitsTableTableManager(
      $_db,
      $_db.examUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ConflictsTable, List<Conflict>>
  _conflictsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conflicts,
    aliasName: $_aliasNameGenerator(db.audits.id, db.conflicts.auditId),
  );

  $$ConflictsTableProcessedTableManager get conflictsRefs {
    final manager = $$ConflictsTableTableManager(
      $_db,
      $_db.conflicts,
    ).filter((f) => f.auditId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_conflictsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AuditsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceSegmentsTableFilterComposer get sourceSegmentId {
    final $$SourceSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableFilterComposer get examUnitId {
    final $$ExamUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableFilterComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> conflictsRefs(
    Expression<bool> Function($$ConflictsTableFilterComposer f) f,
  ) {
    final $$ConflictsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableFilterComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuditsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceSegmentsTableOrderingComposer get sourceSegmentId {
    final $$SourceSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableOrderingComposer get examUnitId {
    final $$ExamUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditsTable> {
  $$AuditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SourceSegmentsTableAnnotationComposer get sourceSegmentId {
    final $$SourceSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableAnnotationComposer get examUnitId {
    final $$ExamUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> conflictsRefs<T extends Object>(
    Expression<T> Function($$ConflictsTableAnnotationComposer a) f,
  ) {
    final $$ConflictsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.conflicts,
      getReferencedColumn: (t) => t.auditId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConflictsTableAnnotationComposer(
            $db: $db,
            $table: $db.conflicts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AuditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditsTable,
          Audit,
          $$AuditsTableFilterComposer,
          $$AuditsTableOrderingComposer,
          $$AuditsTableAnnotationComposer,
          $$AuditsTableCreateCompanionBuilder,
          $$AuditsTableUpdateCompanionBuilder,
          (Audit, $$AuditsTableReferences),
          Audit,
          PrefetchHooks Function({
            bool sourceSegmentId,
            bool examUnitId,
            bool conflictsRefs,
          })
        > {
  $$AuditsTableTableManager(_$AppDatabase db, $AuditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceSegmentId = const Value.absent(),
                Value<int> examUnitId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AuditsCompanion(
                id: id,
                sourceSegmentId: sourceSegmentId,
                examUnitId: examUnitId,
                status: status,
                contentConfidence: contentConfidence,
                examConfidence: examConfidence,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceSegmentId,
                required int examUnitId,
                required String status,
                Value<String> contentConfidence = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AuditsCompanion.insert(
                id: id,
                sourceSegmentId: sourceSegmentId,
                examUnitId: examUnitId,
                status: status,
                contentConfidence: contentConfidence,
                examConfidence: examConfidence,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AuditsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceSegmentId = false,
                examUnitId = false,
                conflictsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (conflictsRefs) db.conflicts],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceSegmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSegmentId,
                                    referencedTable: $$AuditsTableReferences
                                        ._sourceSegmentIdTable(db),
                                    referencedColumn: $$AuditsTableReferences
                                        ._sourceSegmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (examUnitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.examUnitId,
                                    referencedTable: $$AuditsTableReferences
                                        ._examUnitIdTable(db),
                                    referencedColumn: $$AuditsTableReferences
                                        ._examUnitIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (conflictsRefs)
                        await $_getPrefetchedData<
                          Audit,
                          $AuditsTable,
                          Conflict
                        >(
                          currentTable: table,
                          referencedTable: $$AuditsTableReferences
                              ._conflictsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuditsTableReferences(
                                db,
                                table,
                                p0,
                              ).conflictsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.auditId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AuditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditsTable,
      Audit,
      $$AuditsTableFilterComposer,
      $$AuditsTableOrderingComposer,
      $$AuditsTableAnnotationComposer,
      $$AuditsTableCreateCompanionBuilder,
      $$AuditsTableUpdateCompanionBuilder,
      (Audit, $$AuditsTableReferences),
      Audit,
      PrefetchHooks Function({
        bool sourceSegmentId,
        bool examUnitId,
        bool conflictsRefs,
      })
    >;
typedef $$ConflictsTableCreateCompanionBuilder =
    ConflictsCompanion Function({
      Value<int> id,
      required int sourceSegmentId,
      required int examUnitId,
      Value<int?> claimId,
      Value<int?> auditId,
      Value<String> status,
      Value<String?> reason,
      Value<String?> resolutionNote,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
    });
typedef $$ConflictsTableUpdateCompanionBuilder =
    ConflictsCompanion Function({
      Value<int> id,
      Value<int> sourceSegmentId,
      Value<int> examUnitId,
      Value<int?> claimId,
      Value<int?> auditId,
      Value<String> status,
      Value<String?> reason,
      Value<String?> resolutionNote,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
    });

final class $$ConflictsTableReferences
    extends BaseReferences<_$AppDatabase, $ConflictsTable, Conflict> {
  $$ConflictsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SourceSegmentsTable _sourceSegmentIdTable(_$AppDatabase db) =>
      db.sourceSegments.createAlias(
        $_aliasNameGenerator(
          db.conflicts.sourceSegmentId,
          db.sourceSegments.id,
        ),
      );

  $$SourceSegmentsTableProcessedTableManager get sourceSegmentId {
    final $_column = $_itemColumn<int>('source_segment_id')!;

    final manager = $$SourceSegmentsTableTableManager(
      $_db,
      $_db.sourceSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExamUnitsTable _examUnitIdTable(_$AppDatabase db) =>
      db.examUnits.createAlias(
        $_aliasNameGenerator(db.conflicts.examUnitId, db.examUnits.id),
      );

  $$ExamUnitsTableProcessedTableManager get examUnitId {
    final $_column = $_itemColumn<int>('exam_unit_id')!;

    final manager = $$ExamUnitsTableTableManager(
      $_db,
      $_db.examUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ClaimsTable _claimIdTable(_$AppDatabase db) => db.claims.createAlias(
    $_aliasNameGenerator(db.conflicts.claimId, db.claims.id),
  );

  $$ClaimsTableProcessedTableManager? get claimId {
    final $_column = $_itemColumn<int>('claim_id');
    if ($_column == null) return null;
    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AuditsTable _auditIdTable(_$AppDatabase db) => db.audits.createAlias(
    $_aliasNameGenerator(db.conflicts.auditId, db.audits.id),
  );

  $$AuditsTableProcessedTableManager? get auditId {
    final $_column = $_itemColumn<int>('audit_id');
    if ($_column == null) return null;
    final manager = $$AuditsTableTableManager(
      $_db,
      $_db.audits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auditIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SourceSegmentsTableFilterComposer get sourceSegmentId {
    final $$SourceSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableFilterComposer get examUnitId {
    final $$ExamUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableFilterComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuditsTableFilterComposer get auditId {
    final $$AuditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableFilterComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SourceSegmentsTableOrderingComposer get sourceSegmentId {
    final $$SourceSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableOrderingComposer get examUnitId {
    final $$ExamUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuditsTableOrderingComposer get auditId {
    final $$AuditsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableOrderingComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictsTable> {
  $$ConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get resolutionNote => $composableBuilder(
    column: $table.resolutionNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  $$SourceSegmentsTableAnnotationComposer get sourceSegmentId {
    final $$SourceSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExamUnitsTableAnnotationComposer get examUnitId {
    final $$ExamUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuditsTableAnnotationComposer get auditId {
    final $$AuditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auditId,
      referencedTable: $db.audits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditsTableAnnotationComposer(
            $db: $db,
            $table: $db.audits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictsTable,
          Conflict,
          $$ConflictsTableFilterComposer,
          $$ConflictsTableOrderingComposer,
          $$ConflictsTableAnnotationComposer,
          $$ConflictsTableCreateCompanionBuilder,
          $$ConflictsTableUpdateCompanionBuilder,
          (Conflict, $$ConflictsTableReferences),
          Conflict,
          PrefetchHooks Function({
            bool sourceSegmentId,
            bool examUnitId,
            bool claimId,
            bool auditId,
          })
        > {
  $$ConflictsTableTableManager(_$AppDatabase db, $ConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sourceSegmentId = const Value.absent(),
                Value<int> examUnitId = const Value.absent(),
                Value<int?> claimId = const Value.absent(),
                Value<int?> auditId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> resolutionNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => ConflictsCompanion(
                id: id,
                sourceSegmentId: sourceSegmentId,
                examUnitId: examUnitId,
                claimId: claimId,
                auditId: auditId,
                status: status,
                reason: reason,
                resolutionNote: resolutionNote,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sourceSegmentId,
                required int examUnitId,
                Value<int?> claimId = const Value.absent(),
                Value<int?> auditId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> resolutionNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => ConflictsCompanion.insert(
                id: id,
                sourceSegmentId: sourceSegmentId,
                examUnitId: examUnitId,
                claimId: claimId,
                auditId: auditId,
                status: status,
                reason: reason,
                resolutionNote: resolutionNote,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ConflictsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sourceSegmentId = false,
                examUnitId = false,
                claimId = false,
                auditId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (sourceSegmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSegmentId,
                                    referencedTable: $$ConflictsTableReferences
                                        ._sourceSegmentIdTable(db),
                                    referencedColumn: $$ConflictsTableReferences
                                        ._sourceSegmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (examUnitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.examUnitId,
                                    referencedTable: $$ConflictsTableReferences
                                        ._examUnitIdTable(db),
                                    referencedColumn: $$ConflictsTableReferences
                                        ._examUnitIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (claimId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.claimId,
                                    referencedTable: $$ConflictsTableReferences
                                        ._claimIdTable(db),
                                    referencedColumn: $$ConflictsTableReferences
                                        ._claimIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (auditId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.auditId,
                                    referencedTable: $$ConflictsTableReferences
                                        ._auditIdTable(db),
                                    referencedColumn: $$ConflictsTableReferences
                                        ._auditIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictsTable,
      Conflict,
      $$ConflictsTableFilterComposer,
      $$ConflictsTableOrderingComposer,
      $$ConflictsTableAnnotationComposer,
      $$ConflictsTableCreateCompanionBuilder,
      $$ConflictsTableUpdateCompanionBuilder,
      (Conflict, $$ConflictsTableReferences),
      Conflict,
      PrefetchHooks Function({
        bool sourceSegmentId,
        bool examUnitId,
        bool claimId,
        bool auditId,
      })
    >;
typedef $$StudyMethodsTableCreateCompanionBuilder =
    StudyMethodsCompanion Function({
      Value<int> id,
      required String unitType,
      required String problemFormat,
      required String methodName,
      required String description,
      required int estimatedMinutes,
    });
typedef $$StudyMethodsTableUpdateCompanionBuilder =
    StudyMethodsCompanion Function({
      Value<int> id,
      Value<String> unitType,
      Value<String> problemFormat,
      Value<String> methodName,
      Value<String> description,
      Value<int> estimatedMinutes,
    });

class $$StudyMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $StudyMethodsTable> {
  $$StudyMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problemFormat => $composableBuilder(
    column: $table.problemFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyMethodsTable> {
  $$StudyMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problemFormat => $composableBuilder(
    column: $table.problemFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyMethodsTable> {
  $$StudyMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get problemFormat => $composableBuilder(
    column: $table.problemFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get methodName => $composableBuilder(
    column: $table.methodName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );
}

class $$StudyMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyMethodsTable,
          StudyMethod,
          $$StudyMethodsTableFilterComposer,
          $$StudyMethodsTableOrderingComposer,
          $$StudyMethodsTableAnnotationComposer,
          $$StudyMethodsTableCreateCompanionBuilder,
          $$StudyMethodsTableUpdateCompanionBuilder,
          (
            StudyMethod,
            BaseReferences<_$AppDatabase, $StudyMethodsTable, StudyMethod>,
          ),
          StudyMethod,
          PrefetchHooks Function()
        > {
  $$StudyMethodsTableTableManager(_$AppDatabase db, $StudyMethodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudyMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudyMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudyMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<String> problemFormat = const Value.absent(),
                Value<String> methodName = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
              }) => StudyMethodsCompanion(
                id: id,
                unitType: unitType,
                problemFormat: problemFormat,
                methodName: methodName,
                description: description,
                estimatedMinutes: estimatedMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String unitType,
                required String problemFormat,
                required String methodName,
                required String description,
                required int estimatedMinutes,
              }) => StudyMethodsCompanion.insert(
                id: id,
                unitType: unitType,
                problemFormat: problemFormat,
                methodName: methodName,
                description: description,
                estimatedMinutes: estimatedMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyMethodsTable,
      StudyMethod,
      $$StudyMethodsTableFilterComposer,
      $$StudyMethodsTableOrderingComposer,
      $$StudyMethodsTableAnnotationComposer,
      $$StudyMethodsTableCreateCompanionBuilder,
      $$StudyMethodsTableUpdateCompanionBuilder,
      (
        StudyMethod,
        BaseReferences<_$AppDatabase, $StudyMethodsTable, StudyMethod>,
      ),
      StudyMethod,
      PrefetchHooks Function()
    >;
typedef $$UnitStatsTableCreateCompanionBuilder =
    UnitStatsCompanion Function({
      Value<int> id,
      required int examUnitId,
      Value<int> sourceCount,
      Value<int> segmentCount,
      Value<int> claimCount,
      Value<int> evidenceCount,
      Value<int> conflictCount,
      Value<int> pointWeight,
      Value<int> frequency,
      Value<bool> frequencyManualOverride,
      Value<DateTime?> lastAuditedAt,
      Value<DateTime> updatedAt,
    });
typedef $$UnitStatsTableUpdateCompanionBuilder =
    UnitStatsCompanion Function({
      Value<int> id,
      Value<int> examUnitId,
      Value<int> sourceCount,
      Value<int> segmentCount,
      Value<int> claimCount,
      Value<int> evidenceCount,
      Value<int> conflictCount,
      Value<int> pointWeight,
      Value<int> frequency,
      Value<bool> frequencyManualOverride,
      Value<DateTime?> lastAuditedAt,
      Value<DateTime> updatedAt,
    });

final class $$UnitStatsTableReferences
    extends BaseReferences<_$AppDatabase, $UnitStatsTable, UnitStat> {
  $$UnitStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamUnitsTable _examUnitIdTable(_$AppDatabase db) =>
      db.examUnits.createAlias(
        $_aliasNameGenerator(db.unitStats.examUnitId, db.examUnits.id),
      );

  $$ExamUnitsTableProcessedTableManager get examUnitId {
    final $_column = $_itemColumn<int>('exam_unit_id')!;

    final manager = $$ExamUnitsTableTableManager(
      $_db,
      $_db.examUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UnitStatsTableFilterComposer
    extends Composer<_$AppDatabase, $UnitStatsTable> {
  $$UnitStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceCount => $composableBuilder(
    column: $table.sourceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get segmentCount => $composableBuilder(
    column: $table.segmentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointWeight => $composableBuilder(
    column: $table.pointWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get frequencyManualOverride => $composableBuilder(
    column: $table.frequencyManualOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAuditedAt => $composableBuilder(
    column: $table.lastAuditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamUnitsTableFilterComposer get examUnitId {
    final $$ExamUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableFilterComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitStatsTable> {
  $$UnitStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceCount => $composableBuilder(
    column: $table.sourceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get segmentCount => $composableBuilder(
    column: $table.segmentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointWeight => $composableBuilder(
    column: $table.pointWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get frequencyManualOverride => $composableBuilder(
    column: $table.frequencyManualOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAuditedAt => $composableBuilder(
    column: $table.lastAuditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamUnitsTableOrderingComposer get examUnitId {
    final $$ExamUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitStatsTable> {
  $$UnitStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sourceCount => $composableBuilder(
    column: $table.sourceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get segmentCount => $composableBuilder(
    column: $table.segmentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get claimCount => $composableBuilder(
    column: $table.claimCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get conflictCount => $composableBuilder(
    column: $table.conflictCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pointWeight => $composableBuilder(
    column: $table.pointWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<bool> get frequencyManualOverride => $composableBuilder(
    column: $table.frequencyManualOverride,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAuditedAt => $composableBuilder(
    column: $table.lastAuditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ExamUnitsTableAnnotationComposer get examUnitId {
    final $$ExamUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examUnitId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitStatsTable,
          UnitStat,
          $$UnitStatsTableFilterComposer,
          $$UnitStatsTableOrderingComposer,
          $$UnitStatsTableAnnotationComposer,
          $$UnitStatsTableCreateCompanionBuilder,
          $$UnitStatsTableUpdateCompanionBuilder,
          (UnitStat, $$UnitStatsTableReferences),
          UnitStat,
          PrefetchHooks Function({bool examUnitId})
        > {
  $$UnitStatsTableTableManager(_$AppDatabase db, $UnitStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examUnitId = const Value.absent(),
                Value<int> sourceCount = const Value.absent(),
                Value<int> segmentCount = const Value.absent(),
                Value<int> claimCount = const Value.absent(),
                Value<int> evidenceCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> pointWeight = const Value.absent(),
                Value<int> frequency = const Value.absent(),
                Value<bool> frequencyManualOverride = const Value.absent(),
                Value<DateTime?> lastAuditedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UnitStatsCompanion(
                id: id,
                examUnitId: examUnitId,
                sourceCount: sourceCount,
                segmentCount: segmentCount,
                claimCount: claimCount,
                evidenceCount: evidenceCount,
                conflictCount: conflictCount,
                pointWeight: pointWeight,
                frequency: frequency,
                frequencyManualOverride: frequencyManualOverride,
                lastAuditedAt: lastAuditedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examUnitId,
                Value<int> sourceCount = const Value.absent(),
                Value<int> segmentCount = const Value.absent(),
                Value<int> claimCount = const Value.absent(),
                Value<int> evidenceCount = const Value.absent(),
                Value<int> conflictCount = const Value.absent(),
                Value<int> pointWeight = const Value.absent(),
                Value<int> frequency = const Value.absent(),
                Value<bool> frequencyManualOverride = const Value.absent(),
                Value<DateTime?> lastAuditedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UnitStatsCompanion.insert(
                id: id,
                examUnitId: examUnitId,
                sourceCount: sourceCount,
                segmentCount: segmentCount,
                claimCount: claimCount,
                evidenceCount: evidenceCount,
                conflictCount: conflictCount,
                pointWeight: pointWeight,
                frequency: frequency,
                frequencyManualOverride: frequencyManualOverride,
                lastAuditedAt: lastAuditedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UnitStatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examUnitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (examUnitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.examUnitId,
                                referencedTable: $$UnitStatsTableReferences
                                    ._examUnitIdTable(db),
                                referencedColumn: $$UnitStatsTableReferences
                                    ._examUnitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UnitStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitStatsTable,
      UnitStat,
      $$UnitStatsTableFilterComposer,
      $$UnitStatsTableOrderingComposer,
      $$UnitStatsTableAnnotationComposer,
      $$UnitStatsTableCreateCompanionBuilder,
      $$UnitStatsTableUpdateCompanionBuilder,
      (UnitStat, $$UnitStatsTableReferences),
      UnitStat,
      PrefetchHooks Function({bool examUnitId})
    >;
typedef $$EvidencePacksTableCreateCompanionBuilder =
    EvidencePacksCompanion Function({
      Value<int> id,
      required int claimId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> summary,
      Value<String> contentConfidence,
      Value<String> examConfidence,
    });
typedef $$EvidencePacksTableUpdateCompanionBuilder =
    EvidencePacksCompanion Function({
      Value<int> id,
      Value<int> claimId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> summary,
      Value<String> contentConfidence,
      Value<String> examConfidence,
    });

final class $$EvidencePacksTableReferences
    extends BaseReferences<_$AppDatabase, $EvidencePacksTable, EvidencePack> {
  $$EvidencePacksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ClaimsTable _claimIdTable(_$AppDatabase db) => db.claims.createAlias(
    $_aliasNameGenerator(db.evidencePacks.claimId, db.claims.id),
  );

  $$ClaimsTableProcessedTableManager get claimId {
    final $_column = $_itemColumn<int>('claim_id')!;

    final manager = $$ClaimsTableTableManager(
      $_db,
      $_db.claims,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_claimIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EvidencePackItemsTable, List<EvidencePackItem>>
  _evidencePackItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.evidencePackItems,
        aliasName: $_aliasNameGenerator(
          db.evidencePacks.id,
          db.evidencePackItems.evidencePackId,
        ),
      );

  $$EvidencePackItemsTableProcessedTableManager get evidencePackItemsRefs {
    final manager = $$EvidencePackItemsTableTableManager(
      $_db,
      $_db.evidencePackItems,
    ).filter((f) => f.evidencePackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _evidencePackItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EvidencePacksTableFilterComposer
    extends Composer<_$AppDatabase, $EvidencePacksTable> {
  $$EvidencePacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnFilters(column),
  );

  $$ClaimsTableFilterComposer get claimId {
    final $$ClaimsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableFilterComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> evidencePackItemsRefs(
    Expression<bool> Function($$EvidencePackItemsTableFilterComposer f) f,
  ) {
    final $$EvidencePackItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.evidencePackItems,
      getReferencedColumn: (t) => t.evidencePackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePackItemsTableFilterComposer(
            $db: $db,
            $table: $db.evidencePackItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EvidencePacksTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidencePacksTable> {
  $$EvidencePacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClaimsTableOrderingComposer get claimId {
    final $$ClaimsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableOrderingComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidencePacksTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidencePacksTable> {
  $$EvidencePacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get contentConfidence => $composableBuilder(
    column: $table.contentConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get examConfidence => $composableBuilder(
    column: $table.examConfidence,
    builder: (column) => column,
  );

  $$ClaimsTableAnnotationComposer get claimId {
    final $$ClaimsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.claimId,
      referencedTable: $db.claims,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClaimsTableAnnotationComposer(
            $db: $db,
            $table: $db.claims,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> evidencePackItemsRefs<T extends Object>(
    Expression<T> Function($$EvidencePackItemsTableAnnotationComposer a) f,
  ) {
    final $$EvidencePackItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.evidencePackItems,
          getReferencedColumn: (t) => t.evidencePackId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EvidencePackItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.evidencePackItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$EvidencePacksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidencePacksTable,
          EvidencePack,
          $$EvidencePacksTableFilterComposer,
          $$EvidencePacksTableOrderingComposer,
          $$EvidencePacksTableAnnotationComposer,
          $$EvidencePacksTableCreateCompanionBuilder,
          $$EvidencePacksTableUpdateCompanionBuilder,
          (EvidencePack, $$EvidencePacksTableReferences),
          EvidencePack,
          PrefetchHooks Function({bool claimId, bool evidencePackItemsRefs})
        > {
  $$EvidencePacksTableTableManager(_$AppDatabase db, $EvidencePacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidencePacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidencePacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidencePacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> claimId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
              }) => EvidencePacksCompanion(
                id: id,
                claimId: claimId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                summary: summary,
                contentConfidence: contentConfidence,
                examConfidence: examConfidence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int claimId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> contentConfidence = const Value.absent(),
                Value<String> examConfidence = const Value.absent(),
              }) => EvidencePacksCompanion.insert(
                id: id,
                claimId: claimId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                summary: summary,
                contentConfidence: contentConfidence,
                examConfidence: examConfidence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidencePacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({claimId = false, evidencePackItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (evidencePackItemsRefs) db.evidencePackItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (claimId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.claimId,
                                    referencedTable:
                                        $$EvidencePacksTableReferences
                                            ._claimIdTable(db),
                                    referencedColumn:
                                        $$EvidencePacksTableReferences
                                            ._claimIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (evidencePackItemsRefs)
                        await $_getPrefetchedData<
                          EvidencePack,
                          $EvidencePacksTable,
                          EvidencePackItem
                        >(
                          currentTable: table,
                          referencedTable: $$EvidencePacksTableReferences
                              ._evidencePackItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EvidencePacksTableReferences(
                                db,
                                table,
                                p0,
                              ).evidencePackItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.evidencePackId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EvidencePacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidencePacksTable,
      EvidencePack,
      $$EvidencePacksTableFilterComposer,
      $$EvidencePacksTableOrderingComposer,
      $$EvidencePacksTableAnnotationComposer,
      $$EvidencePacksTableCreateCompanionBuilder,
      $$EvidencePacksTableUpdateCompanionBuilder,
      (EvidencePack, $$EvidencePacksTableReferences),
      EvidencePack,
      PrefetchHooks Function({bool claimId, bool evidencePackItemsRefs})
    >;
typedef $$EvidencePackItemsTableCreateCompanionBuilder =
    EvidencePackItemsCompanion Function({
      Value<int> id,
      required int evidencePackId,
      required int sourceSegmentId,
      Value<int?> pageNumber,
      Value<String?> snippet,
      Value<int> weight,
      Value<DateTime> createdAt,
    });
typedef $$EvidencePackItemsTableUpdateCompanionBuilder =
    EvidencePackItemsCompanion Function({
      Value<int> id,
      Value<int> evidencePackId,
      Value<int> sourceSegmentId,
      Value<int?> pageNumber,
      Value<String?> snippet,
      Value<int> weight,
      Value<DateTime> createdAt,
    });

final class $$EvidencePackItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EvidencePackItemsTable,
          EvidencePackItem
        > {
  $$EvidencePackItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EvidencePacksTable _evidencePackIdTable(_$AppDatabase db) =>
      db.evidencePacks.createAlias(
        $_aliasNameGenerator(
          db.evidencePackItems.evidencePackId,
          db.evidencePacks.id,
        ),
      );

  $$EvidencePacksTableProcessedTableManager get evidencePackId {
    final $_column = $_itemColumn<int>('evidence_pack_id')!;

    final manager = $$EvidencePacksTableTableManager(
      $_db,
      $_db.evidencePacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_evidencePackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourceSegmentsTable _sourceSegmentIdTable(_$AppDatabase db) =>
      db.sourceSegments.createAlias(
        $_aliasNameGenerator(
          db.evidencePackItems.sourceSegmentId,
          db.sourceSegments.id,
        ),
      );

  $$SourceSegmentsTableProcessedTableManager get sourceSegmentId {
    final $_column = $_itemColumn<int>('source_segment_id')!;

    final manager = $$SourceSegmentsTableTableManager(
      $_db,
      $_db.sourceSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceSegmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EvidencePackItemsTableFilterComposer
    extends Composer<_$AppDatabase, $EvidencePackItemsTable> {
  $$EvidencePackItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EvidencePacksTableFilterComposer get evidencePackId {
    final $$EvidencePacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidencePackId,
      referencedTable: $db.evidencePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePacksTableFilterComposer(
            $db: $db,
            $table: $db.evidencePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableFilterComposer get sourceSegmentId {
    final $$SourceSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidencePackItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $EvidencePackItemsTable> {
  $$EvidencePackItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snippet => $composableBuilder(
    column: $table.snippet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EvidencePacksTableOrderingComposer get evidencePackId {
    final $$EvidencePacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidencePackId,
      referencedTable: $db.evidencePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePacksTableOrderingComposer(
            $db: $db,
            $table: $db.evidencePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableOrderingComposer get sourceSegmentId {
    final $$SourceSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidencePackItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EvidencePackItemsTable> {
  $$EvidencePackItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snippet =>
      $composableBuilder(column: $table.snippet, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EvidencePacksTableAnnotationComposer get evidencePackId {
    final $$EvidencePacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.evidencePackId,
      referencedTable: $db.evidencePacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EvidencePacksTableAnnotationComposer(
            $db: $db,
            $table: $db.evidencePacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourceSegmentsTableAnnotationComposer get sourceSegmentId {
    final $$SourceSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceSegmentId,
      referencedTable: $db.sourceSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourceSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sourceSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EvidencePackItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EvidencePackItemsTable,
          EvidencePackItem,
          $$EvidencePackItemsTableFilterComposer,
          $$EvidencePackItemsTableOrderingComposer,
          $$EvidencePackItemsTableAnnotationComposer,
          $$EvidencePackItemsTableCreateCompanionBuilder,
          $$EvidencePackItemsTableUpdateCompanionBuilder,
          (EvidencePackItem, $$EvidencePackItemsTableReferences),
          EvidencePackItem,
          PrefetchHooks Function({bool evidencePackId, bool sourceSegmentId})
        > {
  $$EvidencePackItemsTableTableManager(
    _$AppDatabase db,
    $EvidencePackItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EvidencePackItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EvidencePackItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EvidencePackItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> evidencePackId = const Value.absent(),
                Value<int> sourceSegmentId = const Value.absent(),
                Value<int?> pageNumber = const Value.absent(),
                Value<String?> snippet = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidencePackItemsCompanion(
                id: id,
                evidencePackId: evidencePackId,
                sourceSegmentId: sourceSegmentId,
                pageNumber: pageNumber,
                snippet: snippet,
                weight: weight,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int evidencePackId,
                required int sourceSegmentId,
                Value<int?> pageNumber = const Value.absent(),
                Value<String?> snippet = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EvidencePackItemsCompanion.insert(
                id: id,
                evidencePackId: evidencePackId,
                sourceSegmentId: sourceSegmentId,
                pageNumber: pageNumber,
                snippet: snippet,
                weight: weight,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EvidencePackItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({evidencePackId = false, sourceSegmentId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (evidencePackId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.evidencePackId,
                                    referencedTable:
                                        $$EvidencePackItemsTableReferences
                                            ._evidencePackIdTable(db),
                                    referencedColumn:
                                        $$EvidencePackItemsTableReferences
                                            ._evidencePackIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceSegmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceSegmentId,
                                    referencedTable:
                                        $$EvidencePackItemsTableReferences
                                            ._sourceSegmentIdTable(db),
                                    referencedColumn:
                                        $$EvidencePackItemsTableReferences
                                            ._sourceSegmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$EvidencePackItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EvidencePackItemsTable,
      EvidencePackItem,
      $$EvidencePackItemsTableFilterComposer,
      $$EvidencePackItemsTableOrderingComposer,
      $$EvidencePackItemsTableAnnotationComposer,
      $$EvidencePackItemsTableCreateCompanionBuilder,
      $$EvidencePackItemsTableUpdateCompanionBuilder,
      (EvidencePackItem, $$EvidencePackItemsTableReferences),
      EvidencePackItem,
      PrefetchHooks Function({bool evidencePackId, bool sourceSegmentId})
    >;
typedef $$UnitMergeHistoryTableCreateCompanionBuilder =
    UnitMergeHistoryCompanion Function({
      Value<int> id,
      required int parentId,
      required int childId,
      Value<DateTime> mergedAt,
      required String movedClaimIds,
      required String childTitle,
      Value<String> childUnitType,
      Value<String?> childDescription,
      Value<String> childConfidenceLevel,
      Value<String> childExamConfidence,
      Value<String> childAuditStatus,
      Value<int> childSortOrder,
      Value<DateTime?> undoneAt,
    });
typedef $$UnitMergeHistoryTableUpdateCompanionBuilder =
    UnitMergeHistoryCompanion Function({
      Value<int> id,
      Value<int> parentId,
      Value<int> childId,
      Value<DateTime> mergedAt,
      Value<String> movedClaimIds,
      Value<String> childTitle,
      Value<String> childUnitType,
      Value<String?> childDescription,
      Value<String> childConfidenceLevel,
      Value<String> childExamConfidence,
      Value<String> childAuditStatus,
      Value<int> childSortOrder,
      Value<DateTime?> undoneAt,
    });

final class $$UnitMergeHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UnitMergeHistoryTable,
          UnitMergeHistoryData
        > {
  $$UnitMergeHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExamUnitsTable _parentIdTable(_$AppDatabase db) =>
      db.examUnits.createAlias(
        $_aliasNameGenerator(db.unitMergeHistory.parentId, db.examUnits.id),
      );

  $$ExamUnitsTableProcessedTableManager get parentId {
    final $_column = $_itemColumn<int>('parent_id')!;

    final manager = $$ExamUnitsTableTableManager(
      $_db,
      $_db.examUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UnitMergeHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $UnitMergeHistoryTable> {
  $$UnitMergeHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get mergedAt => $composableBuilder(
    column: $table.mergedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movedClaimIds => $composableBuilder(
    column: $table.movedClaimIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childTitle => $composableBuilder(
    column: $table.childTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childUnitType => $composableBuilder(
    column: $table.childUnitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childDescription => $composableBuilder(
    column: $table.childDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childConfidenceLevel => $composableBuilder(
    column: $table.childConfidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childExamConfidence => $composableBuilder(
    column: $table.childExamConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childAuditStatus => $composableBuilder(
    column: $table.childAuditStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get childSortOrder => $composableBuilder(
    column: $table.childSortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamUnitsTableFilterComposer get parentId {
    final $$ExamUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableFilterComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitMergeHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitMergeHistoryTable> {
  $$UnitMergeHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get mergedAt => $composableBuilder(
    column: $table.mergedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movedClaimIds => $composableBuilder(
    column: $table.movedClaimIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childTitle => $composableBuilder(
    column: $table.childTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childUnitType => $composableBuilder(
    column: $table.childUnitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childDescription => $composableBuilder(
    column: $table.childDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childConfidenceLevel => $composableBuilder(
    column: $table.childConfidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childExamConfidence => $composableBuilder(
    column: $table.childExamConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childAuditStatus => $composableBuilder(
    column: $table.childAuditStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get childSortOrder => $composableBuilder(
    column: $table.childSortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get undoneAt => $composableBuilder(
    column: $table.undoneAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamUnitsTableOrderingComposer get parentId {
    final $$ExamUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitMergeHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitMergeHistoryTable> {
  $$UnitMergeHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<DateTime> get mergedAt =>
      $composableBuilder(column: $table.mergedAt, builder: (column) => column);

  GeneratedColumn<String> get movedClaimIds => $composableBuilder(
    column: $table.movedClaimIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childTitle => $composableBuilder(
    column: $table.childTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childUnitType => $composableBuilder(
    column: $table.childUnitType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childDescription => $composableBuilder(
    column: $table.childDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childConfidenceLevel => $composableBuilder(
    column: $table.childConfidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childExamConfidence => $composableBuilder(
    column: $table.childExamConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get childAuditStatus => $composableBuilder(
    column: $table.childAuditStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get childSortOrder => $composableBuilder(
    column: $table.childSortOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get undoneAt =>
      $composableBuilder(column: $table.undoneAt, builder: (column) => column);

  $$ExamUnitsTableAnnotationComposer get parentId {
    final $$ExamUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.examUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.examUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UnitMergeHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UnitMergeHistoryTable,
          UnitMergeHistoryData,
          $$UnitMergeHistoryTableFilterComposer,
          $$UnitMergeHistoryTableOrderingComposer,
          $$UnitMergeHistoryTableAnnotationComposer,
          $$UnitMergeHistoryTableCreateCompanionBuilder,
          $$UnitMergeHistoryTableUpdateCompanionBuilder,
          (UnitMergeHistoryData, $$UnitMergeHistoryTableReferences),
          UnitMergeHistoryData,
          PrefetchHooks Function({bool parentId})
        > {
  $$UnitMergeHistoryTableTableManager(
    _$AppDatabase db,
    $UnitMergeHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitMergeHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitMergeHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitMergeHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> parentId = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<DateTime> mergedAt = const Value.absent(),
                Value<String> movedClaimIds = const Value.absent(),
                Value<String> childTitle = const Value.absent(),
                Value<String> childUnitType = const Value.absent(),
                Value<String?> childDescription = const Value.absent(),
                Value<String> childConfidenceLevel = const Value.absent(),
                Value<String> childExamConfidence = const Value.absent(),
                Value<String> childAuditStatus = const Value.absent(),
                Value<int> childSortOrder = const Value.absent(),
                Value<DateTime?> undoneAt = const Value.absent(),
              }) => UnitMergeHistoryCompanion(
                id: id,
                parentId: parentId,
                childId: childId,
                mergedAt: mergedAt,
                movedClaimIds: movedClaimIds,
                childTitle: childTitle,
                childUnitType: childUnitType,
                childDescription: childDescription,
                childConfidenceLevel: childConfidenceLevel,
                childExamConfidence: childExamConfidence,
                childAuditStatus: childAuditStatus,
                childSortOrder: childSortOrder,
                undoneAt: undoneAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int parentId,
                required int childId,
                Value<DateTime> mergedAt = const Value.absent(),
                required String movedClaimIds,
                required String childTitle,
                Value<String> childUnitType = const Value.absent(),
                Value<String?> childDescription = const Value.absent(),
                Value<String> childConfidenceLevel = const Value.absent(),
                Value<String> childExamConfidence = const Value.absent(),
                Value<String> childAuditStatus = const Value.absent(),
                Value<int> childSortOrder = const Value.absent(),
                Value<DateTime?> undoneAt = const Value.absent(),
              }) => UnitMergeHistoryCompanion.insert(
                id: id,
                parentId: parentId,
                childId: childId,
                mergedAt: mergedAt,
                movedClaimIds: movedClaimIds,
                childTitle: childTitle,
                childUnitType: childUnitType,
                childDescription: childDescription,
                childConfidenceLevel: childConfidenceLevel,
                childExamConfidence: childExamConfidence,
                childAuditStatus: childAuditStatus,
                childSortOrder: childSortOrder,
                undoneAt: undoneAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UnitMergeHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable:
                                    $$UnitMergeHistoryTableReferences
                                        ._parentIdTable(db),
                                referencedColumn:
                                    $$UnitMergeHistoryTableReferences
                                        ._parentIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UnitMergeHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UnitMergeHistoryTable,
      UnitMergeHistoryData,
      $$UnitMergeHistoryTableFilterComposer,
      $$UnitMergeHistoryTableOrderingComposer,
      $$UnitMergeHistoryTableAnnotationComposer,
      $$UnitMergeHistoryTableCreateCompanionBuilder,
      $$UnitMergeHistoryTableUpdateCompanionBuilder,
      (UnitMergeHistoryData, $$UnitMergeHistoryTableReferences),
      UnitMergeHistoryData,
      PrefetchHooks Function({bool parentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$SourceSegmentsTableTableManager get sourceSegments =>
      $$SourceSegmentsTableTableManager(_db, _db.sourceSegments);
  $$ExamUnitsTableTableManager get examUnits =>
      $$ExamUnitsTableTableManager(_db, _db.examUnits);
  $$ClaimsTableTableManager get claims =>
      $$ClaimsTableTableManager(_db, _db.claims);
  $$EvidenceLinksTableTableManager get evidenceLinks =>
      $$EvidenceLinksTableTableManager(_db, _db.evidenceLinks);
  $$AuditsTableTableManager get audits =>
      $$AuditsTableTableManager(_db, _db.audits);
  $$ConflictsTableTableManager get conflicts =>
      $$ConflictsTableTableManager(_db, _db.conflicts);
  $$StudyMethodsTableTableManager get studyMethods =>
      $$StudyMethodsTableTableManager(_db, _db.studyMethods);
  $$UnitStatsTableTableManager get unitStats =>
      $$UnitStatsTableTableManager(_db, _db.unitStats);
  $$EvidencePacksTableTableManager get evidencePacks =>
      $$EvidencePacksTableTableManager(_db, _db.evidencePacks);
  $$EvidencePackItemsTableTableManager get evidencePackItems =>
      $$EvidencePackItemsTableTableManager(_db, _db.evidencePackItems);
  $$UnitMergeHistoryTableTableManager get unitMergeHistory =>
      $$UnitMergeHistoryTableTableManager(_db, _db.unitMergeHistory);
}
