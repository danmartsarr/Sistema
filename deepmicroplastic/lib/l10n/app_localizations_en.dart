import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';


/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RAVI System';

  @override
  String get appAcronymR => 'ecognition';

  @override
  String get appAcronymA => 'utomated';

  @override
  String get appAcronymV => 'ia';

  @override
  String get appAcronymI => 'nfrared';

  @override
  String get appTagline => 'Microplastic Identification by FTIR';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageEnglish => 'English';

  @override
  String get language => 'Language';

  @override
  String get login => 'Sign in';

  @override
  String get loginInstitution => 'Institution';

  @override
  String get loginInstitutionHint => 'e.g. usp';

  @override
  String get loginUsername => 'Username';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginEnter => 'ENTER';

  @override
  String get loginInstitutionContinue => 'CONTINUE';

  @override
  String get loginInstitutionNotFound => 'Institution not found.';

  @override
  String get loginUserNotFound => 'Invalid username or password.';

  @override
  String get loginFillAll => 'Fill in all fields.';

  @override
  String get loginFirstRunBanner =>
      'First run — create the system administrator and the first institution.';

  @override
  String get loginCreateFirstAdmin => 'CREATE ADMIN ACCOUNT';

  @override
  String get loginNewInstitution => 'Register a new institution';

  @override
  String get loginNewInstitutionDesc =>
      'Only system administrators can create institutions.';

  @override
  String get loginAdminFullName => 'Administrator full name';

  @override
  String get loginAdminEmail => 'Administrator e-mail';

  @override
  String get loginInstitutionName => 'Institution name';

  @override
  String get loginPasswordMin => 'Password must have at least 6 characters.';

  @override
  String get loginInstitutionAlreadyExists =>
      'An institution with this slug already exists.';

  @override
  String get loginCreateError => 'Could not create. Check your connection.';

  @override
  String get loginChangeInstitution => 'Change institution';

  @override
  String get homeTitle => 'FTIR Analysis';

  @override
  String get homeKpiTotalSamples => 'Total samples';

  @override
  String get homeKpiCollections => 'Collections';

  @override
  String get homeKpiVerified => 'Verified';

  @override
  String get homePolymerDistribution => 'Polymer distribution';

  @override
  String get homeRegisteredCollections => 'Registered collections';

  @override
  String get homeNoCollections =>
      'No collection registered yet.\nTap \"New Collection\" to start.';

  @override
  String get homeNewCollection => 'New Collection';

  @override
  String get homeMenuUsers => 'Manage Users';

  @override
  String get homeMenuInstitutions => 'Manage Institutions';

  @override
  String get homeMenuLanguage => 'Language';

  @override
  String get homeMenuLogout => 'Sign out';

  @override
  String get homeLoadError => 'Failed to load data. Check your connection.';

  @override
  String get homeRetry => 'Try again';

  @override
  String datasetSamples(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n samples',
      one: '1 sample',
    );
    return '$_temp0';
  }

  @override
  String get datasetRemoveTitle => 'Remove collection?';

  @override
  String datasetRemoveBody(Object name) {
    return 'The collection \"$name\" and all its samples will be permanently removed.';
  }

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionSave => 'Save';

  @override
  String get actionImportCsv => 'Import CSV';

  @override
  String get addDatasetTitle => 'New Collection';

  @override
  String get addDatasetSectionId => 'IDENTIFICATION';

  @override
  String get addDatasetName => 'Collection name';

  @override
  String get addDatasetNameHint => 'e.g. Future Beach — Apr/2024';

  @override
  String get addDatasetDescription => 'Description';

  @override
  String get addDatasetDescriptionHint =>
      'e.g. Surface sediment at 5 sampling points';

  @override
  String get addDatasetLocation => 'Location';

  @override
  String get addDatasetLocationHint => 'e.g. Fortaleza, CE';

  @override
  String get addDatasetSectionEquipment => 'EQUIPMENT AND CALIBRATION';

  @override
  String get addDatasetEquipmentNote =>
      'Parameters shared by all samples in this collection.';

  @override
  String get addDatasetSpectrometerModel => 'Spectrometer model';

  @override
  String get addDatasetSpectrometerHint =>
      'e.g. Bruker Vertex 70 + Hyperion 3000';

  @override
  String get addDatasetAcquisitionMode => 'Acquisition mode';

  @override
  String get addDatasetAtrCrystal => 'ATR crystal';

  @override
  String get addDatasetDetector => 'Detector';

  @override
  String get addDatasetResolution => 'Resolution (cm⁻¹)';

  @override
  String get addDatasetScans => 'Number of scans';

  @override
  String get addDatasetSectionDataType => 'DEFAULT DATA TYPE';

  @override
  String get addDatasetSave => 'SAVE COLLECTION';

  @override
  String get addDatasetRequired => 'Required field';

  @override
  String get addDatasetSaveError => 'Save failed. Check your connection.';

  @override
  String get modeAtr => 'ATR';

  @override
  String get modeTransmission => 'Transmission';

  @override
  String get modeReflection => 'Reflection';

  @override
  String get dataAbsorbance => 'Absorbance';

  @override
  String get dataTransmittance => 'Transmittance';

  @override
  String get notInformed => 'Not informed';

  @override
  String get noDescription => 'No description.';

  @override
  String get datasetDetailUploadCsvTooltip => 'Import CSV';

  @override
  String get datasetDetailNewSample => 'New Sample';

  @override
  String get datasetDetailFilterAll => 'All';

  @override
  String get datasetDetailFilterPending => 'Pending';

  @override
  String get datasetDetailColSample => 'Sample';

  @override
  String get datasetDetailColLocation => 'Location';

  @override
  String get datasetDetailColPolymer => 'Polymer';

  @override
  String get datasetDetailColConfidence => 'Confidence';

  @override
  String get datasetDetailEmpty =>
      'No samples registered.\nTap \"New Sample\" to start.';

  @override
  String get datasetDetailEmptyFiltered => 'No samples for this filter.';

  @override
  String get datasetDetailStatAnalyzed => 'Analyzed';

  @override
  String get datasetDetailStatVerified => 'Verified';

  @override
  String get datasetDetailStatAvgConf => 'Avg. conf.';

  @override
  String get datasetDetailPolymerDistribution => 'POLYMER DISTRIBUTION';

  @override
  String get addSampleTitleNew => 'New Sample';

  @override
  String get addSampleTitleEdit => 'Edit Sample';

  @override
  String get addSampleModeIndividual => 'Individual sample';

  @override
  String get addSampleModeBatch => 'Batch of samples';

  @override
  String get addSampleSectionCollection => 'COLLECTION';

  @override
  String get addSampleSectionId => 'IDENTIFICATION';

  @override
  String get addSampleIdLabel => 'Sample ID';

  @override
  String get addSampleIdRandom => 'Random';

  @override
  String get addSampleSiteLabel => 'Collection site';

  @override
  String get addSampleSiteHint => 'e.g. Point 4 — North Shore';

  @override
  String get addSampleSectionDate => 'COLLECTION DATE';

  @override
  String get addSampleChangeDate => 'Change';

  @override
  String get addSampleSectionSpectral => 'SPECTRAL DATA (OPTIONAL)';

  @override
  String get addSampleAttachCsv => 'Attach spectral data (CSV, 1 row)';

  @override
  String get addSampleAttachHelp =>
      'The CSV is sent to the MLP model for automatic identification. The data is bound to this sample\'s random ID.';

  @override
  String get addSampleAttachInvalid => 'CSV without valid samples.';

  @override
  String get addSampleAttachLoading => 'Identifying…';

  @override
  String addSampleAttachLoadingFile(Object file) {
    return 'Identifying $file…';
  }

  @override
  String addSampleAttachMultiline(int n) {
    return 'CSV has $n rows. Only the first was used. To import all, use Batch mode.';
  }

  @override
  String addSampleAttachConfidenceShort(Object pct) {
    return '$pct% conf.';
  }

  @override
  String addSampleAttachPoints(int n) {
    return '$n points';
  }

  @override
  String get addSampleAttachRemoveTooltip => 'Remove attachment';

  @override
  String get addSampleSectionNotes => 'NOTES';

  @override
  String get addSampleNotesLabel => 'Annotations';

  @override
  String get addSampleNotesHint =>
      'Morphology, color, size, collection conditions…';

  @override
  String get addSampleSectionVerification => 'ANNOTATOR VERIFICATION';

  @override
  String get addSampleVerifiedToggle => 'Sample verified by the annotator';

  @override
  String get addSampleSaveBtn => 'REGISTER SAMPLE';

  @override
  String get addSampleSaveBtnEdit => 'SAVE CHANGES';

  @override
  String get addSampleBatchInfo =>
      'Registers multiple samples with random IDs for the same collection point. Use \"Import from CSV\" to create a batch already with spectral data and identification.';

  @override
  String get addSampleBatchSectionCount => 'NUMBER OF SAMPLES';

  @override
  String get addSampleBatchCount => 'Quantity';

  @override
  String get addSampleBatchCountHint => 'e.g. 5';

  @override
  String get addSampleBatchSiteLabel => 'Shared location';

  @override
  String get addSampleBatchSiteHint => 'e.g. Future Beach — Transect 2';

  @override
  String get addSampleBatchNotesLabel => 'Annotations (shared)';

  @override
  String get addSampleBatchNotesHint => 'General collection conditions…';

  @override
  String get addSampleBatchInvalidCount => 'Provide a number between 1 and 50.';

  @override
  String get addSampleBatchSaveBtn => 'REGISTER BATCH (RANDOM IDs)';

  @override
  String get addSampleBatchImportCsv => 'IMPORT BATCH FROM CSV';

  @override
  String get addSampleSaveError => 'Save failed. Check your connection.';

  @override
  String get sampleVerified => 'Sample Verified';

  @override
  String sampleVerifiedBy(Object who) {
    return 'by $who';
  }

  @override
  String get sampleSectionInfo => 'SAMPLE INFORMATION';

  @override
  String get sampleSectionCalibration => 'EQUIPMENT CALIBRATION';

  @override
  String get sampleMetaSite => 'Site';

  @override
  String get sampleMetaCollectionDate => 'Collection date';

  @override
  String get sampleMetaDataType => 'Data type';

  @override
  String get sampleMetaVerifiedBy => 'Verified by';

  @override
  String get sampleMetaVerification => 'Verification';

  @override
  String get sampleMetaPending => 'Pending';

  @override
  String get sampleCalMode => 'Mode';

  @override
  String get sampleCalEquipment => 'Equipment';

  @override
  String get sampleCalResolution => 'Resolution';

  @override
  String get sampleCalScans => 'Number of scans';

  @override
  String get sampleCalDetector => 'Detector';

  @override
  String get sampleCalAtrCrystal => 'ATR crystal';

  @override
  String get sampleSectionResult => 'MODEL ANALYSIS';

  @override
  String get sampleSectionPeaks => 'DIAGNOSTIC BANDS';

  @override
  String get sampleSectionNotes => 'NOTES';

  @override
  String get sampleSpectrumTitle => 'FTIR SPECTRUM';

  @override
  String get sampleIdentifyMlp => 'IDENTIFY WITH MLP';

  @override
  String get sampleIdentifying => 'IDENTIFYING…';

  @override
  String get sampleIdentifyTooltip => 'Identify with MLP';

  @override
  String get sampleNoServer =>
      'Could not reach the MLP server. Make sure mlp_server.py is running.';

  @override
  String sampleNoSpectrumLoading(Object id) {
    return 'Loading spectrum from server (ID $id)…';
  }

  @override
  String get sampleNoSpectrum =>
      'No spectral data for this sample. Attach a CSV during registration or use \"Import CSV\".';

  @override
  String get sampleRemoveTitle => 'Remove sample?';

  @override
  String sampleRemoveBody(Object name) {
    return 'The sample \"$name\" will be permanently removed.';
  }

  @override
  String get sampleResultLabel => 'Identified Polymer';

  @override
  String get sampleConfidence => 'confidence';

  @override
  String get sampleDecisionPoint => 'Decision point';

  @override
  String get chartAbsorbance => 'Absorbance';

  @override
  String get chartTransmittance => 'Transmittance';

  @override
  String get chartLegendDecision => 'Decision point';

  @override
  String get chartLegendAttention => 'Attention region';

  @override
  String get chartAttention => 'Attention';

  @override
  String get importCsvTitle => 'Import CSV';

  @override
  String get importCsvSectionFormat => 'FILE FORMAT';

  @override
  String get importCsvFormat1 => 'Each CSV row = one spectral sample';

  @override
  String get importCsvFormat2 =>
      'Numeric headers (e.g. 600.0, 3998.0) = wavenumbers';

  @override
  String get importCsvFormat3 =>
      'Categorical columns (name, sample, interpretation…) are removed automatically';

  @override
  String get importCsvFormat4 =>
      'The MLP model identifies: PE, PP, PS, PA, EVA, cellulose';

  @override
  String get importCsvSectionFile => 'FILE';

  @override
  String get importCsvNoFile => 'No file selected';

  @override
  String get importCsvChoose => 'Choose';

  @override
  String get importCsvIdentify => 'IDENTIFY SAMPLES';

  @override
  String importCsvIdentifying(Object progress) {
    return 'IDENTIFYING $progress…';
  }

  @override
  String importCsvResults(int n) {
    return 'RESULTS ($n samples)';
  }

  @override
  String importCsvHighConf(int n) {
    return '$n high confidence';
  }

  @override
  String get importCsvSaving => 'SAVING…';

  @override
  String importCsvImport(int n) {
    return 'IMPORT $n SAMPLE(S) INTO THE DATASET';
  }

  @override
  String importCsvImportedToast(int n) {
    return '$n sample(s) imported successfully.';
  }

  @override
  String get manageUsersTitle => 'Users';

  @override
  String get manageUsersNew => 'New User';

  @override
  String get manageUsersEmpty => 'No user registered.';

  @override
  String get manageUsersRemoveTitle => 'Remove user?';

  @override
  String manageUsersRemoveBody(Object name) {
    return 'The user \"$name\" will be permanently removed.';
  }

  @override
  String get manageUsersRoleAdmin => 'Administrator';

  @override
  String get manageUsersRoleResearcher => 'Researcher';

  @override
  String get manageUsersYou => 'you';

  @override
  String get manageUsersTooltipEdit => 'Edit';

  @override
  String get manageUsersTooltipRemove => 'Remove';

  @override
  String get userFormTitleNew => 'New User';

  @override
  String get userFormTitleEdit => 'Edit User';

  @override
  String get userFormSectionId => 'IDENTIFICATION';

  @override
  String get userFormUsername => 'Username (login)';

  @override
  String get userFormUsernameHint => 'e.g. jsmith';

  @override
  String get userFormFullName => 'Full name';

  @override
  String get userFormFullNameHint => 'e.g. John Smith';

  @override
  String get userFormEmail => 'Institutional e-mail';

  @override
  String get userFormEmailHint => 'e.g. jsmith@usp.br';

  @override
  String get userFormDepartment => 'Department / Lab';

  @override
  String get userFormDepartmentHint => 'e.g. Oceanography Lab';

  @override
  String get userFormSectionRole => 'ACCESS PROFILE';

  @override
  String get userFormRoleResearcher => 'Researcher';

  @override
  String get userFormRoleAdmin => 'Administrator';

  @override
  String get userFormSectionPasswordNew => 'PASSWORD';

  @override
  String get userFormSectionPasswordEdit => 'CHANGE PASSWORD (optional)';

  @override
  String get userFormPassword => 'Password';

  @override
  String get userFormPasswordHintNew => 'Min. 6 characters';

  @override
  String get userFormPasswordHintEdit => 'Leave blank to keep';

  @override
  String get userFormPasswordConfirm => 'Confirm password';

  @override
  String get userFormPasswordConfirmHint => 'Repeat the password';

  @override
  String get userFormPasswordsMismatch => 'Passwords do not match.';

  @override
  String get userFormPasswordTooShort =>
      'Password must have at least 6 characters.';

  @override
  String get userFormUsernameTaken => 'This username is already taken.';

  @override
  String get userFormSaveError => 'Save failed. Check your connection.';

  @override
  String get userFormSaveBtnNew => 'CREATE USER';

  @override
  String get userFormSaveBtnEdit => 'SAVE CHANGES';

  @override
  String get manageInstitutionsTitle => 'Institutions';

  @override
  String get manageInstitutionsEmpty => 'No institution registered.';

  @override
  String get manageInstitutionsNew => 'New Institution';

  @override
  String get manageInstitutionsRemoveTitle => 'Remove institution?';

  @override
  String manageInstitutionsRemoveBody(Object name) {
    return 'All users, datasets and samples of \"$name\" will be permanently removed. This cannot be undone.';
  }

  @override
  String manageInstitutionsCreatedAt(Object date) {
    return 'Created on $date';
  }

  @override
  String get manageInstitutionsAdminOnly =>
      'Only administrators can create new institutions.';

  @override
  String get newInstitutionTitle => 'Register Institution';

  @override
  String get newInstitutionInstName => 'Institution name';

  @override
  String get newInstitutionInstNameHint => 'e.g. University of São Paulo';

  @override
  String get newInstitutionSlug => 'Identifier (slug)';

  @override
  String get newInstitutionSlugHint => 'e.g. usp (auto-generated)';

  @override
  String get newInstitutionAdminSection => 'INITIAL ADMINISTRATOR';

  @override
  String get newInstitutionCreate => 'CREATE INSTITUTION';

  @override
  String get newInstitutionInstitution => 'INSTITUTION';

  @override
  String get newInstitutionAdminUsername => 'Admin username';

  @override
  String get newInstitutionAdminUsernameHint => 'e.g. admin';

  @override
  String get newInstitutionAdminFullName => 'Admin full name';

  @override
  String get newInstitutionAdminEmail => 'Admin e-mail';

  @override
  String get newInstitutionAdminPassword => 'Admin password';

  @override
  String newInstitutionSuccess(Object name) {
    return 'Institution \"$name\" created. You can sign in now.';
  }
}
