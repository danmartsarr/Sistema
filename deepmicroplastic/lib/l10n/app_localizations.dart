import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';


/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'RAVI System'**
  String get appTitle;

  /// No description provided for @appAcronymR.
  ///
  /// In en, this message translates to:
  /// **'ecognition'**
  String get appAcronymR;

  /// No description provided for @appAcronymA.
  ///
  /// In en, this message translates to:
  /// **'utomated'**
  String get appAcronymA;

  /// No description provided for @appAcronymV.
  ///
  /// In en, this message translates to:
  /// **'ia'**
  String get appAcronymV;

  /// No description provided for @appAcronymI.
  ///
  /// In en, this message translates to:
  /// **'nfrared'**
  String get appAcronymI;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Microplastic Identification by FTIR'**
  String get appTagline;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login;

  /// No description provided for @loginInstitution.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get loginInstitution;

  /// No description provided for @loginInstitutionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. usp'**
  String get loginInstitutionHint;

  /// No description provided for @loginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginUsername;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginEnter.
  ///
  /// In en, this message translates to:
  /// **'ENTER'**
  String get loginEnter;

  /// No description provided for @loginInstitutionContinue.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get loginInstitutionContinue;

  /// No description provided for @loginInstitutionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Institution not found.'**
  String get loginInstitutionNotFound;

  /// No description provided for @loginUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get loginUserNotFound;

  /// No description provided for @loginFillAll.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields.'**
  String get loginFillAll;

  /// No description provided for @loginFirstRunBanner.
  ///
  /// In en, this message translates to:
  /// **'First run — create the system administrator and the first institution.'**
  String get loginFirstRunBanner;

  /// No description provided for @loginCreateFirstAdmin.
  ///
  /// In en, this message translates to:
  /// **'CREATE ADMIN ACCOUNT'**
  String get loginCreateFirstAdmin;

  /// No description provided for @loginNewInstitution.
  ///
  /// In en, this message translates to:
  /// **'Register a new institution'**
  String get loginNewInstitution;

  /// No description provided for @loginNewInstitutionDesc.
  ///
  /// In en, this message translates to:
  /// **'Only system administrators can create institutions.'**
  String get loginNewInstitutionDesc;

  /// No description provided for @loginAdminFullName.
  ///
  /// In en, this message translates to:
  /// **'Administrator full name'**
  String get loginAdminFullName;

  /// No description provided for @loginAdminEmail.
  ///
  /// In en, this message translates to:
  /// **'Administrator e-mail'**
  String get loginAdminEmail;

  /// No description provided for @loginInstitutionName.
  ///
  /// In en, this message translates to:
  /// **'Institution name'**
  String get loginInstitutionName;

  /// No description provided for @loginPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 6 characters.'**
  String get loginPasswordMin;

  /// No description provided for @loginInstitutionAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'An institution with this slug already exists.'**
  String get loginInstitutionAlreadyExists;

  /// No description provided for @loginCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create. Check your connection.'**
  String get loginCreateError;

  /// No description provided for @loginChangeInstitution.
  ///
  /// In en, this message translates to:
  /// **'Change institution'**
  String get loginChangeInstitution;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'FTIR Analysis'**
  String get homeTitle;

  /// No description provided for @homeKpiTotalSamples.
  ///
  /// In en, this message translates to:
  /// **'Total samples'**
  String get homeKpiTotalSamples;

  /// No description provided for @homeKpiCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get homeKpiCollections;

  /// No description provided for @homeKpiVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get homeKpiVerified;

  /// No description provided for @homePolymerDistribution.
  ///
  /// In en, this message translates to:
  /// **'Polymer distribution'**
  String get homePolymerDistribution;

  /// No description provided for @homeRegisteredCollections.
  ///
  /// In en, this message translates to:
  /// **'Registered collections'**
  String get homeRegisteredCollections;

  /// No description provided for @homeNoCollections.
  ///
  /// In en, this message translates to:
  /// **'No collection registered yet.\nTap \"New Collection\" to start.'**
  String get homeNoCollections;

  /// No description provided for @homeNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get homeNewCollection;

  /// No description provided for @homeMenuUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get homeMenuUsers;

  /// No description provided for @homeMenuInstitutions.
  ///
  /// In en, this message translates to:
  /// **'Manage Institutions'**
  String get homeMenuInstitutions;

  /// No description provided for @homeMenuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get homeMenuLanguage;

  /// No description provided for @homeMenuLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get homeMenuLogout;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Check your connection.'**
  String get homeLoadError;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeRetry;

  /// No description provided for @datasetSamples.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 sample} other{{n} samples}}'**
  String datasetSamples(int n);

  /// No description provided for @datasetRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove collection?'**
  String get datasetRemoveTitle;

  /// No description provided for @datasetRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'The collection \"{name}\" and all its samples will be permanently removed.'**
  String datasetRemoveBody(Object name);

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionImportCsv.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get actionImportCsv;

  /// No description provided for @addDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get addDatasetTitle;

  /// No description provided for @addDatasetSectionId.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFICATION'**
  String get addDatasetSectionId;

  /// No description provided for @addDatasetName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get addDatasetName;

  /// No description provided for @addDatasetNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Future Beach — Apr/2024'**
  String get addDatasetNameHint;

  /// No description provided for @addDatasetDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addDatasetDescription;

  /// No description provided for @addDatasetDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Surface sediment at 5 sampling points'**
  String get addDatasetDescriptionHint;

  /// No description provided for @addDatasetLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get addDatasetLocation;

  /// No description provided for @addDatasetLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fortaleza, CE'**
  String get addDatasetLocationHint;

  /// No description provided for @addDatasetSectionEquipment.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT AND CALIBRATION'**
  String get addDatasetSectionEquipment;

  /// No description provided for @addDatasetEquipmentNote.
  ///
  /// In en, this message translates to:
  /// **'Parameters shared by all samples in this collection.'**
  String get addDatasetEquipmentNote;

  /// No description provided for @addDatasetSpectrometerModel.
  ///
  /// In en, this message translates to:
  /// **'Spectrometer model'**
  String get addDatasetSpectrometerModel;

  /// No description provided for @addDatasetSpectrometerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bruker Vertex 70 + Hyperion 3000'**
  String get addDatasetSpectrometerHint;

  /// No description provided for @addDatasetAcquisitionMode.
  ///
  /// In en, this message translates to:
  /// **'Acquisition mode'**
  String get addDatasetAcquisitionMode;

  /// No description provided for @addDatasetAtrCrystal.
  ///
  /// In en, this message translates to:
  /// **'ATR crystal'**
  String get addDatasetAtrCrystal;

  /// No description provided for @addDatasetDetector.
  ///
  /// In en, this message translates to:
  /// **'Detector'**
  String get addDatasetDetector;

  /// No description provided for @addDatasetResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution (cm⁻¹)'**
  String get addDatasetResolution;

  /// No description provided for @addDatasetScans.
  ///
  /// In en, this message translates to:
  /// **'Number of scans'**
  String get addDatasetScans;

  /// No description provided for @addDatasetSectionDataType.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT DATA TYPE'**
  String get addDatasetSectionDataType;

  /// No description provided for @addDatasetSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE COLLECTION'**
  String get addDatasetSave;

  /// No description provided for @addDatasetRequired.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get addDatasetRequired;

  /// No description provided for @addDatasetSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Check your connection.'**
  String get addDatasetSaveError;

  /// No description provided for @modeAtr.
  ///
  /// In en, this message translates to:
  /// **'ATR'**
  String get modeAtr;

  /// No description provided for @modeTransmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get modeTransmission;

  /// No description provided for @modeReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get modeReflection;

  /// No description provided for @dataAbsorbance.
  ///
  /// In en, this message translates to:
  /// **'Absorbance'**
  String get dataAbsorbance;

  /// No description provided for @dataTransmittance.
  ///
  /// In en, this message translates to:
  /// **'Transmittance'**
  String get dataTransmittance;

  /// No description provided for @notInformed.
  ///
  /// In en, this message translates to:
  /// **'Not informed'**
  String get notInformed;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;

  /// No description provided for @datasetDetailUploadCsvTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get datasetDetailUploadCsvTooltip;

  /// No description provided for @datasetDetailNewSample.
  ///
  /// In en, this message translates to:
  /// **'New Sample'**
  String get datasetDetailNewSample;

  /// No description provided for @datasetDetailFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get datasetDetailFilterAll;

  /// No description provided for @datasetDetailFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get datasetDetailFilterPending;

  /// No description provided for @datasetDetailColSample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get datasetDetailColSample;

  /// No description provided for @datasetDetailColLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get datasetDetailColLocation;

  /// No description provided for @datasetDetailColPolymer.
  ///
  /// In en, this message translates to:
  /// **'Polymer'**
  String get datasetDetailColPolymer;

  /// No description provided for @datasetDetailColConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get datasetDetailColConfidence;

  /// No description provided for @datasetDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No samples registered.\nTap \"New Sample\" to start.'**
  String get datasetDetailEmpty;

  /// No description provided for @datasetDetailEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No samples for this filter.'**
  String get datasetDetailEmptyFiltered;

  /// No description provided for @datasetDetailStatAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Analyzed'**
  String get datasetDetailStatAnalyzed;

  /// No description provided for @datasetDetailStatVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get datasetDetailStatVerified;

  /// No description provided for @datasetDetailStatAvgConf.
  ///
  /// In en, this message translates to:
  /// **'Avg. conf.'**
  String get datasetDetailStatAvgConf;

  /// No description provided for @datasetDetailPolymerDistribution.
  ///
  /// In en, this message translates to:
  /// **'POLYMER DISTRIBUTION'**
  String get datasetDetailPolymerDistribution;

  /// No description provided for @addSampleTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New Sample'**
  String get addSampleTitleNew;

  /// No description provided for @addSampleTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Sample'**
  String get addSampleTitleEdit;

  /// No description provided for @addSampleModeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual sample'**
  String get addSampleModeIndividual;

  /// No description provided for @addSampleModeBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch of samples'**
  String get addSampleModeBatch;

  /// No description provided for @addSampleSectionCollection.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION'**
  String get addSampleSectionCollection;

  /// No description provided for @addSampleSectionId.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFICATION'**
  String get addSampleSectionId;

  /// No description provided for @addSampleIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Sample ID'**
  String get addSampleIdLabel;

  /// No description provided for @addSampleIdRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get addSampleIdRandom;

  /// No description provided for @addSampleSiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection site'**
  String get addSampleSiteLabel;

  /// No description provided for @addSampleSiteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Point 4 — North Shore'**
  String get addSampleSiteHint;

  /// No description provided for @addSampleSectionDate.
  ///
  /// In en, this message translates to:
  /// **'COLLECTION DATE'**
  String get addSampleSectionDate;

  /// No description provided for @addSampleChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get addSampleChangeDate;

  /// No description provided for @addSampleSectionSpectral.
  ///
  /// In en, this message translates to:
  /// **'SPECTRAL DATA (OPTIONAL)'**
  String get addSampleSectionSpectral;

  /// No description provided for @addSampleAttachCsv.
  ///
  /// In en, this message translates to:
  /// **'Attach spectral data (CSV, 1 row)'**
  String get addSampleAttachCsv;

  /// No description provided for @addSampleAttachHelp.
  ///
  /// In en, this message translates to:
  /// **'The CSV is sent to the MLP model for automatic identification. The data is bound to this sample\'s random ID.'**
  String get addSampleAttachHelp;

  /// No description provided for @addSampleAttachInvalid.
  ///
  /// In en, this message translates to:
  /// **'CSV without valid samples.'**
  String get addSampleAttachInvalid;

  /// No description provided for @addSampleAttachLoading.
  ///
  /// In en, this message translates to:
  /// **'Identifying…'**
  String get addSampleAttachLoading;

  /// No description provided for @addSampleAttachLoadingFile.
  ///
  /// In en, this message translates to:
  /// **'Identifying {file}…'**
  String addSampleAttachLoadingFile(Object file);

  /// No description provided for @addSampleAttachMultiline.
  ///
  /// In en, this message translates to:
  /// **'CSV has {n} rows. Only the first was used. To import all, use Batch mode.'**
  String addSampleAttachMultiline(int n);

  /// No description provided for @addSampleAttachConfidenceShort.
  ///
  /// In en, this message translates to:
  /// **'{pct}% conf.'**
  String addSampleAttachConfidenceShort(Object pct);

  /// No description provided for @addSampleAttachPoints.
  ///
  /// In en, this message translates to:
  /// **'{n} points'**
  String addSampleAttachPoints(int n);

  /// No description provided for @addSampleAttachRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove attachment'**
  String get addSampleAttachRemoveTooltip;

  /// No description provided for @addSampleSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get addSampleSectionNotes;

  /// No description provided for @addSampleNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Annotations'**
  String get addSampleNotesLabel;

  /// No description provided for @addSampleNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Morphology, color, size, collection conditions…'**
  String get addSampleNotesHint;

  /// No description provided for @addSampleSectionVerification.
  ///
  /// In en, this message translates to:
  /// **'ANNOTATOR VERIFICATION'**
  String get addSampleSectionVerification;

  /// No description provided for @addSampleVerifiedToggle.
  ///
  /// In en, this message translates to:
  /// **'Sample verified by the annotator'**
  String get addSampleVerifiedToggle;

  /// No description provided for @addSampleSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'REGISTER SAMPLE'**
  String get addSampleSaveBtn;

  /// No description provided for @addSampleSaveBtnEdit.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get addSampleSaveBtnEdit;

  /// No description provided for @addSampleBatchInfo.
  ///
  /// In en, this message translates to:
  /// **'Registers multiple samples with random IDs for the same collection point. Use \"Import from CSV\" to create a batch already with spectral data and identification.'**
  String get addSampleBatchInfo;

  /// No description provided for @addSampleBatchSectionCount.
  ///
  /// In en, this message translates to:
  /// **'NUMBER OF SAMPLES'**
  String get addSampleBatchSectionCount;

  /// No description provided for @addSampleBatchCount.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get addSampleBatchCount;

  /// No description provided for @addSampleBatchCountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get addSampleBatchCountHint;

  /// No description provided for @addSampleBatchSiteLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared location'**
  String get addSampleBatchSiteLabel;

  /// No description provided for @addSampleBatchSiteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Future Beach — Transect 2'**
  String get addSampleBatchSiteHint;

  /// No description provided for @addSampleBatchNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Annotations (shared)'**
  String get addSampleBatchNotesLabel;

  /// No description provided for @addSampleBatchNotesHint.
  ///
  /// In en, this message translates to:
  /// **'General collection conditions…'**
  String get addSampleBatchNotesHint;

  /// No description provided for @addSampleBatchInvalidCount.
  ///
  /// In en, this message translates to:
  /// **'Provide a number between 1 and 50.'**
  String get addSampleBatchInvalidCount;

  /// No description provided for @addSampleBatchSaveBtn.
  ///
  /// In en, this message translates to:
  /// **'REGISTER BATCH (RANDOM IDs)'**
  String get addSampleBatchSaveBtn;

  /// No description provided for @addSampleBatchImportCsv.
  ///
  /// In en, this message translates to:
  /// **'IMPORT BATCH FROM CSV'**
  String get addSampleBatchImportCsv;

  /// No description provided for @addSampleSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Check your connection.'**
  String get addSampleSaveError;

  /// No description provided for @sampleVerified.
  ///
  /// In en, this message translates to:
  /// **'Sample Verified'**
  String get sampleVerified;

  /// No description provided for @sampleVerifiedBy.
  ///
  /// In en, this message translates to:
  /// **'by {who}'**
  String sampleVerifiedBy(Object who);

  /// No description provided for @sampleSectionInfo.
  ///
  /// In en, this message translates to:
  /// **'SAMPLE INFORMATION'**
  String get sampleSectionInfo;

  /// No description provided for @sampleSectionCalibration.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT CALIBRATION'**
  String get sampleSectionCalibration;

  /// No description provided for @sampleMetaSite.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get sampleMetaSite;

  /// No description provided for @sampleMetaCollectionDate.
  ///
  /// In en, this message translates to:
  /// **'Collection date'**
  String get sampleMetaCollectionDate;

  /// No description provided for @sampleMetaDataType.
  ///
  /// In en, this message translates to:
  /// **'Data type'**
  String get sampleMetaDataType;

  /// No description provided for @sampleMetaVerifiedBy.
  ///
  /// In en, this message translates to:
  /// **'Verified by'**
  String get sampleMetaVerifiedBy;

  /// No description provided for @sampleMetaVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get sampleMetaVerification;

  /// No description provided for @sampleMetaPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sampleMetaPending;

  /// No description provided for @sampleCalMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get sampleCalMode;

  /// No description provided for @sampleCalEquipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get sampleCalEquipment;

  /// No description provided for @sampleCalResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get sampleCalResolution;

  /// No description provided for @sampleCalScans.
  ///
  /// In en, this message translates to:
  /// **'Number of scans'**
  String get sampleCalScans;

  /// No description provided for @sampleCalDetector.
  ///
  /// In en, this message translates to:
  /// **'Detector'**
  String get sampleCalDetector;

  /// No description provided for @sampleCalAtrCrystal.
  ///
  /// In en, this message translates to:
  /// **'ATR crystal'**
  String get sampleCalAtrCrystal;

  /// No description provided for @sampleSectionResult.
  ///
  /// In en, this message translates to:
  /// **'MODEL ANALYSIS'**
  String get sampleSectionResult;

  /// No description provided for @sampleSectionPeaks.
  ///
  /// In en, this message translates to:
  /// **'DIAGNOSTIC BANDS'**
  String get sampleSectionPeaks;

  /// No description provided for @sampleSectionNotes.
  ///
  /// In en, this message translates to:
  /// **'NOTES'**
  String get sampleSectionNotes;

  /// No description provided for @sampleSpectrumTitle.
  ///
  /// In en, this message translates to:
  /// **'FTIR SPECTRUM'**
  String get sampleSpectrumTitle;

  /// No description provided for @sampleIdentifyMlp.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFY WITH MLP'**
  String get sampleIdentifyMlp;

  /// No description provided for @sampleIdentifying.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFYING…'**
  String get sampleIdentifying;

  /// No description provided for @sampleIdentifyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Identify with MLP'**
  String get sampleIdentifyTooltip;

  /// No description provided for @sampleNoServer.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the MLP server. Make sure mlp_server.py is running.'**
  String get sampleNoServer;

  /// No description provided for @sampleNoSpectrumLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading spectrum from server (ID {id})…'**
  String sampleNoSpectrumLoading(Object id);

  /// No description provided for @sampleNoSpectrum.
  ///
  /// In en, this message translates to:
  /// **'No spectral data for this sample. Attach a CSV during registration or use \"Import CSV\".'**
  String get sampleNoSpectrum;

  /// No description provided for @sampleRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove sample?'**
  String get sampleRemoveTitle;

  /// No description provided for @sampleRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'The sample \"{name}\" will be permanently removed.'**
  String sampleRemoveBody(Object name);

  /// No description provided for @sampleResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Identified Polymer'**
  String get sampleResultLabel;

  /// No description provided for @sampleConfidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get sampleConfidence;

  /// No description provided for @sampleDecisionPoint.
  ///
  /// In en, this message translates to:
  /// **'Decision point'**
  String get sampleDecisionPoint;

  /// No description provided for @chartAbsorbance.
  ///
  /// In en, this message translates to:
  /// **'Absorbance'**
  String get chartAbsorbance;

  /// No description provided for @chartTransmittance.
  ///
  /// In en, this message translates to:
  /// **'Transmittance'**
  String get chartTransmittance;

  /// No description provided for @chartLegendDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision point'**
  String get chartLegendDecision;

  /// No description provided for @chartLegendAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention region'**
  String get chartLegendAttention;

  /// No description provided for @chartAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get chartAttention;

  /// No description provided for @importCsvTitle.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsvTitle;

  /// No description provided for @importCsvSectionFormat.
  ///
  /// In en, this message translates to:
  /// **'FILE FORMAT'**
  String get importCsvSectionFormat;

  /// No description provided for @importCsvFormat1.
  ///
  /// In en, this message translates to:
  /// **'Each CSV row = one spectral sample'**
  String get importCsvFormat1;

  /// No description provided for @importCsvFormat2.
  ///
  /// In en, this message translates to:
  /// **'Numeric headers (e.g. 600.0, 3998.0) = wavenumbers'**
  String get importCsvFormat2;

  /// No description provided for @importCsvFormat3.
  ///
  /// In en, this message translates to:
  /// **'Categorical columns (name, sample, interpretation…) are removed automatically'**
  String get importCsvFormat3;

  /// No description provided for @importCsvFormat4.
  ///
  /// In en, this message translates to:
  /// **'The MLP model identifies: PE, PP, PS, PA, EVA, cellulose'**
  String get importCsvFormat4;

  /// No description provided for @importCsvSectionFile.
  ///
  /// In en, this message translates to:
  /// **'FILE'**
  String get importCsvSectionFile;

  /// No description provided for @importCsvNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get importCsvNoFile;

  /// No description provided for @importCsvChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get importCsvChoose;

  /// No description provided for @importCsvIdentify.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFY SAMPLES'**
  String get importCsvIdentify;

  /// No description provided for @importCsvIdentifying.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFYING {progress}…'**
  String importCsvIdentifying(Object progress);

  /// No description provided for @importCsvResults.
  ///
  /// In en, this message translates to:
  /// **'RESULTS ({n} samples)'**
  String importCsvResults(int n);

  /// No description provided for @importCsvHighConf.
  ///
  /// In en, this message translates to:
  /// **'{n} high confidence'**
  String importCsvHighConf(int n);

  /// No description provided for @importCsvSaving.
  ///
  /// In en, this message translates to:
  /// **'SAVING…'**
  String get importCsvSaving;

  /// No description provided for @importCsvImport.
  ///
  /// In en, this message translates to:
  /// **'IMPORT {n} SAMPLE(S) INTO THE DATASET'**
  String importCsvImport(int n);

  /// No description provided for @importCsvImportedToast.
  ///
  /// In en, this message translates to:
  /// **'{n} sample(s) imported successfully.'**
  String importCsvImportedToast(int n);

  /// No description provided for @manageUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get manageUsersTitle;

  /// No description provided for @manageUsersNew.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get manageUsersNew;

  /// No description provided for @manageUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No user registered.'**
  String get manageUsersEmpty;

  /// No description provided for @manageUsersRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove user?'**
  String get manageUsersRemoveTitle;

  /// No description provided for @manageUsersRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'The user \"{name}\" will be permanently removed.'**
  String manageUsersRemoveBody(Object name);

  /// No description provided for @manageUsersRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get manageUsersRoleAdmin;

  /// No description provided for @manageUsersRoleResearcher.
  ///
  /// In en, this message translates to:
  /// **'Researcher'**
  String get manageUsersRoleResearcher;

  /// No description provided for @manageUsersYou.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get manageUsersYou;

  /// No description provided for @manageUsersTooltipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get manageUsersTooltipEdit;

  /// No description provided for @manageUsersTooltipRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get manageUsersTooltipRemove;

  /// No description provided for @userFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New User'**
  String get userFormTitleNew;

  /// No description provided for @userFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get userFormTitleEdit;

  /// No description provided for @userFormSectionId.
  ///
  /// In en, this message translates to:
  /// **'IDENTIFICATION'**
  String get userFormSectionId;

  /// No description provided for @userFormUsername.
  ///
  /// In en, this message translates to:
  /// **'Username (login)'**
  String get userFormUsername;

  /// No description provided for @userFormUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jsmith'**
  String get userFormUsernameHint;

  /// No description provided for @userFormFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get userFormFullName;

  /// No description provided for @userFormFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Smith'**
  String get userFormFullNameHint;

  /// No description provided for @userFormEmail.
  ///
  /// In en, this message translates to:
  /// **'Institutional e-mail'**
  String get userFormEmail;

  /// No description provided for @userFormEmailHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. jsmith@usp.br'**
  String get userFormEmailHint;

  /// No description provided for @userFormDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department / Lab'**
  String get userFormDepartment;

  /// No description provided for @userFormDepartmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Oceanography Lab'**
  String get userFormDepartmentHint;

  /// No description provided for @userFormSectionRole.
  ///
  /// In en, this message translates to:
  /// **'ACCESS PROFILE'**
  String get userFormSectionRole;

  /// No description provided for @userFormRoleResearcher.
  ///
  /// In en, this message translates to:
  /// **'Researcher'**
  String get userFormRoleResearcher;

  /// No description provided for @userFormRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get userFormRoleAdmin;

  /// No description provided for @userFormSectionPasswordNew.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get userFormSectionPasswordNew;

  /// No description provided for @userFormSectionPasswordEdit.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD (optional)'**
  String get userFormSectionPasswordEdit;

  /// No description provided for @userFormPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get userFormPassword;

  /// No description provided for @userFormPasswordHintNew.
  ///
  /// In en, this message translates to:
  /// **'Min. 6 characters'**
  String get userFormPasswordHintNew;

  /// No description provided for @userFormPasswordHintEdit.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep'**
  String get userFormPasswordHintEdit;

  /// No description provided for @userFormPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get userFormPasswordConfirm;

  /// No description provided for @userFormPasswordConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat the password'**
  String get userFormPasswordConfirmHint;

  /// No description provided for @userFormPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get userFormPasswordsMismatch;

  /// No description provided for @userFormPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 6 characters.'**
  String get userFormPasswordTooShort;

  /// No description provided for @userFormUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get userFormUsernameTaken;

  /// No description provided for @userFormSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed. Check your connection.'**
  String get userFormSaveError;

  /// No description provided for @userFormSaveBtnNew.
  ///
  /// In en, this message translates to:
  /// **'CREATE USER'**
  String get userFormSaveBtnNew;

  /// No description provided for @userFormSaveBtnEdit.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get userFormSaveBtnEdit;

  /// No description provided for @manageInstitutionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Institutions'**
  String get manageInstitutionsTitle;

  /// No description provided for @manageInstitutionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No institution registered.'**
  String get manageInstitutionsEmpty;

  /// No description provided for @manageInstitutionsNew.
  ///
  /// In en, this message translates to:
  /// **'New Institution'**
  String get manageInstitutionsNew;

  /// No description provided for @manageInstitutionsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove institution?'**
  String get manageInstitutionsRemoveTitle;

  /// No description provided for @manageInstitutionsRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'All users, datasets and samples of \"{name}\" will be permanently removed. This cannot be undone.'**
  String manageInstitutionsRemoveBody(Object name);

  /// No description provided for @manageInstitutionsCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created on {date}'**
  String manageInstitutionsCreatedAt(Object date);

  /// No description provided for @manageInstitutionsAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Only administrators can create new institutions.'**
  String get manageInstitutionsAdminOnly;

  /// No description provided for @newInstitutionTitle.
  ///
  /// In en, this message translates to:
  /// **'Register Institution'**
  String get newInstitutionTitle;

  /// No description provided for @newInstitutionInstName.
  ///
  /// In en, this message translates to:
  /// **'Institution name'**
  String get newInstitutionInstName;

  /// No description provided for @newInstitutionInstNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. University of São Paulo'**
  String get newInstitutionInstNameHint;

  /// No description provided for @newInstitutionSlug.
  ///
  /// In en, this message translates to:
  /// **'Identifier (slug)'**
  String get newInstitutionSlug;

  /// No description provided for @newInstitutionSlugHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. usp (auto-generated)'**
  String get newInstitutionSlugHint;

  /// No description provided for @newInstitutionAdminSection.
  ///
  /// In en, this message translates to:
  /// **'INITIAL ADMINISTRATOR'**
  String get newInstitutionAdminSection;

  /// No description provided for @newInstitutionCreate.
  ///
  /// In en, this message translates to:
  /// **'CREATE INSTITUTION'**
  String get newInstitutionCreate;

  /// No description provided for @newInstitutionInstitution.
  ///
  /// In en, this message translates to:
  /// **'INSTITUTION'**
  String get newInstitutionInstitution;

  /// No description provided for @newInstitutionAdminUsername.
  ///
  /// In en, this message translates to:
  /// **'Admin username'**
  String get newInstitutionAdminUsername;

  /// No description provided for @newInstitutionAdminUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. admin'**
  String get newInstitutionAdminUsernameHint;

  /// No description provided for @newInstitutionAdminFullName.
  ///
  /// In en, this message translates to:
  /// **'Admin full name'**
  String get newInstitutionAdminFullName;

  /// No description provided for @newInstitutionAdminEmail.
  ///
  /// In en, this message translates to:
  /// **'Admin e-mail'**
  String get newInstitutionAdminEmail;

  /// No description provided for @newInstitutionAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Admin password'**
  String get newInstitutionAdminPassword;

  /// No description provided for @newInstitutionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Institution \"{name}\" created. You can sign in now.'**
  String newInstitutionSuccess(Object name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
