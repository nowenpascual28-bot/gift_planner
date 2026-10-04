import 'package:flutter/material.dart';

import '../../models/recipient.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';

class RecipientFormScreen extends StatefulWidget {
  final Recipient? recipient;

  const RecipientFormScreen({super.key, this.recipient});

  @override
  State<RecipientFormScreen> createState() => _RecipientFormScreenState();
}

class _RecipientFormScreenState extends State<RecipientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RecipientService();

  late final TextEditingController _name;
  late final TextEditingController _relationship;
  late final TextEditingController _interests;
  late final TextEditingController _notes;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.recipient != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipient;
    _name = TextEditingController(text: r?.name ?? '');
    _relationship = TextEditingController(text: r?.relationship ?? '');
    _interests = TextEditingController(text: r?.interests ?? '');
    _notes = TextEditingController(text: r?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _relationship.dispose();
    _interests.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      late final Recipient saved;
      if (_isEditing) {
        final updated = Recipient(
          id: widget.recipient!.id,
          userId: widget.recipient!.userId,
          name: _name.text.trim(),
          relationship: _relationship.text.trim(),
          interests: _interests.text.trim(),
          notes: _notes.text.trim(),
          createdAt: widget.recipient!.createdAt,
          updatedAt: widget.recipient!.updatedAt,
        );
        saved = await _service.updateRecipient(updated);
      } else {
        saved = await _service.createRecipient(
          name: _name.text.trim(),
          relationship: _relationship.text.trim(),
          interests: _interests.text.trim(),
          notes: _notes.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      setState(() => _error = 'Could not save this recipient. $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: _isEditing ? 'Edit recipient' : 'Add recipient',
        showBack: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              AppTextField(
                label: 'Name',
                controller: _name,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Relationship',
                controller: _relationship,
                hint: 'e.g. Sister, Best friend',
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(
                label: 'Interests',
                controller: _interests,
                hint: 'e.g. Hiking, sci-fi novels, coffee',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(label: 'Notes', controller: _notes, maxLines: 4),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: AppSpacing.space24),
              PrimaryButton(label: 'Save', onPressed: _save, loading: _saving),
              const SizedBox(height: AppSpacing.space8),
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
