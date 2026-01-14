import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kpostal/kpostal.dart';

import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/states/store_form_state.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_creation_controller.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_form_controllerable.dart';
import 'package:studio_chance/presentation/commons/store_input/controllers/store_update_controller.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar_action_button.dart';
import 'package:studio_chance/presentation/commons/widgets/app_bar_back_button.dart';
import 'package:studio_chance/presentation/commons/widgets/custom_app_bar.dart';
import 'package:studio_chance/presentation/commons/widgets/grouped_form_container.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_body_button.dart';
import 'package:studio_chance/presentation/commons/widgets/input_form_body_text_field.dart';
import 'package:studio_chance/presentation/commons/widgets/safe_area_with_padding.dart';

class StoreAddressInputScreen extends ConsumerStatefulWidget {
  const StoreAddressInputScreen({super.key});

  @override
  ConsumerState<StoreAddressInputScreen> createState() =>
      _StoreAddressInputScreenState();
}

class _StoreAddressInputScreenState
    extends ConsumerState<StoreAddressInputScreen> {
  late final TextEditingController _addressDetaillController;
  late final TextEditingController _addressGuideController;

  String _address = '';

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _addressDetaillController = TextEditingController();
    _addressGuideController = TextEditingController();

    _addressDetaillController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final storeToEdit = GoRouterState.of(context).extra as Store?;

      StoreFormState state;

      if (storeToEdit != null) {
        state = ref.read(storeUpdateControllerProvider(storeToEdit));
      } else {
        state = ref.read(storeCreationControllerProvider);
      }

      _address = state.address;
      _addressDetaillController.text = state.addressDetail;
      _addressGuideController.text = state.addressGuide;

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _addressDetaillController.dispose();
    _addressGuideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storeToEdit = GoRouterState.of(context).extra as Store?;

    StoreFormControllerable notifier;
    if (storeToEdit != null) {
      notifier = ref.read(storeUpdateControllerProvider(storeToEdit).notifier);
    } else {
      notifier = ref.read(storeCreationControllerProvider.notifier);
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: '주소 입력',
        actions: [
          AppBarActionButton(
            label: '완료',
            onPressed: () {
              notifier.setAddress(_address);
              notifier.setAddressDetail(_addressDetaillController.text);
              notifier.setAddressGuide(_addressGuideController.text);
              context.pop();
            },
          ),
        ],
      ),
      body: SafeAreaWithPadding(
        child: GroupedFormContainer(
          children: [
            InputFormBodyButton(
              placeholder: '주소 검색',
              content: _address.isEmpty ? null : _address,
              onPressed: () async {
                final commonAppBar = CustomAppBar(
                  title: '주소 검색',
                  leading: AppBarModalBackButton(
                    onPressed: () => context.pop(),
                  ),
                );
                final commonOnLoading =
                    const CircularProgressIndicator.adaptive();

                Kpostal? result;
                if (Platform.isIOS) {
                  result = await showCupertinoSheet<Kpostal>(
                    enableDrag: false,
                    context: context,
                    builder: (context) {
                      return KpostalView(
                        appBar: commonAppBar,
                        onLoading: commonOnLoading,
                      );
                    },
                  );
                } else if (Platform.isAndroid) {
                  result = await showModalBottomSheet<Kpostal>(
                    isDismissible: false,
                    isScrollControlled: true,
                    useSafeArea: true,
                    context: context,
                    builder: (context) {
                      return KpostalView(
                        appBar: commonAppBar,
                        onLoading: commonOnLoading,
                      );
                    },
                  );
                }

                if (result != null) {
                  setState(() {
                    _address = result!.address;
                  });
                }
              },
            ),
            InputFormBodyTextField(
              controller: _addressDetaillController,
              placeholder: '상세 주소 혹은 주소 직접 입력',
              maxLines: 1,
              showClearButton: true,
              returnButtonType: TextInputAction.next,
            ),
            InputFormBodyTextField(
              controller: _addressGuideController,
              placeholder: '찾아오는 길 안내',
              maxLines: null,
              returnButtonType: TextInputAction.done,
              autocorrect: true,
            ),
          ],
        ),
      ),
    );
  }
}
