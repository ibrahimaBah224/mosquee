import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/mosque_info.dart';
import '../../../../core/services/mosque_service.dart';

class MosqueSettingsPage extends StatefulWidget {
  const MosqueSettingsPage({super.key});

  @override
  State<MosqueSettingsPage> createState() => _MosqueSettingsPageState();
}

class _MosqueSettingsPageState extends State<MosqueSettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Controllers pour tous les champs
  final _nameController = TextEditingController();
  final _nameArabicController = TextEditingController();
  final _sloganController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _twitterController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _imamNameController = TextEditingController();
  final _imamPhoneController = TextEditingController();
  final _imamEmailController = TextEditingController();
  final _presidentNameController = TextEditingController();
  final _presidentPhoneController = TextEditingController();
  final _presidentEmailController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _mobileMoneyController = TextEditingController();
  final _paypalController = TextEditingController();
  final _capacityController = TextEditingController();
  final _servicesController = TextEditingController();
  final _logoUrlController = TextEditingController();
  final _bannerImageController = TextEditingController();
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();

  // Variables pour les équipements
  bool _hasParking = false;
  bool _hasWuduArea = true;
  bool _hasWomenSection = false;
  bool _hasChildrenArea = false;
  bool _hasLibrary = false;
  bool _hasClassrooms = false;
  bool _hasKitchen = false;
  bool _isWheelchairAccessible = false;

  // Horaires d'ouverture
  Map<String, String> _openingHours = {
    'Lundi': '05:00 - 22:00',
    'Mardi': '05:00 - 22:00',
    'Mercredi': '05:00 - 22:00',
    'Jeudi': '05:00 - 22:00',
    'Vendredi': '05:00 - 23:00',
    'Samedi': '05:00 - 22:00',
    'Dimanche': '05:00 - 22:00',
  };

  MosqueInfo? _currentInfo;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadMosqueInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _nameController.dispose();
    _nameArabicController.dispose();
    _sloganController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _timezoneController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _supportEmailController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    _imamNameController.dispose();
    _imamPhoneController.dispose();
    _imamEmailController.dispose();
    _presidentNameController.dispose();
    _presidentPhoneController.dispose();
    _presidentEmailController.dispose();
    _bankAccountController.dispose();
    _mobileMoneyController.dispose();
    _paypalController.dispose();
    _capacityController.dispose();
    _servicesController.dispose();
    _logoUrlController.dispose();
    _bannerImageController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
  }

  Future<void> _loadMosqueInfo() async {
    try {
      final info = await MosqueService().getMosqueInfo();
      if (info != null) {
        setState(() {
          _currentInfo = info;
          _populateFields(info);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement: $e')),
      );
    }
  }

  void _populateFields(MosqueInfo info) {
    _nameController.text = info.name;
    _nameArabicController.text = info.nameArabic;
    _sloganController.text = info.slogan;
    _descriptionController.text = info.description;
    _addressController.text = info.address;
    _cityController.text = info.city;
    _countryController.text = info.country;
    _latitudeController.text = info.latitude.toString();
    _longitudeController.text = info.longitude.toString();
    _timezoneController.text = info.timezone;
    _phoneController.text = info.phone;
    _emailController.text = info.email;
    _websiteController.text = info.website;
    _supportEmailController.text = info.supportEmail;
    _facebookController.text = info.facebookUrl ?? '';
    _instagramController.text = info.instagramUrl ?? '';
    _youtubeController.text = info.youtubeUrl ?? '';
    _twitterController.text = info.twitterUrl ?? '';
    _tiktokController.text = info.tiktokUrl ?? '';
    _imamNameController.text = info.imamName ?? '';
    _imamPhoneController.text = info.imamPhone ?? '';
    _imamEmailController.text = info.imamEmail ?? '';
    _presidentNameController.text = info.presidentName ?? '';
    _presidentPhoneController.text = info.presidentPhone ?? '';
    _presidentEmailController.text = info.presidentEmail ?? '';
    _bankAccountController.text = info.bankAccount ?? '';
    _mobileMoneyController.text = info.mobileMoneyNumber ?? '';
    _paypalController.text = info.paypalAccount ?? '';
    _capacityController.text = info.capacity.toString();
    _servicesController.text = info.services.join(', ');
    _logoUrlController.text = info.logoUrl;
    _bannerImageController.text = info.bannerImageUrl;
    _primaryColorController.text = info.primaryColor;
    _secondaryColorController.text = info.secondaryColor;

    _hasParking = info.hasParking;
    _hasWuduArea = info.hasWuduArea;
    _hasWomenSection = info.hasWomenSection;
    _hasChildrenArea = info.hasChildrenArea;
    _hasLibrary = info.hasLibrary;
    _hasClassrooms = info.hasClassrooms;
    _hasKitchen = info.hasKitchen;
    _isWheelchairAccessible = info.isWheelchairAccessible;

    _openingHours = Map<String, String>.from(info.openingHours);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Mosquée'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Général'),
            Tab(text: 'Localisation'),
            Tab(text: 'Contact'),
            Tab(text: 'Responsables'),
            Tab(text: 'Équipements'),
            Tab(text: 'Horaires'),
          ],
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(),
                  _buildLocationTab(),
                  _buildContactTab(),
                  _buildResponsablesTab(),
                  _buildEquipmentsTab(),
                  _buildScheduleTab(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveMosqueInfo,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.save),
        label: const Text('Sauvegarder'),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionCard('Informations générales', [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de la mosquée *',
                prefixIcon: Icon(Icons.mosque),
              ),
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameArabicController,
              decoration: const InputDecoration(
                labelText: 'Nom en arabe *',
                prefixIcon: Icon(Icons.translate),
              ),
              textDirection: TextDirection.rtl,
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sloganController,
              decoration: const InputDecoration(
                labelText: 'Slogan',
                prefixIcon: Icon(Icons.format_quote),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Apparence', [
            TextFormField(
              controller: _logoUrlController,
              decoration: const InputDecoration(
                labelText: 'URL du logo',
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bannerImageController,
              decoration: const InputDecoration(
                labelText: 'URL de l\'image de bannière',
                prefixIcon: Icon(Icons.panorama),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _primaryColorController,
                    decoration: const InputDecoration(
                      labelText: 'Couleur primaire',
                      prefixIcon: Icon(Icons.palette),
                      hintText: '#2E7D32',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _secondaryColorController,
                    decoration: const InputDecoration(
                      labelText: 'Couleur secondaire',
                      hintText: '#1565C0',
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard('Adresse', [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse *',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville *',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Pays *',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    validator: (value) =>
                        value?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Coordonnées GPS', [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      prefixIcon: Icon(Icons.gps_fixed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      prefixIcon: Icon(Icons.gps_fixed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value?.isEmpty == true ? 'Requis' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _timezoneController,
              decoration: const InputDecoration(
                labelText: 'Fuseau horaire *',
                prefixIcon: Icon(Icons.schedule),
                hintText: 'Ex: Africa/Conakry',
              ),
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard('Contact principal', [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty == true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Site web',
                prefixIcon: Icon(Icons.web),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supportEmailController,
              decoration: const InputDecoration(
                labelText: 'Email de support',
                prefixIcon: Icon(Icons.support),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Réseaux sociaux', [
            TextFormField(
              controller: _facebookController,
              decoration: const InputDecoration(
                labelText: 'Facebook',
                prefixIcon: Icon(Icons.facebook),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(
                labelText: 'Instagram',
                prefixIcon: Icon(Icons.camera_alt),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _youtubeController,
              decoration: const InputDecoration(
                labelText: 'YouTube',
                prefixIcon: Icon(Icons.video_library),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _twitterController,
              decoration: const InputDecoration(
                labelText: 'Twitter/X',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tiktokController,
              decoration: const InputDecoration(
                labelText: 'TikTok',
                prefixIcon: Icon(Icons.music_video),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Informations financières', [
            TextFormField(
              controller: _mobileMoneyController,
              decoration: const InputDecoration(
                labelText: 'Mobile Money (Orange/MTN)',
                prefixIcon: Icon(Icons.phone_android),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bankAccountController,
              decoration: const InputDecoration(
                labelText: 'Compte bancaire',
                prefixIcon: Icon(Icons.account_balance),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paypalController,
              decoration: const InputDecoration(
                labelText: 'PayPal',
                prefixIcon: Icon(Icons.payment),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildResponsablesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard('Imam', [
            TextFormField(
              controller: _imamNameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'Imam',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imamPhoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone de l\'Imam',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _imamEmailController,
              decoration: const InputDecoration(
                labelText: 'Email de l\'Imam',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Président/Responsable', [
            TextFormField(
              controller: _presidentNameController,
              decoration: const InputDecoration(
                labelText: 'Nom du Président',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _presidentPhoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone du Président',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _presidentEmailController,
              decoration: const InputDecoration(
                labelText: 'Email du Président',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildEquipmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard('Capacité', [
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacité d\'accueil',
                prefixIcon: Icon(Icons.people),
                suffix: Text('personnes'),
              ),
              keyboardType: TextInputType.number,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Équipements disponibles', [
            SwitchListTile(
              title: const Text('Parking'),
              subtitle: const Text('Places de stationnement'),
              value: _hasParking,
              onChanged: (value) => setState(() => _hasParking = value),
            ),
            SwitchListTile(
              title: const Text('Zone d\'ablutions'),
              subtitle: const Text('Espace pour les ablutions'),
              value: _hasWuduArea,
              onChanged: (value) => setState(() => _hasWuduArea = value),
            ),
            SwitchListTile(
              title: const Text('Section femmes'),
              subtitle: const Text('Espace dédié aux femmes'),
              value: _hasWomenSection,
              onChanged: (value) => setState(() => _hasWomenSection = value),
            ),
            SwitchListTile(
              title: const Text('Espace enfants'),
              subtitle: const Text('Zone pour les enfants'),
              value: _hasChildrenArea,
              onChanged: (value) => setState(() => _hasChildrenArea = value),
            ),
            SwitchListTile(
              title: const Text('Bibliothèque'),
              subtitle: const Text('Livres islamiques'),
              value: _hasLibrary,
              onChanged: (value) => setState(() => _hasLibrary = value),
            ),
            SwitchListTile(
              title: const Text('Salles de classe'),
              subtitle: const Text('Pour les cours'),
              value: _hasClassrooms,
              onChanged: (value) => setState(() => _hasClassrooms = value),
            ),
            SwitchListTile(
              title: const Text('Cuisine'),
              subtitle: const Text('Préparation de repas'),
              value: _hasKitchen,
              onChanged: (value) => setState(() => _hasKitchen = value),
            ),
            SwitchListTile(
              title: const Text('Accessible PMR'),
              subtitle: const Text('Accès handicapés'),
              value: _isWheelchairAccessible,
              onChanged: (value) =>
                  setState(() => _isWheelchairAccessible = value),
            ),
          ]),
          const SizedBox(height: 16),
          _buildSectionCard('Services proposés', [
            TextFormField(
              controller: _servicesController,
              decoration: const InputDecoration(
                labelText: 'Services (séparés par des virgules)',
                prefixIcon: Icon(Icons.list),
                hintText: 'Prières quotidiennes, Cours de Coran, Mariage...',
              ),
              maxLines: 3,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            'Horaires d\'ouverture',
            _openingHours.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: entry.value,
                        decoration: InputDecoration(
                          hintText: '05:00 - 22:00',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        onChanged: (value) {
                          _openingHours[entry.key] = value;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Future<void> _saveMosqueInfo() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez corriger les erreurs')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final services = _servicesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updatedInfo = MosqueInfo(
        id: _currentInfo?.id ?? 'main',
        name: _nameController.text.trim(),
        nameArabic: _nameArabicController.text.trim(),
        slogan: _sloganController.text.trim(),
        description: _descriptionController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        country: _countryController.text.trim(),
        latitude: double.tryParse(_latitudeController.text) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text) ?? 0.0,
        timezone: _timezoneController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        website: _websiteController.text.trim(),
        supportEmail: _supportEmailController.text.trim(),
        facebookUrl: _facebookController.text.trim().isNotEmpty
            ? _facebookController.text.trim()
            : null,
        instagramUrl: _instagramController.text.trim().isNotEmpty
            ? _instagramController.text.trim()
            : null,
        youtubeUrl: _youtubeController.text.trim().isNotEmpty
            ? _youtubeController.text.trim()
            : null,
        twitterUrl: _twitterController.text.trim().isNotEmpty
            ? _twitterController.text.trim()
            : null,
        tiktokUrl: _tiktokController.text.trim().isNotEmpty
            ? _tiktokController.text.trim()
            : null,
        openingHours: Map<String, String>.from(_openingHours),
        imamName: _imamNameController.text.trim().isNotEmpty
            ? _imamNameController.text.trim()
            : null,
        imamPhone: _imamPhoneController.text.trim().isNotEmpty
            ? _imamPhoneController.text.trim()
            : null,
        imamEmail: _imamEmailController.text.trim().isNotEmpty
            ? _imamEmailController.text.trim()
            : null,
        presidentName: _presidentNameController.text.trim().isNotEmpty
            ? _presidentNameController.text.trim()
            : null,
        presidentPhone: _presidentPhoneController.text.trim().isNotEmpty
            ? _presidentPhoneController.text.trim()
            : null,
        presidentEmail: _presidentEmailController.text.trim().isNotEmpty
            ? _presidentEmailController.text.trim()
            : null,
        bankAccount: _bankAccountController.text.trim().isNotEmpty
            ? _bankAccountController.text.trim()
            : null,
        mobileMoneyNumber: _mobileMoneyController.text.trim().isNotEmpty
            ? _mobileMoneyController.text.trim()
            : null,
        paypalAccount: _paypalController.text.trim().isNotEmpty
            ? _paypalController.text.trim()
            : null,
        capacity: int.tryParse(_capacityController.text) ?? 0,
        hasParking: _hasParking,
        hasWuduArea: _hasWuduArea,
        hasWomenSection: _hasWomenSection,
        hasChildrenArea: _hasChildrenArea,
        hasLibrary: _hasLibrary,
        hasClassrooms: _hasClassrooms,
        hasKitchen: _hasKitchen,
        isWheelchairAccessible: _isWheelchairAccessible,
        services: services,
        appVersion: _currentInfo?.appVersion ?? '1.0.0',
        logoUrl: _logoUrlController.text.trim(),
        bannerImageUrl: _bannerImageController.text.trim(),
        primaryColor: _primaryColorController.text.trim(),
        secondaryColor: _secondaryColorController.text.trim(),
        createdAt: _currentInfo?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        lastUpdatedBy: 'admin',
      );

      await MosqueService().updateMosqueInfo(updatedInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations sauvegardées avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/admin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
