import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/cat_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class EditCatScreen extends StatefulWidget {
  final CatModel? cat; // null for new cat, non-null for editing

  const EditCatScreen({super.key, this.cat});

  @override
  State<EditCatScreen> createState() => _EditCatScreenState();
}

class _EditCatScreenState extends State<EditCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CatBreed _breed = CatBreed.britishShorthair;
  final _descriptionController = TextEditingController();
  late String _catId;
  DateTime? _birthDate;
  CatGender _gender = CatGender.male;
  BreedingStatus _breedingStatus = BreedingStatus.notAvailable;
  final List<String> _photoUrls = [];
  final Map<String, String> _healthRecords = {};
  final Map<String, DateTime> _healthRecordDates = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cat != null) {
      _nameController.text = widget.cat!.name;
      _breed = widget.cat!.breed;
      _descriptionController.text = widget.cat!.description ?? '';
      _catId = widget.cat!.id;
      _birthDate = widget.cat!.birthDate;
      _gender = widget.cat!.gender;
      _breedingStatus = widget.cat!.breedingStatus;
      _photoUrls.addAll(widget.cat!.photoUrls);
      _healthRecords.addAll(widget.cat!.healthRecords);
      _healthRecordDates.addAll(widget.cat!.healthRecordDates ?? {});
    } else { //new cat
      _catId = const Uuid().v4();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser == null) return;

      final storageService = context.read<StorageService>();
      final photoUrl = await storageService.uploadCatImage(
        File(image.path),
        _catId,
      );

      setState(() {
        _photoUrls.add(photoUrl);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePhoto(String photoUrl) async {
    setState(() => _isLoading = true);

    try {
      await context.read<StorageService>().deleteFile(photoUrl);
      setState(() {
        _photoUrls.remove(photoUrl);
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a birth date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser == null) return;

      final cat = CatModel(
        id: _catId,
        ownerId: currentUser.uid,
        name: _nameController.text.trim(),
        breed: _breed,
        birthDate: _birthDate!,
        gender: _gender,
        photoUrls: _photoUrls,
        description: _descriptionController.text.trim(),
        breedingStatus: _breedingStatus,
        healthRecords: _healthRecords,
        healthRecordDates: _healthRecordDates,
      );

      final firestoreService = context.read<FirestoreService>();
      await firestoreService.saveCat(cat);

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addHealthRecord() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddHealthRecordDialog(),
    );

    if (result != null) {
      setState(() {
        _healthRecords[result['title'] as String] = result['description'] as String;
        _healthRecordDates[result['title'] as String] = result['date'] as DateTime;
      });
    }
  }

  Future<void> _editHealthRecord(String originalTitle) async {
    final record = _healthRecords[originalTitle];
    final date = _healthRecordDates[originalTitle];
    if (record == null || date == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddHealthRecordDialog(
        initialTitle: originalTitle,
        initialDescription: record,
        initialDate: date,
      ),
    );

    if (result != null) {
      setState(() {
        // Remove old record
        _healthRecords.remove(originalTitle);
        _healthRecordDates.remove(originalTitle);
        
        // Add updated record
        _healthRecords[result['title'] as String] = result['description'] as String;
        _healthRecordDates[result['title'] as String] = result['date'] as DateTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat == null ? 'Add Cat' : 'Edit Cat'),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveCat,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photos
                    Text(
                      'Photos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Add photo button
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              width: 120,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 40),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Photo list
                          ..._photoUrls.map((url) => Stack(
                                children: [
                                  Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(url),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => _deletePhoto(url),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic info
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Breed Section
                    const Text(
                      'Breed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<CatBreed>(
                      segments: CatBreed.values.map((breed) {
                        return ButtonSegment<CatBreed>(
                          value: breed,
                          label: Text(breed.toString().split('.').last),
                          icon: null,
                        );
                      }).toList(),
                      selected: {_breed},
                      onSelectionChanged: (Set<CatBreed> newSelection) {
                        setState(() {
                          _breed = newSelection.first;
                        });
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    // Birth date
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _birthDate == null
                            ? 'Select birth date'
                            : 'Birth date: ${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _birthDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _birthDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Gender Section
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<CatGender>(
                      segments: CatGender.values.map((gender) {
                        return ButtonSegment<CatGender>(
                          value: gender,
                          label: Text(gender.toString().split('.').last),
                          icon: null,
                        );
                      }).toList(),
                      selected: {_gender},
                      onSelectionChanged: (Set<CatGender> newSelection) {
                        setState(() {
                          _gender = newSelection.first;
                        });
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    // Breeding Status Section
                    const Text(
                      'Breeding Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<BreedingStatus>(
                      segments: BreedingStatus.values.map((status) {
                        return ButtonSegment<BreedingStatus>(
                          value: status,
                          label: Text(status.toString().split('.').last),
                          icon: null,
                        );
                      }).toList(),
                      selected: {_breedingStatus},
                      onSelectionChanged: (Set<BreedingStatus> newSelection) {
                        setState(() {
                          _breedingStatus = newSelection.first;
                        });
                      },
                      showSelectedIcon: false,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Health records
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Health Records',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Record'),
                          onPressed: _addHealthRecord,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._healthRecords.entries.map(
                      (entry) {
                        final date = _healthRecordDates[entry.key];
                        return Card(
                          child: ListTile(
                            title: Text(entry.key),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (date != null)
                                  Text(
                                    'Date: ${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(entry.value),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editHealthRecord(entry.key),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      _healthRecords.remove(entry.key);
                                      _healthRecordDates.remove(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _AddHealthRecordDialog extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDate;

  const _AddHealthRecordDialog({
    this.initialTitle,
    this.initialDescription,
    this.initialDate,
  });

  @override
  _AddHealthRecordDialogState createState() => _AddHealthRecordDialogState();
}

class _AddHealthRecordDialogState extends State<_AddHealthRecordDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _descriptionController.text = widget.initialDescription ?? '';
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Health Record'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Vaccination, Check-up',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter details about the health record',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.of(context).pop({
                'title': _titleController.text.trim(),
                'description': _descriptionController.text.trim(),
                'date': _selectedDate,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 