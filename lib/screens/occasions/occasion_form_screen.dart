import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/occasion.dart';
import '../../models/recipient.dart';
import '../../services/occasion_service.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/primary_button.dart';
import '../recipients/recipient_form_screen.dart';

/// Add/edit form for an [Occasion]. Pass [occasion] to edit an existing one,
/// or [initialRecipientId] to pre-select a recipient when creating a new one
/// from that recipient's details screen.
class OccasionFormScreen extends StatefulWidget {
  final Occasion? occasion;
  final String? initialRecipientId;

  const OccasionFormScreen({super.key, this.occasion, this.initialRecipientId});

  @override
  State<OccasionFormScreen> createState() => _OccasionFormScreenState();
}

class _OccasionFormScreenState extends State<OccasionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _occasionService = OccasionService();
  final _recipientService = RecipientService();

  late final TextEditingController _title;
  late final TextEditingController _notes;
  late DateTime _date;
  String? _recipientId;

  Future<List<Recipient>>? _recipientsFuture;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.occasion != null;

  @override
  void initState() {
    super.initState();
    final o = widget.occasion;
    _title = TextEditingController(text: o?.title ?? '');
    _notes = TextEditingController(text: o?.notes ?? '');
    _date = o?.date ?? DateTime.now();
    _recipientId = o?.recipientId ?? widget.initialRecipientId;
    _recipientsFuture = _recipientService.getRecipients();
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }


  Future<void> _addRecipient() async {
    final saved = await Navigator.of(context).push<Recipient>(
      MaterialPageRoute(builder: (_) => const RecipientFormScreen()),
    );
    if (!mounted || saved == null) return;
    setState(() {
      _recipientId = saved.id;
      _recipientsFuture = _recipientService.getRecipients();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipientId == null) {
      setState(() => _error = 'Choose a recipient for this occasion.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      late final Occasion saved;
      if (_isEditing) {
        final updated = Occasion(
          id: widget.occasion!.id,
          userId: widget.occasion!.userId,
          recipientId: _recipientId!,
          title: _title.text.trim(),
          date: _date,
          notes: _notes.text.trim(),
          createdAt: widget.occasion!.createdAt,
          updatedAt: widget.occasion!.updatedAt,
        );
        saved = await _occasionService.updateOccasion(updated);
      } else {
        saved = await _occasionService.createOccasion(
          recipientId: _recipientId!,
          title: _title.text.trim(),
          date: _date,
          notes: _notes.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      setState(() => _error = 'Could not save this occasion. $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: _isEditing ? 'Edit occasion' : 'Add occasion', showBack: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              AppTextField(
                label: 'Title',
                controller: _title,
                hint: 'e.g. Birthday, Anniversary, Graduation',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: AppSpacing.space16),
              FutureBuilder<List<Recipient>>(
                future: _recipientsFuture,
                builder: (context, snapshot) {
                  final recipients = snapshot.data ?? const <Recipient>[];
                  return DropdownButtonFormField<String>(
                    initialValue: recipients.any((r) => r.id == _recipientId) ? _recipientId : null,
                    decoration: const InputDecoration(labelText: 'Recipient'),
                    items: recipients
                        .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                        .toList(),
                    onChanged: (value) => setState(() => _recipientId = value),
                    validator: (value) => value == null ? 'Choose a recipient' : null,
                  );
                },
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving ? null : _addRecipient,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Add new recipient'),
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Date'),
                  child: Text(DateFormat.yMMMd().format(_date)),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              AppTextField(label: 'Notes', controller: _notes, maxLines: 4),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.space16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
