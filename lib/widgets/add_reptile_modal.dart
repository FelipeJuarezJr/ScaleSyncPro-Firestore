import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../models/reptile.dart';
import '../services/reptile_service.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';

class AddReptileModal extends StatefulWidget {
  const AddReptileModal({super.key});

  @override
  State<AddReptileModal> createState() => _AddReptileModalState();
}

class _AddReptileModalState extends State<AddReptileModal> {
  final _formKey = GlobalKey<FormState>();
  final _speciesController = TextEditingController();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _morphController = TextEditingController();
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();
  final _breederController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedGender = 'unknown'; // 'male', 'female', 'unknown'
  String _selectedGroup = '[No group]';
  final List<String> _groups = ['[No group]', 'Breeders', 'Hatchlings', 'Holdbacks'];
  
  String _selectedLengthUnit = 'cm';
  final List<String> _lengthUnits = ['cm', 'in'];
  
  String _selectedWeightUnit = 'gr';
  final List<String> _weightUnits = ['gr', 'kg', 'oz', 'lbs'];

  DateTime? _selectedBirthDate;
  bool _isSaving = false;

  // Image upload and camera options
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageFileName;

  // Static list of reptile and animal species provided by the user
  static const List<String> _speciesList = [
    // Snakes by Species
    // Pythons (Pythonidae)
    "Ball Python (Python regius)",
    "Reticulated Python (Malayopython reticulatus)",
    "Burmese Python (Python bivittatus)",
    "Green Tree Python (Morelia viridis)",
    // Carpet Pythons
    "Irian Jaya / West Papuan (Morelia spilota harrisoni)",
    "Jungle Carpet (Morelia spilota cheynei)",
    "Coastal Carpet (Morelia spilota mcdowelli)",
    "Diamond Python (Morelia spilota spilota)",
    // Short-Tailed & Blood Pythons
    "Blood Python (Python brongersmai)",
    "Borneo Short-Tailed Python (Python breitensteini)",
    "Sumatran Short-Tailed Python (Python curtus)",
    // Children's Python Complex
    "Children's Python (Antaresia childreni)",
    "Spotted Python (Antaresia maculosa)",
    "Stimson's Python (Antaresia stimsoni)",
    "Pygmy Python (Antaresia perthenis)",
    // Other Pythons
    "Woma Python (Aspidites ramsayi)",
    "Black-Headed Python (Aspidites melanocephalus)",
    "White-Lipped Python (Bothrochilus albertisii)",
    "Angolan Python (Python anchietae)",
    "Scrub Python (Simalia amethistina)",
    // Boas (Boidae)
    // Boa Constrictors
    "Common Northern / BCI (Boa imperator)",
    "True Red-Tail / BCC (Boa constrictor constrictor)",
    "Argentine Boa (Boa constrictor occidentalis)",
    // Sand Boas
    "Kenyan Sand Boa (Eryx colubrinus)",
    "Russian/Tartar Sand Boa (Eryx tataricus)",
    "Sahara Sand Boa (Eryx muelleri)",
    "Rosy Boas (Lichanura trivirgata)",
    // Rainbow Boas
    "Brazilian Rainbow Boa (Epicrates cenchria)",
    "Colombian Rainbow Boa (Epicrates maurus)",
    // Other Boas
    "Dumeril's Boa (Acrantophis dumerili)",
    "Emerald Tree Boa (Corallus caninus)",
    "Amazon Tree Boa (Corallus hortulana)",
    "Pacific Boa (Candoia aspera)",
    // Colubrids & True Snakes
    "Corn Snake (Pantherophis guttatus)",
    "Western Hognose (Heterodon nasicus)",
    // Kingsnakes
    "California Kingsnake (Lampropeltis californiae)",
    "Mexican Black Kingsnake (Lampropeltis getula nigrita)",
    "Florida Kingsnake (Lampropeltis getula floridana)",
    "Grey-Banded Kingsnake (Lampropeltis alterna)",
    // Milk Snakes
    "Honduran Milk Snake (Lampropeltis triangulum hondurensis)",
    "Nelson's Milk Snake (Lampropeltis triangulum nelsoni)",
    "Sinaloan Milk Snake (Lampropeltis triangulum sinaloae)",
    "Pueblan Milk Snake (Lampropeltis triangulum campbelli)",
    // Rat Snakes
    "Black Rat Snake (Pantherophis obsoletus)",
    "Texas Rat Snake (Pantherophis obsoletus lindheimeri)",
    "Baird's Rat Snake (Pantherophis bairdi)",
    "Asian Beauty Snake (Elaphe taeniura)",
    "Mandarin Rat Snake (Euprepiophis mandarinus)",
    // Bull, Gopher & Pine Snakes
    "Bullsnake (Pituophis catenifer sayi)",
    "Pacific Gopher Snake (Pituophis catenifer catenifer)",
    "San Diego Gopher Snake (Pituophis catenifer annectens)",
    "Pine Snake (Pituophis melanoleucus)",
    // Garter Snakes
    "Plains Garter Snake (Thamnophis radix)",
    "Checkered Garter Snake (Thamnophis marcianus)",
    "San Francisco Garter Snake (Thamnophis sirtalis tetrataenia)",
    // Other Notable Colubrids/Snakes
    "African House Snake (Boaedon fuliginosus)",
    "African Egg-Eating Snake (Dasypeltis scabra)",
    "African File Snake (Gonionotophis capensis)",

    // Lizards & Geckos by Species
    // Geckos
    "Crested Gecko (Correlophus ciliatus)",
    "Leopard Gecko (Eublepharis macularius)",
    "Gargoyle Gecko (Rhacodactylus auriculatus)",
    "African Fat-Tailed Gecko (Hemitheconyx caudicinctus)",
    "Chahoua Gecko / Mossy Prehensile-Tailed (Mniarogekko chahoua)",
    "Leachianus / New Caledonian Giant Gecko (Rhacodactylus leachianus)",
    // Day Geckos
    "Giant Day Gecko (Phelsuma grandis)",
    "Gold Dust Day Gecko (Phelsuma laticauda)",
    "Peacock Day Gecko (Phelsuma quadriocellata)",
    // Knob-Tailed Geckos
    "Smooth Knob-Tailed Gecko (Nephrurus levis)",
    "Rough Knob-Tailed Gecko (Nephrurus amyae)",
    // Other Geckos
    "Tokay Gecko (Gekko gecko)",
    "Chinese Cave Gecko (Goniurosaurus hainanensis)",
    "Mourning Gecko (Lepidodactylus lugubris)",
    "Viper Gecko (Hemidactylus imbricatus)",
    // Other Lizards
    "Bearded Dragon (Pogona vitticeps)",
    // Blue Tongue Skinks
    "Northern Blue Tongue Skink (Tiliqua scincoides intermedia)",
    "Indonesian Blue Tongue Skink (Tiliqua gigas)",
    "Halmahera Blue Tongue Skink (Tiliqua gigas gigas)",
    "Shingleback Skink (Tiliqua rugosa)",
    // Monitors
    "Ackie Monitor (Varanus acanthurus)",
    "Savannah Monitor (Varanus exanthematicus)",
    "Nile Monitor (Varanus niloticus)",
    "Asian Water Monitor (Varanus salvator)",
    "Emerald Tree Monitor (Varanus prasinus)",
    "Black Tree Monitor (Varanus beccarii)",
    // Tegus
    "Argentine Black and White Tegu (Salvator merianae)",
    "Red Tegu (Salvator rufescens)",
    "Golden Tegu (Tupinambis teguixin)",
    // Uromastyx
    "Saharan Uromastyx (Uromastyx geyri)",
    "Ornate Uromastyx (Uromastyx ornata)",
    "Ocellated Uromastyx (Uromastyx ocellata)",
    "Mali Uromastyx (Uromastyx maliensis)",
    // Chameleons
    "Panther Chameleon (Furcifer pardalis)",
    "Veiled Chameleon (Chamaeleo calyptratus)",
    "Jackson's Chameleon (Trioceros jacksonii)",
    // Iguanas
    "Green Iguana (Iguana iguana)",
    "Rhinoceros Iguana (Cyclura cornuta)",
    "Spiny-Tailed Iguana (Ctenosaura similis)",

    // Chelonia by Species (Turtles & Tortoises)
    // Tortoises
    "Sulcata Tortoise (Centrochelys sulcata)",
    "Leopard Tortoise (Stigmochelys pardalis)",
    "Red-Footed Tortoise (Chelonoidis carbonarius)",
    "Cherry Head Tortoise (Chelonoidis carbonarius var)",
    "Yellow-Footed Tortoise (Chelonoidis denticulatus)",
    "Russian Tortoise (Agrionemys horsfieldii)",
    "Greek Tortoise (Testudo graeca)",
    "Hermann's Tortoise (Testudo hermanni)",
    "Radiated Tortoise (Astrochelys radiata)",
    // Turtles
    // Box Turtles
    "Eastern Box Turtle (Terrapene carolina carolina)",
    "Three-Toed Box Turtle (Terrapene carolina triunguis)",
    "Ornate Box Turtle (Terrapene ornata)",
    // Water & Pond Turtles
    "Red-Eared Slider (Trachemys scripta elegans)",
    "Cooter Turtles (Pseudemys species)",
    "Diamondback Terrapin (Malaclemys terrapin)",
    "Common Musk Turtle / Stinkpot (Sternotherus odoratus)",
    "Razorback Musk Turtle (Sternotherus carinatus)",
    "Three-Striped Mud Turtle (Kinosternon baurii)",
    "Spotted Turtle (Clemmys guttata)",

    // Amphibians by Species
    "Axolotl (Ambystoma mexicanum)",
    // Dart Frogs
    "Green and Black Poison Dart Frog (Dendrobates auratus)",
    "Bumblebee Poison Dart Frog (Dendrobates leucomelas)",
    "Blue Poison Dart Frog (Dendrobates tinctorius)",
    // Tree Frogs
    "Red-Eyed Tree Frog (Agalychnis callidryas)",
    "White's Tree Frog / Dumpy (Ranoidea caerulea)",
    // Horned Frogs
    "Pacman Frog (Ceratophrys cranwelli or Ceratophrys cornuta)",
    // Toads
    "Cane Toad (Rhinella marina)",
    "Colorado River Toad (Incilius alvarius)",

    // Invertebrates by Species
    // Tarantulas (Theraphosidae)
    "Mexican Red Knee (Brachypelma hamorii)",
    "Curly Hair Tarantula (Tliltocatl albopilosus)",
    "Pink Toe Tarantula (Avicularia avicularia)",
    "Greenbottle Blue (Chromatopelma cyaneopubescens)",
    "Brazilian Black (Grammostola pulchra)",
    // Isopods
    "Dairy Cow Isopod (Porcellio laevis)",
    "Zebra Isopod (Armadillidium maculatum)",
    "Rubber Ducky Isopod (Cubaris species)",
    // Scorpions & Others
    "Emperor Scorpion (Pandinus imperator)",
    "Asian Forest Scorpion (Heterometrus silenus)",
    "Spiny Flower Mantis (Pseudocreobotra wahlbergii)",
    "Ghost Mantis (Phyllocrania paradoxa)",
  ];

  @override
  void dispose() {
    _speciesController.dispose();
    _nameController.dispose();
    _identifierController.dispose();
    _morphController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _breederController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _showAddGroupDialog() {
    final groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Group'),
        content: TextField(
          controller: groupNameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g. Holdbacks 2026',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newGroup = groupNameController.text.trim();
              if (newGroup.isNotEmpty) {
                setState(() {
                  if (!_groups.contains(newGroup)) {
                    _groups.add(newGroup);
                  }
                  _selectedGroup = newGroup;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFileName = image.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageFileName = null;
    });
  }

  Future<void> _selectBirthDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedBirthDate = pickedDate;
      });
    }
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final speciesVal = _speciesController.text.trim();
      final nameVal = _nameController.text.trim();
      final identifierVal = _identifierController.text.trim();
      final morphVal = _morphController.text.trim();
      final lengthVal = double.tryParse(_lengthController.text.trim()) ?? 0.0;
      final weightVal = double.tryParse(_weightController.text.trim()) ?? 0.0;
      final breederVal = _breederController.text.trim();
      final remarksVal = _remarksController.text.trim();

      // Bundle measurements
      final Map<String, dynamic> measurements = {
        'length': lengthVal,
        'lengthUnit': _selectedLengthUnit,
        'weight': weightVal,
        'weightUnit': _selectedWeightUnit,
      };

      if (identifierVal.isNotEmpty) {
        measurements['identifier'] = identifierVal;
      }
      if (_selectedGroup != '[No group]') {
        measurements['group'] = _selectedGroup;
      }

      List<String> photoUrls = [];
      if (_imageBytes != null) {
        final storage = StorageService();
        final fileName = _imageFileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploadPath = 'reptiles/$fileName';
        final downloadUrl = await storage.uploadFile(
          path: uploadPath,
          data: _imageBytes!,
          contentType: 'image/jpeg',
        );
        photoUrls.add(downloadUrl);
      }

      final newReptile = Reptile(
        name: nameVal.isEmpty ? 'Unnamed $speciesVal' : nameVal,
        species: speciesVal,
        gender: _selectedGender,
        morph: morphVal.isEmpty ? 'Normal' : morphVal,
        birthDate: _selectedBirthDate,
        acquisitionDate: DateTime.now(),
        breeder: breederVal.isEmpty ? null : breederVal,
        notes: remarksVal.isEmpty ? null : remarksVal,
        status: 'active',
        measurements: measurements,
        photoUrls: photoUrls,
      );

      final service = ReptileService();
      await service.addReptile(newReptile);

      if (mounted) {
        Navigator.pop(context, true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newReptile.name} added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save animal: $e'),
            backgroundColor: AppTheme.dangerColor,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Custom dark green header color for diurnal/light theme to match mockup
    final headerBgColor = isDark ? AppTheme.bgPrimary : const Color(0xFF2C5530);
    final headerTextColor = Colors.white;

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLg),
        side: isDark ? const BorderSide(color: AppTheme.borderColor) : BorderSide.none,
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Container(
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.borderRadiusLg),
                  topRight: Radius.circular(AppTheme.borderRadiusLg),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add an animal',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: headerTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: headerTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: headerTextColor),
                    onPressed: _isSaving ? null : _saveAnimal,
                  ),
                ],
              ),
            ),
            
            // Subtext Banner
            Container(
              color: isDark ? AppTheme.bgSecondary : const Color(0xFFF1F3F4),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Enter a name or an identifier, or both if you want to',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                ),
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Selector
                      Text(
                        'Reptile Photo',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.bgTertiary : const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                            border: Border.all(
                              color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                            ),
                          ),
                          child: _imageBytes != null
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppTheme.borderRadius - 1),
                                      child: Image.memory(
                                        _imageBytes!,
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: InkWell(
                                        onTap: _removeImage,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: Colors.black.withOpacity(0.6),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 40,
                                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () => _pickImage(ImageSource.gallery),
                                          icon: const Icon(Icons.photo_library, size: 16),
                                          label: const Text('Upload Image'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? AppTheme.bgSecondary : const Color(0xFFE2E8F0),
                                            foregroundColor: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ElevatedButton.icon(
                                          onPressed: () => _pickImage(ImageSource.camera),
                                          icon: const Icon(Icons.camera_alt, size: 16),
                                          label: const Text('Take Photo'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDark ? AppTheme.bgSecondary : const Color(0xFFE2E8F0),
                                            foregroundColor: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Type of animal (Autocomplete field)
                      Text(
                        'Type of animal / Species',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      RawAutocomplete<String>(
                        textEditingController: _speciesController,
                        focusNode: FocusNode(),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return _speciesList.where((String option) {
                            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Ball Python, Leopard Gecko...',
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Species/Type of animal is required';
                              }
                              return null;
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              color: isDark ? AppTheme.bgTertiary : Colors.white,
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Two column layout for Name & Identifier
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter name...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Identifier',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _identifierController,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. ID-09832',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Group and Sex Toggles
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedGroup,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        items: _groups.map((group) {
                                          return DropdownMenuItem<String>(
                                            value: group,
                                            child: Text(group),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedGroup = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        backgroundColor: isDark ? AppTheme.bgTertiary : AppTheme.lightBgTertiary,
                                        foregroundColor: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                          side: BorderSide(
                                            color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                                          ),
                                        ),
                                      ),
                                      onPressed: _showAddGroupDialog,
                                      child: const Row(
                                        children: [
                                          Icon(Icons.add, size: 16),
                                          SizedBox(width: 4),
                                          Text('Add'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sex',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppTheme.bgTertiary : const Color(0xFFF1F3F4),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                    border: Border.all(
                                      color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Row(
                                    children: [
                                      // Female (♀) Button
                                      Expanded(
                                        child: _SexToggleCell(
                                          label: '♀',
                                          isSelected: _selectedGender == 'female',
                                          selectedBgColor: const Color(0xFFFFE0B2), // Light peach/orange
                                          selectedFgColor: Colors.black87,
                                          onTap: () {
                                            setState(() {
                                              _selectedGender = 'female';
                                            });
                                          },
                                        ),
                                      ),
                                      // Male (♂) Button
                                      Expanded(
                                        child: _SexToggleCell(
                                          label: '♂',
                                          isSelected: _selectedGender == 'male',
                                          selectedBgColor: const Color(0xFFE3F2FD), // Light blue
                                          selectedFgColor: Colors.black87,
                                          onTap: () {
                                            setState(() {
                                              _selectedGender = 'male';
                                            });
                                          },
                                        ),
                                      ),
                                      // Unknown (?) Button
                                      Expanded(
                                        child: _SexToggleCell(
                                          label: '?',
                                          isSelected: _selectedGender == 'unknown',
                                          selectedBgColor: isDark ? AppTheme.primaryColor : const Color(0xFF4A7C59),
                                          selectedFgColor: isDark ? Colors.black : Colors.white,
                                          onTap: () {
                                            setState(() {
                                              _selectedGender = 'unknown';
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Morph Input
                      Text(
                        'Morph',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _morphController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Pastel, Normal, Albino...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Length and Weight Fields with units
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Length',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _lengthController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 80,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedLengthUnit,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        items: _lengthUnits.map((unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedLengthUnit = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _weightController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          hintText: '0',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 80,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedWeightUnit,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                        items: _weightUnits.map((unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              _selectedWeightUnit = val;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Birthdate & Breeder
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Birthdate',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectBirthDate,
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppTheme.bgTertiary : theme.inputDecorationTheme.fillColor,
                                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                      border: Border.all(
                                        color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _selectedBirthDate != null
                                                ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                                                : 'Select birthdate...',
                                            style: TextStyle(
                                              color: _selectedBirthDate != null
                                                  ? (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary)
                                                  : (isDark ? AppTheme.textLight : AppTheme.lightTextLight),
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 18,
                                          color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Breeder',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _breederController,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter breeder...',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Remarks
                      Text(
                        'Remarks',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _remarksController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'add your remarks here...',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Actions Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      foregroundColor: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      side: BorderSide(
                        color: isDark ? AppTheme.borderColor : AppTheme.lightBorderColor,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveAnimal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: isDark ? AppTheme.primaryColor : const Color(0xFF4A7C59),
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SexToggleCell extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedBgColor;
  final Color selectedFgColor;
  final VoidCallback onTap;

  const _SexToggleCell({
    required this.label,
    required this.isSelected,
    required this.selectedBgColor,
    required this.selectedFgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius - 2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected
                ? selectedFgColor
                : (isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
