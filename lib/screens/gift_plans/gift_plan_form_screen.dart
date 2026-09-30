import 'package:flutter/material.dart';

import '../../models/gift_plan.dart';
import '../../models/occasion.dart';
import '../../models/recipient.dart';
import '../../services/gift_plan_service.dart';
import '../../services/occasion_service.dart';
import '../../services/recipient_service.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_top_bar.dart';
import '../../widgets/budget_progress.dart';
import '../../widgets/primary_button.dart';
import '../recipients/recipient_form_screen.dart';

/// Add/edit form for a [GiftPlan]. Pass [plan] to edit an existing one, or
/// [initialRecipientId] to pre-select a recipient when creating a new one.
class GiftPlanFormScreen extends StatefulWidget {
  final GiftPlan? plan;
  final String? initialRecipientId;

  const GiftPlanFormScreen({super.key, this.plan, this.initialRecipientId});

  @override
  State<GiftPlanFormScreen> createState() => _GiftPlanFormScreenState();
}

class _GiftPlanFormScreenState extends State<GiftPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _giftPlanService = GiftPlanService();
  final _recipientService = RecipientService();
  final _occasionService = OccasionService();

  late final TextEditingController _giftName;
  late final TextEditingController _budget;
  late final TextEditingController _spent;
  late final TextEditingController _notes;
  String? _recipientId;
  String? _occasionId;
  late GiftPlanStatus _status;

  Future<List<Recipient>>? _recipientsFuture;
  Future<List<Occasion>>? _occasionsFuture;

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _giftName = TextEditingController(text: p?.giftName ?? '');
    _budget = TextEditingController(text: p == null ? '' : p.budget.toStringAsFixed(2));
    _spent = TextEditingController(text: p == null ? '0' : p.spent.toStringAsFixed(2));
    _notes = TextEditingController(text: p?.notes ?? '');
    _recipientId = p?.recipientId ?? widget.initialRecipientId;
    _occasionId = p?.occasionId;
    _status = p?.status ?? GiftPlanStatus.planned;
    _recipientsFuture = _recipientService.getRecipients();
    if (_recipientId != null) _loadOccasionsFor(_recipientId!);
    _budget.addListener(() => setState(() {}));
    _spent.addListener(() => setState(() {}));
  }

  void _loadOccasionsFor(String recipientId) {
    _occasionsFuture = _occasionService.getOccasions(recipientId: recipientId);
  }

  @override
  void dispose() {
    _giftName.dispose();
    _budget.dispose();
    _spent.dispose();
    _notes.dispose();
    super.dispose();
  }

  double? _parseNonNegative(String text) {
    final value = double.tryParse(text.trim());
    if (value == null || value < 0) return null;
    return value;
  }


  Future<void> _addRecipient() async {
    final saved = await Navigator.of(context).push<Recipient>(
      MaterialPageRoute(builder: (_) => const RecipientFormScreen()),
    );
    if (!mounted || saved == null) return;
    setState(() {
      _recipientId = saved.id;
      _occasionId = null;
      _recipientsFuture = _recipientService.getRecipients();
    });
    _loadOccasionsFor(saved.id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_recipientId == null) {
      setState(() => _error = 'Choose a recipient for this gift plan.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final budget = _parseNonNegative(_budget.text) ?? 0;
      final spent = _parseNonNegative(_spent.text) ?? 0;
      late final GiftPlan saved;
      if (_isEditing) {
        final updated = GiftPlan(
          id: widget.plan!.id,
          userId: widget.plan!.userId,
          recipientId: _recipientId!,
          occasionId: _occasionId,
          giftName: _giftName.text.trim(),
          budget: budget,
          spent: spent,
          status: _status,
          notes: _notes.text.trim(),
          createdAt: widget.plan!.createdAt,
          updatedAt: widget.plan!.updatedAt,
        );
        saved = await _giftPlanService.updateGiftPlan(updated);
      } else {
        saved = await _giftPlanService.createGiftPlan(
          recipientId: _recipientId!,
          occasionId: _occasionId,
          giftName: _giftName.text.trim(),
          budget: budget,
          spent: spent,
          status: _status,
          notes: _notes.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } catch (e) {
      setState(() => _error = 'Could not save this gift plan. $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewBudget = _parseNonNegative(_budget.text) ?? 0;
    final previewSpent = _parseNonNegative(_spent.text) ?? 0;

    return Scaffold(
      appBar: AppTopBar(title: _isEditing ? 'Edit gift plan' : 'New gift plan', showBack: true),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.space16),
            children: [
              AppTextField(
                label: 'Gift name',
                controller: _giftName,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Gift name is required' : null,
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
                    onChanged: (value) {
                      setState(() {
                        _recipientId = value;
                        _occasionId = null;
                        if (value != null) _loadOccasionsFor(value);
                      });
                    },
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
              if (_recipientId != null)
                FutureBuilder<List<Occasion>>(
                  future: _occasionsFuture,
                  builder: (context, snapshot) {
                    final occasions = snapshot.data ?? const <Occasion>[];
                    return DropdownButtonFormField<String?>(
                      initialValue: occasions.any((o) => o.id == _occasionId) ? _occasionId : null,
                      decoration: const InputDecoration(labelText: 'Occasion (optional)'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('No specific occasion')),
                        ...occasions.map((o) => DropdownMenuItem<String?>(value: o.id, child: Text(o.title))),
                      ],
                      onChanged: (value) => setState(() => _occasionId = value),
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.space16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Budget',
                      controller: _budget,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => _parseNonNegative(v ?? '') == null ? 'Enter a valid amount' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space16),
                  Expanded(
                    child: AppTextField(
                      label: 'Spent',
                      controller: _spent,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => _parseNonNegative(v ?? '') == null ? 'Enter a valid amount' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.space16),
              BudgetProgress(budget: previewBudget, spent: previewSpent),
              const SizedBox(height: AppSpacing.space16),
              DropdownButtonFormField<GiftPlanStatus>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: GiftPlanStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
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
