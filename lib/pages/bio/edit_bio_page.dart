import 'package:circlo_app/features/auth/bloc/auth_bloc.dart';
import 'package:circlo_app/features/auth/bloc/auth_event.dart';
import 'package:circlo_app/features/auth/bloc/auth_state.dart';
import 'package:circlo_app/features/bio/bloc/bio_bloc.dart';
import 'package:circlo_app/features/bio/bloc/bio_event.dart';
import 'package:circlo_app/features/bio/bloc/bio_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

const _kPurple = Color(0xFF6C63FF);

class EditBioPage extends StatefulWidget {
  const EditBioPage({super.key});

  @override
  State<EditBioPage> createState() => _EditBioPageState();
}

class _EditBioPageState extends State<EditBioPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _websiteCtrl;

  bool _hasBio = false;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final existingBio = authState is AuthAuthenticated
        ? authState.user.bio
        : null;
    _hasBio = existingBio != null;
    _bioCtrl = TextEditingController(text: existingBio?.bio ?? '');
    _locationCtrl = TextEditingController(text: existingBio?.location ?? '');
    _websiteCtrl = TextEditingController(text: existingBio?.website ?? '');
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  // ── GPS AUTO-DETECT ──────────────────────────────────────────
  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);

    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationSnackbar(
          'Location services are disabled. Please enable GPS.',
          isError: true,
        );
        return;
      }

      // 2. Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationSnackbar(
          permission == LocationPermission.deniedForever
              ? 'Location permission permanently denied. Enable it in Settings.'
              : 'Location permission denied.',
          isError: true,
        );
        return;
      }

      // 3. Try last known position first (instant), then fresh fix
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          // NO timeLimit — it throws a hard exception that kills the whole flow
        ),
      );

      // 4. Reverse geocode — isolated try/catch so a network hiccup
      //    still shows the raw coordinates rather than a hard failure
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if (p.locality != null && p.locality!.isNotEmpty) p.locality!,
            if (p.administrativeArea != null &&
                p.administrativeArea!.isNotEmpty)
              p.administrativeArea!,
            if (p.country != null && p.country!.isNotEmpty) p.country!,
          ];
          final locationStr = parts.isNotEmpty
              ? parts.join(', ')
              : _rawCoords(position);
          _locationCtrl.text = locationStr;
          HapticFeedback.lightImpact();
          _showLocationSnackbar('Location detected: $locationStr');
        } else {
          // Geocoding returned nothing — fall back to raw coords
          _locationCtrl.text = _rawCoords(position);
          HapticFeedback.lightImpact();
          _showLocationSnackbar('Location set from GPS coordinates.');
        }
      } catch (_) {
        // Geocoding failed (no internet?) — still fill with raw coords
        _locationCtrl.text = _rawCoords(position);
        HapticFeedback.lightImpact();
        _showLocationSnackbar('Location set from GPS coordinates.');
      }
    } on LocationServiceDisabledException {
      _showLocationSnackbar(
        'Location services are disabled. Please enable GPS.',
        isError: true,
      );
    } on PermissionDeniedException {
      _showLocationSnackbar('Location permission denied.', isError: true);
    } catch (e) {
      // Show the real error so it's easier to diagnose
      _showLocationSnackbar('Location error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  String _rawCoords(Position p) =>
      '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';

  void _showLocationSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: isError ? Colors.redAccent : _kPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── SUBMIT ───────────────────────────────────────────────────
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    final bioText = _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim();
    final location = _locationCtrl.text.trim().isEmpty
        ? null
        : _locationCtrl.text.trim();
    final website = _websiteCtrl.text.trim().isEmpty
        ? null
        : _websiteCtrl.text.trim();

    if (_hasBio) {
      context.read<BioBloc>().add(
        BioUpdateRequested(bio: bioText, location: location, website: website),
      );
    } else {
      context.read<BioBloc>().add(
        BioCreateRequested(bio: bioText, location: location, website: website),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final surface = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5);
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final hint = isDark ? Colors.grey[500]! : Colors.grey[500]!;

    return BlocListener<BioBloc, BioState>(
      listener: (context, state) {
        if (state is BioSuccess) {
          // Silent refresh — updates user.bio WITHOUT emitting AuthLoading,
          // so the router never redirects to /splash
          context.read<AuthBloc>().add(AuthRefreshUserRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _hasBio ? 'Bio updated successfully!' : 'Bio created!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: _kPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
          context.pop();
        } else if (state is BioFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: GoogleFonts.poppins()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      child: BlocBuilder<BioBloc, BioState>(
        builder: (context, state) {
          final isLoading = state is BioLoading;

          return Scaffold(
            backgroundColor: bg,
            appBar: AppBar(
              backgroundColor: bg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: textPrimary,
                  size: 20,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: textPrimary,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _kPurple,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: _submit,
                          child: Text(
                            'Save',
                            style: GoogleFonts.poppins(
                              color: _kPurple,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 8),

                  Text(
                    'Tell people about yourself',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: hint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Bio field ──────────────────────────────────
                  _BioTextField(
                    controller: _bioCtrl,
                    label: 'Bio',
                    hint: 'Write a short bio…',
                    icon: Icons.edit_note_rounded,
                    maxLines: 4,
                    surface: surface,
                    textPrimary: textPrimary,
                    hintColor: hint,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // ── Location field with GPS button ─────────────
                  _LocationField(
                    controller: _locationCtrl,
                    surface: surface,
                    textPrimary: textPrimary,
                    hintColor: hint,
                    isDark: isDark,
                    isFetching: _fetchingLocation,
                    onDetect: _fetchLocation,
                  ),
                  const SizedBox(height: 16),

                  // ── Website field ──────────────────────────────
                  _BioTextField(
                    controller: _websiteCtrl,
                    label: 'Website',
                    hint: 'https://yourwebsite.com',
                    icon: Icons.link_rounded,
                    maxLines: 1,
                    keyboardType: TextInputType.url,
                    surface: surface,
                    textPrimary: textPrimary,
                    hintColor: hint,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 40),

                  // ── Save button ────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: isLoading
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF9B59B6)],
                            ),
                      color: isLoading ? Colors.grey[600] : null,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: _kPurple.withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: isLoading ? null : _submit,
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _hasBio ? 'Update Bio' : 'Create Bio',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LOCATION FIELD  (with GPS detect button)
// ─────────────────────────────────────────────────────────────
class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final Color surface;
  final Color textPrimary;
  final Color hintColor;
  final bool isDark;
  final bool isFetching;
  final VoidCallback onDetect;

  const _LocationField({
    required this.controller,
    required this.surface,
    required this.textPrimary,
    required this.hintColor,
    required this.isDark,
    required this.isFetching,
    required this.onDetect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: _kPurple),
            const SizedBox(width: 6),
            Text(
              'Location',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const Spacer(),
            // ── Auto-detect button ───────────────────────────
            GestureDetector(
              onTap: isFetching ? null : onDetect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kPurple.withValues(alpha: isFetching ? 0.12 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _kPurple.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isFetching)
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: _kPurple,
                        ),
                      )
                    else
                      const Icon(
                        Icons.my_location_rounded,
                        size: 13,
                        color: _kPurple,
                      ),
                    const SizedBox(width: 5),
                    Text(
                      isFetching ? 'Detecting…' : 'Auto-detect',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _kPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: 'Where are you based?',
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: hintColor),
            filled: true,
            fillColor: surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  GENERIC BIO TEXT FIELD
// ─────────────────────────────────────────────────────────────
class _BioTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final Color surface;
  final Color textPrimary;
  final Color hintColor;
  final bool isDark;

  const _BioTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.maxLines,
    required this.surface,
    required this.textPrimary,
    required this.hintColor,
    required this.isDark,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _kPurple),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, color: textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 14, color: hintColor),
            filled: true,
            fillColor: surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
