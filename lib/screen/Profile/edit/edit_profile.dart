import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:itech/main.dart';
import 'package:itech/utils/url.dart';
import 'package:itech/providers/user/profile_socket_manager.dart';
import 'package:provider/provider.dart';
import 'package:itech/service/myProfile/profileService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itech/screen/buttonBar/ButtonNavbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _webSiteController = TextEditingController();
  final TextEditingController _cityStateController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  double _profileCompletionPercentage = 80;

  // Add a flag to track if form has been submitted
  bool _formSubmitted = false;

  // Create ProfileService instance
  final ProfileService _profileService = ProfileService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoading = false;

  // Image picker and selected images
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  File? _coverImage;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _loadProfileData();
  }

  // New method to load profile data with retry mechanism
  Future<void> _loadProfileData() async {
    // Try to load data immediately
    _updateFieldsFromWebSocketManager();

    // If data is not available yet, retry after a delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (_firstNameController.text == '' ||
          _firstNameController.text == '...') {
        print('Retrying profile data load...');
        _updateFieldsFromWebSocketManager();

        // Try one more time after a longer delay if still not available
        Future.delayed(Duration(seconds: 1), () {
          if (_firstNameController.text == '' ||
              _firstNameController.text == '...') {
            print('Final retry for profile data load...');
            _updateFieldsFromWebSocketManager();
          }
        });
      }
    });
  }

  // Helper method to update fields from WebSocketManager
  void _updateFieldsFromWebSocketManager() {
    final webSocketManager = Provider.of<ProfileSocketManager>(
      context,
      listen: false,
    );

    setState(() {
      _firstNameController.text =
          webSocketManager.first_name != '...'
              ? webSocketManager.first_name
              : '';
      _lastNameController.text =
          webSocketManager.last_name != '...' ? webSocketManager.last_name : '';
      _emailController.text =
          webSocketManager.emailName != '...' ? webSocketManager.emailName : '';
      _phoneController.text =
          webSocketManager.phone_number != '...'
              ? webSocketManager.phone_number
              : '';
      _countryController.text =
          webSocketManager.country != '...' ? webSocketManager.country : '';
      _jobTitleController.text =
          webSocketManager.job_title != '...' ? webSocketManager.job_title : '';
      _webSiteController.text =
          webSocketManager.website != '...' ? webSocketManager.website : '';
      _cityStateController.text =
          webSocketManager.city_state != '...'
              ? webSocketManager.city_state
              : '';
      _bioController.text =
          webSocketManager.bio != '...' ? webSocketManager.bio : '';
      _usernameController.text =
          webSocketManager.userName != '...' ? webSocketManager.userName : '';
    });
  }

  // Function to pick profile image
  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting image"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to pick cover image
  Future<void> _pickCoverImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _coverImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking cover image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error selecting image"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _usernameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _countryController.dispose();
    _jobTitleController.dispose();
    _webSiteController.dispose();
    _cityStateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webSocketManager = Provider.of<ProfileSocketManager>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final iconColor = Theme.of(context).extension<IconColors>()!;
    final editeProfileColors =
        Theme.of(context).extension<EditeProfileColors>()!;

    return Scaffold(
      backgroundColor: editeProfileColors.editeProfileColor,
      appBar: AppBar(
        backgroundColor: editeProfileColors.editeProfileColor,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            fontFamily: "a-m",
            fontSize: 20,
            color: textTheme.bodyMedium!.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image section
              Container(
                margin: EdgeInsets.only(top: 24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Cover",
                        style: TextStyle(
                          fontFamily: "a-m",
                          fontSize: 16,
                          color: textTheme.bodyMedium!.color,
                        ),
                      ),
                      SizedBox(height: 12),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey[200],
                              image:
                                  _coverImage != null
                                      ? DecorationImage(
                                        image: FileImage(_coverImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : DecorationImage(
                                        image:
                                            webSocketManager.profile_caver ==
                                                    null
                                                ? AssetImage(
                                                  "assets/img/kevin-mueller-MardXkt4Gdk-unsplash.jpg",
                                                )
                                                : NetworkImage(
                                                  '${ApiAddress.baseUrl}${webSocketManager.profile_caver}',
                                                ),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.background,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: ImageIcon(
                                  AssetImage(
                                    "assets/icons/edit-1-svgrepo-com.png",
                                  ),
                                  size: 25,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                padding: EdgeInsets.zero,
                                onPressed: _pickCoverImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Profile picture section
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _profileImage != null
                              ? FileImage(_profileImage!)
                              : (webSocketManager.profile_picture != null &&
                                  webSocketManager.profile_picture!.isNotEmpty)
                              ? NetworkImage(
                                    '${ApiAddress.baseUrl}${webSocketManager.profile_picture}',
                                  )
                                  as ImageProvider
                              : AssetImage(
                                'assets/img/44884218_345707102882519_2446069589734326272_n.jpg',
                              ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xfff6f6f6),
                            width: 0,
                          ),
                        ),
                        child: IconButton(
                          icon: ImageIcon(
                            AssetImage("assets/icons/edit-1-svgrepo-com.png"),
                            size: 25,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: _pickProfileImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form fields container
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        "First Name",
                        _firstNameController,
                        hintText: "Enter first Name",
                        isRequired: true,
                      ),
                      _buildFormField(
                        "Last Name",
                        _lastNameController,
                        hintText: "Enter last Name",
                        isRequired: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        "Email Address",
                        _emailController,
                        readOnly: true,
                        suffix: Container(
                          margin: EdgeInsets.only(right: 5),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check, size: 14, color: Colors.blue),
                              SizedBox(width: 2),
                              Text(
                                "VERIFIED",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Outfit-bold",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      _buildFormField(
                        "username",
                        _usernameController,
                        hintText: "Enter username",
                        isRequired: true,
                      ),

                      _buildFormField(
                        "Phone Number",
                        _phoneController,
                        hintText: "Enter Phone Number",
                      ),

                      // _buildFormField(
                      //   "Date of Birth",
                      //   _dateController,
                      //   hintText: "dd/mm/yyyy",
                      // ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        "Country",
                        _countryController,
                        hintText: "Enter Country",
                      ),

                      _buildFormField(
                        "Job Title",
                        _jobTitleController,
                        hintText: "Enter Job Title",
                      ),

                      _buildFormField(
                        "Website",
                        _webSiteController,
                        hintText: "Enter Website",
                      ),

                      _buildFormField(
                        "City/State",
                        _cityStateController,
                        hintText: "Enter City/State",
                      ),

                      _buildFormField(
                        "Bio",
                        _bioController,
                        hintText: "Enter Bio",
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              // Save button
              Container(
                margin: EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF123fdb),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Saved Change",
                            style: TextStyle(
                              fontFamily: "a-m",
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    Widget? suffix,
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isLast = false,
    bool isRequired = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Only show error if form has been submitted and field is empty
    bool hasError = _formSubmitted && isRequired && controller.text.isEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: "a-m",
                  fontSize: 16,
                  color: textTheme.bodyMedium!.color,
                ),
              ),
              if (isRequired)
                Text(
                  " *",
                  style: TextStyle(
                    fontFamily: "Outfit-Medium",
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: (value) {
              // If form has been submitted, update validation state when typing
              if (_formSubmitted && isRequired) {
                setState(() {
                  // This will trigger a rebuild to update error state
                });
              }
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor:
                  readOnly ? colorScheme.background : colorScheme.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[200]!,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: hasError ? Colors.red : Colors.grey[300]!,
                  width: hasError ? 1.5 : 1,
                ),
              ),
              suffixIcon:
                  suffix ??
                  (hasError ? Icon(Icons.error, color: Colors.red) : null),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 6),
              child: Text(
                "$label cannot be empty",
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontFamily: "a-r",
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Method to update profile with the ProfileService
  Future<void> _updateProfile() async {
    // Set form as submitted to trigger validation display
    setState(() {
      _formSubmitted = true;
      _isLoading = true;
    });

    // Check for required fields
    bool hasEmptyRequiredFields = false;

    // Check required fields
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      hasEmptyRequiredFields = true;
    }

    if (hasEmptyRequiredFields) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Please fill in all required fields',
            contentType: ContentType.failure,
          ),
        ),
      );
      return;
    }

    try {
      // Collect updated profile data
      final updatedData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'username': _usernameController.text,
        'phone_number': _phoneController.text,
        'country': _countryController.text,
        'job_title': _jobTitleController.text,
        'website': _webSiteController.text,
        'city_state': _cityStateController.text,
        'bio': _bioController.text,
      };

      // Send data using ProfileService
      final success = await _profileService.updateProfileWithImages(
        profileData: updatedData,
        profileImage: _profileImage,
        coverImage: _coverImage,
      );

      if (success) {
        // پروفایل با موفقیت بروز شد، پس مقدار newUser را به false تغییر می‌دهیم
        await _secureStorage.write(key: 'newUser', value: 'false');

        // Navigate to ButtonNavbar with profile tab selected (index 3)
        // Don't show SnackBar before navigation to avoid the deactivated widget error
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ButtonNavbar(3)),
          (route) => false,
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message: 'Failed to update profile. Please try again.',
              contentType: ContentType.failure,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'An error occurred. Please try again.',
            contentType: ContentType.failure,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
