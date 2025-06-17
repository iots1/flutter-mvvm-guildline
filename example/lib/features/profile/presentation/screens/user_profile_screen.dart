// features/profile/presentation/screens/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../view_models/user_profile_view_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProfileViewModel>(context, listen: false).fetchUserProfile('test_user_id'); // Example user ID
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateFields(UserProfileViewModel viewModel) {
    if (viewModel.userProfile != null) {
      _nameController.text = viewModel.userProfile!.name;
      _emailController.text = viewModel.userProfile!.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Consumer<UserProfileViewModel>(
        builder: (context, viewModel, child) {
          _populateFields(viewModel);

          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text('Error: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.red)));
          } else if (viewModel.userProfile != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(radius: 60, backgroundImage: NetworkImage(viewModel.userProfile!.avatarUrl.isNotEmpty ? viewModel.userProfile!.avatarUrl : 'https://via.placeholder.com/150')),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  AppTextFormField(controller: _nameController, labelText: 'Name'),
                  const SizedBox(height: AppDimensions.spacingMedium),
                  AppTextFormField(controller: _emailController, labelText: 'Email', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: AppDimensions.spacingLarge),
                  AppButton(text: 'Update Profile', onPressed: () {
                    // Call viewModel.updateProfile here
                  }),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No profile data to display.'));
          }
        },
      ),
    );
  }
}