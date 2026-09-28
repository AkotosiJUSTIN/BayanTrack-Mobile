import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

// ignore_for_file: type=lint

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
    Locale('fil'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BayanTrack'**
  String get appName;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'Watching over communities, supporting local action.'**
  String get brandTagline;

  /// No description provided for @reportTrackResolve.
  ///
  /// In en, this message translates to:
  /// **'Report. Track. Resolve.'**
  String get reportTrackResolve;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String pageOf(int page, int count);

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @filipino.
  ///
  /// In en, this message translates to:
  /// **'Filipino'**
  String get filipino;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Profile.'**
  String get chooseLanguageSubtitle;

  /// No description provided for @onboardingReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Issues in Your Community'**
  String get onboardingReportTitle;

  /// No description provided for @onboardingReportDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly report floods, potholes, broken streetlights, garbage, and other local concerns directly to the LGU.'**
  String get onboardingReportDescription;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Report’s Progress'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTrackDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your report’s status and receive updates as it moves toward resolution.'**
  String get onboardingTrackDescription;

  /// No description provided for @onboardingStayInformedTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get onboardingStayInformedTitle;

  /// No description provided for @onboardingStayInformedDescription.
  ///
  /// In en, this message translates to:
  /// **'Receive important updates and safety alerts for your community.'**
  String get onboardingStayInformedDescription;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @bantayWaving.
  ///
  /// In en, this message translates to:
  /// **'Bantay waving'**
  String get bantayWaving;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loggingIn.
  ///
  /// In en, this message translates to:
  /// **'Logging in'**
  String get loggingIn;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinCitizenReporters.
  ///
  /// In en, this message translates to:
  /// **'Join the community of civic reporters'**
  String get joinCitizenReporters;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @enterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterYourFirstName;

  /// No description provided for @enterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterYourLastName;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get createPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @barangay.
  ///
  /// In en, this message translates to:
  /// **'Barangay'**
  String get barangay;

  /// No description provided for @selectYourBarangay.
  ///
  /// In en, this message translates to:
  /// **'Select your barangay'**
  String get selectYourBarangay;

  /// No description provided for @pleaseSelectBarangay.
  ///
  /// In en, this message translates to:
  /// **'Please select a barangay'**
  String get pleaseSelectBarangay;

  /// No description provided for @failedLoadBarangays.
  ///
  /// In en, this message translates to:
  /// **'Failed to load barangays. Please restart the app.'**
  String get failedLoadBarangays;

  /// No description provided for @iAgreeTo.
  ///
  /// In en, this message translates to:
  /// **'I agree to the'**
  String get iAgreeTo;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions and Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @policyDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review how BayanTrack handles community reports and protects your account'**
  String get policyDialogSubtitle;

  /// No description provided for @termsPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'BAYANTRACK TERMS & CONDITIONS\n\n1. Purpose\nBayanTrack helps residents send community reports to their barangay and follow the progress of concerns that affect their neighborhood.\n\n2. Use the service responsibly\nUse your own account and submit reports about real community concerns. Do not upload abusive, unlawful, discriminatory, or deliberately misleading content.\n\n3. Reports and evidence\nDescribe what happened, where it happened, and when it happened as accurately as you can. Only share photos, videos, and other evidence that you are allowed to share. BayanTrack may route a report and its evidence to authorized barangay or city personnel for review and action.\n\n4. Account security\nKeep your email address and password private. You are responsible for activity made through your account. Contact the BayanTrack team if you believe your account has been accessed by someone else.\n\nBAYANTRACK PRIVACY POLICY\n\n1. Information we receive\nWe collect the details you provide when you register, including your name, email address, and selected barangay. We also receive the report details, location, attachments, and updates you choose to submit.\n\n2. How we use your information\nWe use this information to verify accounts, route reports to the right barangay, send status updates, prevent misuse, and improve BayanTrack\'s community reporting service.\n\n3. Who may access it\nRelevant report details may be viewed by authorized BayanTrack administrators and local government personnel who need the information to review or respond to the concern. We do not sell your personal information.\n\n4. Your choices\nPlease keep your account information accurate and tell us if it needs to be corrected. We keep information only for as long as it is needed for service operations, reporting history, safety, and applicable requirements.\n\nBy tapping Accept, you confirm that you have read and understood the BayanTrack Terms & Conditions and Privacy Policy.'**
  String get termsPolicyContent;

  /// No description provided for @creatingAccount.
  ///
  /// In en, this message translates to:
  /// **'Creating account'**
  String get creatingAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to receive a verification code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get enterVerificationCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String version(String version, String build);

  /// No description provided for @profilePictureBackupPending.
  ///
  /// In en, this message translates to:
  /// **'Profile picture backup pending'**
  String get profilePictureBackupPending;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @userVerification.
  ///
  /// In en, this message translates to:
  /// **'User Verification'**
  String get userVerification;

  /// No description provided for @verifyIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify Identity'**
  String get verifyIdentity;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @createReport.
  ///
  /// In en, this message translates to:
  /// **'Create report'**
  String get createReport;

  /// No description provided for @chooseReportType.
  ///
  /// In en, this message translates to:
  /// **'Choose the faster quick report or the full multi-step report.'**
  String get chooseReportType;

  /// No description provided for @quickReport.
  ///
  /// In en, this message translates to:
  /// **'Quick Report'**
  String get quickReport;

  /// No description provided for @fastReport.
  ///
  /// In en, this message translates to:
  /// **'Fast Report'**
  String get fastReport;

  /// No description provided for @fastReportGuidance.
  ///
  /// In en, this message translates to:
  /// **'For emergencies: confirm your GPS location and briefly describe what is happening.'**
  String get fastReportGuidance;

  /// No description provided for @submitFastReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Fast Report'**
  String get submitFastReport;

  /// No description provided for @submittingFastReport.
  ///
  /// In en, this message translates to:
  /// **'Submitting Fast Report…'**
  String get submittingFastReport;

  /// No description provided for @closeFastReport.
  ///
  /// In en, this message translates to:
  /// **'Close Fast Report'**
  String get closeFastReport;

  /// No description provided for @emergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Emergency Report'**
  String get emergencyReport;

  /// No description provided for @addDetails.
  ///
  /// In en, this message translates to:
  /// **'Add details'**
  String get addDetails;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImage;

  /// No description provided for @completeFastReport.
  ///
  /// In en, this message translates to:
  /// **'Complete your Fast Report'**
  String get completeFastReport;

  /// No description provided for @completeFastReportBody.
  ///
  /// In en, this message translates to:
  /// **'Add an image or extra details to help responders follow up.'**
  String get completeFastReportBody;

  /// No description provided for @closeEmergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Close Emergency Report'**
  String get closeEmergencyReport;

  /// No description provided for @emergencyIncidentType.
  ///
  /// In en, this message translates to:
  /// **'Incident type'**
  String get emergencyIncidentType;

  /// No description provided for @emergencyReportNotice.
  ///
  /// In en, this message translates to:
  /// **'For immediate threats. BayanTrack does not replace emergency hotlines.'**
  String get emergencyReportNotice;

  /// No description provided for @emergencyCallGuidance.
  ///
  /// In en, this message translates to:
  /// **'If someone is in immediate danger, call local emergency services if cellular calling is available. BayanTrack has not confirmed receipt of this report.'**
  String get emergencyCallGuidance;

  /// No description provided for @emergencyConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm this is an emergency and the location is accurate.'**
  String get emergencyConfirm;

  /// No description provided for @emergencyCategoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an incident type to continue.'**
  String get emergencyCategoryRequired;

  /// No description provided for @emergencyConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm the emergency and location before submitting.'**
  String get emergencyConfirmationRequired;

  /// No description provided for @submitEmergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Emergency Report'**
  String get submitEmergencyReport;

  /// No description provided for @submittingEmergencyReport.
  ///
  /// In en, this message translates to:
  /// **'Sending Emergency Report…'**
  String get submittingEmergencyReport;

  /// No description provided for @reportDraftFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfinished report'**
  String get reportDraftFoundTitle;

  /// No description provided for @reportDraftFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'You have a saved {reportType} draft.'**
  String reportDraftFoundMessage(String reportType);

  /// No description provided for @resumeDraft.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resumeDraft;

  /// No description provided for @startNewReport.
  ///
  /// In en, this message translates to:
  /// **'Start New'**
  String get startNewReport;

  /// No description provided for @discardDraft.
  ///
  /// In en, this message translates to:
  /// **'Discard Draft'**
  String get discardDraft;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @discardDraftConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this draft?'**
  String get discardDraftConfirmationTitle;

  /// No description provided for @discardDraftConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'This saved report and its unused photos will be deleted.'**
  String get discardDraftConfirmationMessage;

  /// No description provided for @replaceDraftConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'The saved report will be replaced with a new draft.'**
  String get replaceDraftConfirmationMessage;

  /// No description provided for @keepDraft.
  ///
  /// In en, this message translates to:
  /// **'Keep Draft'**
  String get keepDraft;

  /// No description provided for @emergencyNotYetTransmitted.
  ///
  /// In en, this message translates to:
  /// **'NOT YET TRANSMITTED'**
  String get emergencyNotYetTransmitted;

  /// No description provided for @emergencyDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Add details that can help responders.'**
  String get emergencyDetailsHint;

  /// No description provided for @detailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Details added'**
  String get detailsSaved;

  /// No description provided for @fullReport.
  ///
  /// In en, this message translates to:
  /// **'Full Report'**
  String get fullReport;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not available on mobile yet.'**
  String get notificationsUnavailable;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsRead;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get allCaughtUp;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications at the moment.'**
  String get noNewNotifications;

  /// No description provided for @failedLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedLoadNotifications;

  /// No description provided for @notificationsNetworkError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading notifications. Please check your internet connection and try again.'**
  String get notificationsNetworkError;

  /// No description provided for @notificationsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not update notifications. Please try again.'**
  String get notificationsUpdateFailed;

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New Report'**
  String get newReport;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get reportTitle;

  /// No description provided for @reportLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get reportLocation;

  /// No description provided for @reportDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get reportDescription;

  /// No description provided for @reportTiming.
  ///
  /// In en, this message translates to:
  /// **'Report Timing'**
  String get reportTiming;

  /// No description provided for @briefTitle.
  ///
  /// In en, this message translates to:
  /// **'Brief title for your report'**
  String get briefTitle;

  /// No description provided for @whatIsHappening.
  ///
  /// In en, this message translates to:
  /// **'What is happening?'**
  String get whatIsHappening;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address or nearby landmark'**
  String get streetAddress;

  /// No description provided for @isHappeningNow.
  ///
  /// In en, this message translates to:
  /// **'Is this happening right now?'**
  String get isHappeningNow;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCity;

  /// No description provided for @selectBarangay.
  ///
  /// In en, this message translates to:
  /// **'Select barangay'**
  String get selectBarangay;

  /// No description provided for @loadingBarangays.
  ///
  /// In en, this message translates to:
  /// **'Loading barangays…'**
  String get loadingBarangays;

  /// No description provided for @continueToReview.
  ///
  /// In en, this message translates to:
  /// **'Continue to Review'**
  String get continueToReview;

  /// No description provided for @usePhoneLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Phone Location'**
  String get usePhoneLocation;

  /// No description provided for @manualPin.
  ///
  /// In en, this message translates to:
  /// **'Manual Pin'**
  String get manualPin;

  /// No description provided for @recenterToCity.
  ///
  /// In en, this message translates to:
  /// **'Recenter to city'**
  String get recenterToCity;

  /// No description provided for @refreshLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh location'**
  String get refreshLocation;

  /// No description provided for @useCityCenter.
  ///
  /// In en, this message translates to:
  /// **'Use {city} center'**
  String useCityCenter(String city);

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @noPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet'**
  String get noPhotosYet;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @confirmAccurate.
  ///
  /// In en, this message translates to:
  /// **'I confirm the information is accurate'**
  String get confirmAccurate;

  /// No description provided for @consentDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'I consent to data processing'**
  String get consentDataProcessing;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get reportSubmitted;

  /// No description provided for @reportPendingSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync'**
  String get reportPendingSyncTitle;

  /// No description provided for @reportPendingSync.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Not yet transmitted to BayanTrack.'**
  String get reportPendingSync;

  /// No description provided for @reportOutboxRetrying.
  ///
  /// In en, this message translates to:
  /// **'Will retry safely when BayanTrack is reachable.'**
  String get reportOutboxRetrying;

  /// No description provided for @reportOutboxWaitingAuth.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the original account to resume this report.'**
  String get reportOutboxWaitingAuth;

  /// No description provided for @reportOutboxNeedsEdit.
  ///
  /// In en, this message translates to:
  /// **'Report was not accepted. Edit and submit it again.'**
  String get reportOutboxNeedsEdit;

  /// No description provided for @reportOutboxConflict.
  ///
  /// In en, this message translates to:
  /// **'Submission could not be confirmed. Edit report before resubmitting.'**
  String get reportOutboxConflict;

  /// No description provided for @reportOutboxRetryNow.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get reportOutboxRetryNow;

  /// No description provided for @reportOutboxEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit and resubmit'**
  String get reportOutboxEdit;

  /// No description provided for @reportEvidenceHandoffTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence upload'**
  String get reportEvidenceHandoffTitle;

  /// No description provided for @reportEvidenceHandoffPending.
  ///
  /// In en, this message translates to:
  /// **'Report received. Evidence is still waiting to upload.'**
  String get reportEvidenceHandoffPending;

  /// No description provided for @reportEvidenceHandoffRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry evidence upload'**
  String get reportEvidenceHandoffRetry;

  /// No description provided for @addOptionalPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add an optional photo as evidence?'**
  String get addOptionalPhoto;

  /// No description provided for @photoEvidenceSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one or more photos to attach to this report.'**
  String get photoEvidenceSelectionHint;

  /// No description provided for @selectedPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s) selected'**
  String selectedPhotoCount(int count);

  /// No description provided for @uploadEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload evidence'**
  String get uploadEvidence;

  /// No description provided for @skipPhotoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipPhotoEvidence;

  /// No description provided for @reviewMine.
  ///
  /// In en, this message translates to:
  /// **'Review mine'**
  String get reviewMine;

  /// No description provided for @submitAnyway.
  ///
  /// In en, this message translates to:
  /// **'Submit anyway'**
  String get submitAnyway;

  /// No description provided for @reportsAlreadyNearby.
  ///
  /// In en, this message translates to:
  /// **'Reports already nearby'**
  String get reportsAlreadyNearby;

  /// No description provided for @submittingQuickReport.
  ///
  /// In en, this message translates to:
  /// **'Submitting Quick Report…'**
  String get submittingQuickReport;

  /// No description provided for @submitQuickReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Quick Report'**
  String get submitQuickReport;

  /// No description provided for @closeQuickReport.
  ///
  /// In en, this message translates to:
  /// **'Close Quick Report'**
  String get closeQuickReport;

  /// No description provided for @cityBoundary.
  ///
  /// In en, this message translates to:
  /// **'City boundary'**
  String get cityBoundary;

  /// No description provided for @phoneGps.
  ///
  /// In en, this message translates to:
  /// **'Phone GPS'**
  String get phoneGps;

  /// No description provided for @recenterCity.
  ///
  /// In en, this message translates to:
  /// **'Recenter city'**
  String get recenterCity;

  /// No description provided for @reportCreated.
  ///
  /// In en, this message translates to:
  /// **'Report created successfully.'**
  String get reportCreated;

  /// No description provided for @evidenceUploadPending.
  ///
  /// In en, this message translates to:
  /// **'Evidence upload pending'**
  String get evidenceUploadPending;

  /// No description provided for @reportHistory.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get reportHistory;

  /// No description provided for @noReportsYet.
  ///
  /// In en, this message translates to:
  /// **'No reports yet'**
  String get noReportsYet;

  /// No description provided for @noReportsMessage.
  ///
  /// In en, this message translates to:
  /// **'Reports you submit will appear here.'**
  String get noReportsMessage;

  /// No description provided for @failedLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports'**
  String get failedLoadReports;

  /// No description provided for @reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// No description provided for @deleteReportConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report?'**
  String get deleteReportConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @closeReport.
  ///
  /// In en, this message translates to:
  /// **'Close Report'**
  String get closeReport;

  /// No description provided for @verifyReport.
  ///
  /// In en, this message translates to:
  /// **'Verify Report'**
  String get verifyReport;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryEngineeringInfrastructure.
  ///
  /// In en, this message translates to:
  /// **'Municipal Engineering & Infrastructure'**
  String get categoryEngineeringInfrastructure;

  /// No description provided for @categoryFloodDisaster.
  ///
  /// In en, this message translates to:
  /// **'Flood & Disaster Response'**
  String get categoryFloodDisaster;

  /// No description provided for @categoryWasteEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Solid Waste & Environmental Management'**
  String get categoryWasteEnvironment;

  /// No description provided for @categoryPublicSafety.
  ///
  /// In en, this message translates to:
  /// **'Public Safety & Order'**
  String get categoryPublicSafety;

  /// No description provided for @categoryPublicUtilities.
  ///
  /// In en, this message translates to:
  /// **'Public Utilities & Service'**
  String get categoryPublicUtilities;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get underReview;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @resolvedStatus.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedStatus;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @unknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get unknownLocation;

  /// No description provided for @aiSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get aiSuggestion;

  /// No description provided for @queuePriority.
  ///
  /// In en, this message translates to:
  /// **'Queue priority'**
  String get queuePriority;

  /// No description provided for @notificationsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get notificationsEmail;

  /// No description provided for @notificationsPush.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notificationsPush;

  /// No description provided for @notifyStatusChange.
  ///
  /// In en, this message translates to:
  /// **'Status Change'**
  String get notifyStatusChange;

  /// No description provided for @notifyComment.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get notifyComment;

  /// No description provided for @notifyAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get notifyAssignment;

  /// No description provided for @preferencesSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save notification preferences.'**
  String get preferencesSaveFailed;

  /// No description provided for @kyc.
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kyc;

  /// No description provided for @kycStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get kycStatus;

  /// No description provided for @kycPending.
  ///
  /// In en, this message translates to:
  /// **'Your verification is pending review.'**
  String get kycPending;

  /// No description provided for @kycVerified.
  ///
  /// In en, this message translates to:
  /// **'Your identity is verified.'**
  String get kycVerified;

  /// No description provided for @kycRejected.
  ///
  /// In en, this message translates to:
  /// **'Your verification was rejected. Please resubmit your documents.'**
  String get kycRejected;

  /// No description provided for @kycUnverified.
  ///
  /// In en, this message translates to:
  /// **'Complete identity verification to unlock all features.'**
  String get kycUnverified;

  /// No description provided for @submitVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit Verification'**
  String get submitVerification;

  /// No description provided for @resubmitDocuments.
  ///
  /// In en, this message translates to:
  /// **'Correct & Resubmit'**
  String get resubmitDocuments;

  /// No description provided for @withdrawSubmission.
  ///
  /// In en, this message translates to:
  /// **'Withdraw submission'**
  String get withdrawSubmission;

  /// No description provided for @withdrawSubmissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw pending submission?'**
  String get withdrawSubmissionTitle;

  /// No description provided for @withdrawSubmissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Your application will be removed from staff review. You can edit and submit it again.'**
  String get withdrawSubmissionDescription;

  /// No description provided for @withdrawalSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Submission withdrawn. You can edit and submit again.'**
  String get withdrawalSucceeded;

  /// No description provided for @viewStatus.
  ///
  /// In en, this message translates to:
  /// **'View Status'**
  String get viewStatus;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String fieldRequired(String field);

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Philippine mobile number'**
  String get invalidPhone;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters'**
  String passwordMinLength(int min);

  /// No description provided for @passwordUppercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter'**
  String get passwordUppercase;

  /// No description provided for @passwordLowercase.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter'**
  String get passwordLowercase;

  /// No description provided for @passwordNumber.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get passwordNumber;

  /// No description provided for @passwordSpecial.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get passwordSpecial;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @confirmPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get confirmPasswordPrompt;

  /// No description provided for @fieldMaxLength.
  ///
  /// In en, this message translates to:
  /// **'{field} must be at most {max} characters'**
  String fieldMaxLength(String field, int max);

  /// No description provided for @lettersOnly.
  ///
  /// In en, this message translates to:
  /// **'{field} must contain letters only'**
  String lettersOnly(String field);

  /// No description provided for @meaningfulDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a meaningful description of the issue instead of “{text}”'**
  String meaningfulDescription(String text);

  /// No description provided for @descriptionDetailed.
  ///
  /// In en, this message translates to:
  /// **'Please provide a more detailed description (at least 10 characters)'**
  String get descriptionDetailed;

  /// No description provided for @descriptionNoRepetition.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meaningful description without excessive repetition'**
  String get descriptionNoRepetition;

  /// No description provided for @descriptionKeyboardMashing.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid description (keyboard mashing detected)'**
  String get descriptionKeyboardMashing;

  /// No description provided for @descriptionCoherent.
  ///
  /// In en, this message translates to:
  /// **'Please enter a coherent description'**
  String get descriptionCoherent;

  /// No description provided for @descriptionProperWords.
  ///
  /// In en, this message translates to:
  /// **'Please provide a meaningful description with proper words'**
  String get descriptionProperWords;

  /// No description provided for @descriptionSpecialCharacters.
  ///
  /// In en, this message translates to:
  /// **'Please reduce the use of special characters and numbers'**
  String get descriptionSpecialCharacters;

  /// No description provided for @requiredShort.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredShort;

  /// No description provided for @newPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'New password and confirmation do not match.'**
  String get newPasswordMismatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed.'**
  String get passwordChanged;

  /// No description provided for @passwordChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to change your password right now. Please try again.'**
  String get passwordChangeFailed;

  /// No description provided for @passwordExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Password change required'**
  String get passwordExpiredTitle;

  /// No description provided for @passwordExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has expired. Change it to continue using BayanTrack.'**
  String get passwordExpiredMessage;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load profile.'**
  String get profileLoadFailed;

  /// No description provided for @profileUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to update profile. Please try again.'**
  String get profileUpdateFailed;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @flashlightOn.
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight on'**
  String get flashlightOn;

  /// No description provided for @flashlightOff.
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight off'**
  String get flashlightOff;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Welcome to BayanTrack.'**
  String get registrationSuccess;

  /// No description provided for @policyCanAccept.
  ///
  /// In en, this message translates to:
  /// **'You can now accept.'**
  String get policyCanAccept;

  /// No description provided for @policyScrollToAccept.
  ///
  /// In en, this message translates to:
  /// **'Scroll to the bottom to enable Accept.'**
  String get policyScrollToAccept;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @escalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get escalated;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports…'**
  String get searchReports;

  /// No description provided for @browseReports.
  ///
  /// In en, this message translates to:
  /// **'Browse public reports'**
  String get browseReports;

  /// No description provided for @homeGuidance.
  ///
  /// In en, this message translates to:
  /// **'See what is happening around you and follow community updates.'**
  String get homeGuidance;

  /// No description provided for @filterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get filterByStatus;

  /// No description provided for @myReportsGuidance.
  ///
  /// In en, this message translates to:
  /// **'Track reports you submitted and any next steps.'**
  String get myReportsGuidance;

  /// No description provided for @reportsAwaitingReview.
  ///
  /// In en, this message translates to:
  /// **'{count} awaiting your confirmation'**
  String reportsAwaitingReview(int count);

  /// No description provided for @notificationsGuidance.
  ///
  /// In en, this message translates to:
  /// **'Updates about your reports and verification appear here.'**
  String get notificationsGuidance;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadNotifications(int count);

  /// No description provided for @reportCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1 {report} other {reports}}'**
  String reportCount(int count);

  /// No description provided for @scrollLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more'**
  String get scrollLoadMore;

  /// No description provided for @noMoreReports.
  ///
  /// In en, this message translates to:
  /// **'No more reports'**
  String get noMoreReports;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hr ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @noReportsMatch.
  ///
  /// In en, this message translates to:
  /// **'No reports match the selected filters.'**
  String get noReportsMatch;

  /// No description provided for @noReportsForFilter.
  ///
  /// In en, this message translates to:
  /// **'You have no reports for the selected filter.'**
  String get noReportsForFilter;

  /// No description provided for @unableLoadReports.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reports'**
  String get unableLoadReports;

  /// No description provided for @reportsNetworkError.
  ///
  /// In en, this message translates to:
  /// **'We’re having trouble loading reports. Please check your internet connection and try again.'**
  String get reportsNetworkError;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level} — {name}'**
  String priorityLevel(int level, String name);

  /// No description provided for @unscored.
  ///
  /// In en, this message translates to:
  /// **'Unscored'**
  String get unscored;

  /// No description provided for @uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get uncategorized;

  /// No description provided for @linkedReports.
  ///
  /// In en, this message translates to:
  /// **'{count} linked'**
  String linkedReports(int count);

  /// No description provided for @distanceAway.
  ///
  /// In en, this message translates to:
  /// **'{distance} m away'**
  String distanceAway(int distance);

  /// No description provided for @groupedIncident.
  ///
  /// In en, this message translates to:
  /// **'grouped incident'**
  String get groupedIncident;

  /// No description provided for @unknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownTime;

  /// No description provided for @evidenceFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Evidence file is missing.'**
  String get evidenceFileMissing;

  /// No description provided for @evidenceUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Evidence upload failed.'**
  String get evidenceUploadFailed;

  /// No description provided for @evidenceUploadsPending.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. {count} evidence upload{count, plural, =1 {} other {s}} pending.'**
  String evidenceUploadsPending(int count);

  /// No description provided for @evidenceUploadCompleted.
  ///
  /// In en, this message translates to:
  /// **'Evidence upload completed.'**
  String get evidenceUploadCompleted;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account & security'**
  String get accountSecurity;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @cachedReportsOffline.
  ///
  /// In en, this message translates to:
  /// **'Backend unavailable. Showing saved reports; information may be outdated.'**
  String get cachedReportsOffline;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @emailUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get emailUpdates;

  /// No description provided for @pushUpdates.
  ///
  /// In en, this message translates to:
  /// **'Receive updates on this device'**
  String get pushUpdates;

  /// No description provided for @statusChangeUpdates.
  ///
  /// In en, this message translates to:
  /// **'When report status changes'**
  String get statusChangeUpdates;

  /// No description provided for @commentUpdates.
  ///
  /// In en, this message translates to:
  /// **'When someone comments on your report'**
  String get commentUpdates;

  /// No description provided for @assignmentUpdates.
  ///
  /// In en, this message translates to:
  /// **'When a report is assigned'**
  String get assignmentUpdates;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'OTP'**
  String get otp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create your new password.'**
  String get createNewPassword;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent. Please check your email.'**
  String get otpSent;

  /// No description provided for @otpResent.
  ///
  /// In en, this message translates to:
  /// **'OTP resent. Please check your email.'**
  String get otpResent;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to {email}'**
  String otpSentTo(String email);

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get otpRequired;

  /// No description provided for @otpSixDigits.
  ///
  /// In en, this message translates to:
  /// **'OTP must be 6 digits'**
  String get otpSixDigits;

  /// No description provided for @rememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password?'**
  String get rememberPassword;

  /// No description provided for @passwordResetSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful. Please log in.'**
  String get passwordResetSuccessful;

  /// No description provided for @sessionExpiredVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please verify the OTP again.'**
  String get sessionExpiredVerifyOtp;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @phoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Include the country code, for example +639123456789 or +12025550123.'**
  String get phoneHelper;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Choose an image smaller than 5 MB.'**
  String get imageTooLarge;

  /// No description provided for @profilePictureUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated.'**
  String get profilePictureUpdated;

  /// No description provided for @avatarUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Keep this preview and tap Retry when ready.'**
  String get avatarUploadFailed;

  /// No description provided for @profilePictureRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile picture removed.'**
  String get profilePictureRemoved;

  /// No description provided for @removePictureFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove the profile picture.'**
  String get removePictureFailed;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your profile has been updated.'**
  String get profileUpdated;

  /// No description provided for @saveProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to save. Refresh the profile and try again.'**
  String get saveProfileFailed;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChanges;

  /// No description provided for @unsavedProfileChanges.
  ///
  /// In en, this message translates to:
  /// **'Your unsaved profile changes will be lost.'**
  String get unsavedProfileChanges;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile picture'**
  String get profilePicture;

  /// No description provided for @removingProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Removing profile picture…'**
  String get removingProfilePicture;

  /// No description provided for @uploadingPercent.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploadingPercent(int percent);

  /// No description provided for @profilePictureReplicationPending.
  ///
  /// In en, this message translates to:
  /// **'Profile picture available; backup replication is pending.'**
  String get profilePictureReplicationPending;

  /// No description provided for @addPicture.
  ///
  /// In en, this message translates to:
  /// **'Add picture'**
  String get addPicture;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @imageFormats.
  ///
  /// In en, this message translates to:
  /// **'JPEG, PNG, or WebP. Maximum 5 MB.'**
  String get imageFormats;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @strong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strong;

  /// No description provided for @veryStrong.
  ///
  /// In en, this message translates to:
  /// **'Very Strong'**
  String get veryStrong;

  /// No description provided for @superStrong.
  ///
  /// In en, this message translates to:
  /// **'Super Strong'**
  String get superStrong;

  /// No description provided for @passwordMustContain.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain:'**
  String get passwordMustContain;

  /// No description provided for @minimumCharacters.
  ///
  /// In en, this message translates to:
  /// **'Minimum number of characters is 8.'**
  String get minimumCharacters;

  /// No description provided for @lowercaseRequirement.
  ///
  /// In en, this message translates to:
  /// **'Should contain lowercase.'**
  String get lowercaseRequirement;

  /// No description provided for @uppercaseRequirement.
  ///
  /// In en, this message translates to:
  /// **'Should contain uppercase.'**
  String get uppercaseRequirement;

  /// No description provided for @numberRequirement.
  ///
  /// In en, this message translates to:
  /// **'Should contain numbers.'**
  String get numberRequirement;

  /// No description provided for @specialCharacterRequirement.
  ///
  /// In en, this message translates to:
  /// **'Should contain special characters.'**
  String get specialCharacterRequirement;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {count}'**
  String stepOf(int step, int count);

  /// No description provided for @describeReportIssue.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue you\'re reporting'**
  String get describeReportIssue;

  /// No description provided for @aiCategorize.
  ///
  /// In en, this message translates to:
  /// **'AI will automatically categorize your report'**
  String get aiCategorize;

  /// No description provided for @incidentOngoingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mark if this incident is ongoing'**
  String get incidentOngoingSubtitle;

  /// No description provided for @locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get locationDetails;

  /// No description provided for @cityMetadataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'City metadata is unavailable.'**
  String get cityMetadataUnavailable;

  /// No description provided for @placeLocationPin.
  ///
  /// In en, this message translates to:
  /// **'Place a location pin for the selected city.'**
  String get placeLocationPin;

  /// No description provided for @pleaseSelectCity.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get pleaseSelectCity;

  /// No description provided for @bundledBarangays.
  ///
  /// In en, this message translates to:
  /// **'Using bundled Urdaneta barangays'**
  String get bundledBarangays;

  /// No description provided for @barangaysUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Barangays unavailable for this city'**
  String get barangaysUnavailable;

  /// No description provided for @streetLandmark.
  ///
  /// In en, this message translates to:
  /// **'Street / Landmark'**
  String get streetLandmark;

  /// No description provided for @aiDetectSeverity.
  ///
  /// In en, this message translates to:
  /// **'AI will automatically detect severity and urgency from your description'**
  String get aiDetectSeverity;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @photosOptional.
  ///
  /// In en, this message translates to:
  /// **'Add photos if available. You can continue without them.'**
  String get photosOptional;

  /// No description provided for @optionalShort.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optionalShort;

  /// No description provided for @useButtonsAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Use the buttons below to add photos'**
  String get useButtonsAddPhotos;

  /// No description provided for @primaryPhoto.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primaryPhoto;

  /// No description provided for @selectLocationDescription.
  ///
  /// In en, this message translates to:
  /// **'Use phone GPS or a manual pin within Urdaneta City.'**
  String get selectLocationDescription;

  /// No description provided for @phoneLocation.
  ///
  /// In en, this message translates to:
  /// **'Phone Location'**
  String get phoneLocation;

  /// No description provided for @tapMapWithin.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place your pin within {city}.'**
  String tapMapWithin(String city);

  /// No description provided for @locationServicesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled. Please enable GPS.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Location permissions are permanently denied. Enable them in Settings.'**
  String get locationPermissionSettings;

  /// No description provided for @locationRequestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Location request timed out. Please try again.'**
  String get locationRequestTimedOut;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location'**
  String get gettingLocation;

  /// No description provided for @gettingLocationNotification.
  ///
  /// In en, this message translates to:
  /// **'BayanTrack is getting your location'**
  String get gettingLocationNotification;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Review & Submit'**
  String get reviewSubmit;

  /// No description provided for @reviewSubmissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Review your report and confirm submission'**
  String get reviewSubmissionDescription;

  /// No description provided for @photoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photo(s)'**
  String photoCount(int count);

  /// No description provided for @locationSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get locationSet;

  /// No description provided for @locationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get locationNotSet;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @gps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gps;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @aiDetectCategory.
  ///
  /// In en, this message translates to:
  /// **'AI will automatically detect category, severity, and urgency'**
  String get aiDetectCategory;

  /// No description provided for @declarationConsent.
  ///
  /// In en, this message translates to:
  /// **'Declaration & Consent'**
  String get declarationConsent;

  /// No description provided for @declarationText.
  ///
  /// In en, this message translates to:
  /// **'I declare that all information provided is true and accurate to the best of my knowledge.'**
  String get declarationText;

  /// No description provided for @consentText.
  ///
  /// In en, this message translates to:
  /// **'I consent to the processing of my personal data for the purpose of handling this report.'**
  String get consentText;

  /// No description provided for @consentRequired.
  ///
  /// In en, this message translates to:
  /// **'You must confirm the declaration and consent to submit'**
  String get consentRequired;

  /// No description provided for @signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again before submitting.'**
  String get signInAgain;

  /// No description provided for @submittingReport.
  ///
  /// In en, this message translates to:
  /// **'Submitting your report…'**
  String get submittingReport;

  /// No description provided for @unableSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the report. Please try again.'**
  String get unableSubmitReport;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get noImages;

  /// No description provided for @aiSuggestionPending.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion — staff review pending'**
  String get aiSuggestionPending;

  /// No description provided for @operationalPriority.
  ///
  /// In en, this message translates to:
  /// **'Operational priority'**
  String get operationalPriority;

  /// No description provided for @confirmedLinkedReports.
  ///
  /// In en, this message translates to:
  /// **'{count} confirmed linked reports'**
  String confirmedLinkedReports(int count);

  /// No description provided for @credibility.
  ///
  /// In en, this message translates to:
  /// **'Credibility {score}/100'**
  String credibility(int score);

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @recenterToMunicipality.
  ///
  /// In en, this message translates to:
  /// **'Recenter to {city}'**
  String recenterToMunicipality(String city);

  /// No description provided for @aiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysis;

  /// No description provided for @categoryConfidence.
  ///
  /// In en, this message translates to:
  /// **'Category confidence'**
  String get categoryConfidence;

  /// No description provided for @aiDepartmentSuggestion.
  ///
  /// In en, this message translates to:
  /// **'AI department suggestion'**
  String get aiDepartmentSuggestion;

  /// No description provided for @currentHandler.
  ///
  /// In en, this message translates to:
  /// **'Current handler'**
  String get currentHandler;

  /// No description provided for @routingStatus.
  ///
  /// In en, this message translates to:
  /// **'Routing status'**
  String get routingStatus;

  /// No description provided for @awaitingStaffConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Awaiting your confirmation'**
  String get awaitingStaffConfirmation;

  /// No description provided for @routingPolicyApplied.
  ///
  /// In en, this message translates to:
  /// **'Routing policy applied'**
  String get routingPolicyApplied;

  /// No description provided for @resolutionProof.
  ///
  /// In en, this message translates to:
  /// **'Response evidence'**
  String get resolutionProof;

  /// No description provided for @resolutionProofResolved.
  ///
  /// In en, this message translates to:
  /// **'Evidence from the Department for your review before you confirm.'**
  String get resolutionProofResolved;

  /// No description provided for @resolutionProofClosed.
  ///
  /// In en, this message translates to:
  /// **'Staff-uploaded proof associated with this closed report.'**
  String get resolutionProofClosed;

  /// No description provided for @alreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted your review. Thank you!'**
  String get alreadyReviewed;

  /// No description provided for @reportResolved.
  ///
  /// In en, this message translates to:
  /// **'Your report has been resolved!'**
  String get reportResolved;

  /// No description provided for @resolvedReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Review the Department\'s resolution. Confirming lets the City proceed with final closure; disputing returns the report to the City for review.'**
  String get resolvedReviewDescription;

  /// No description provided for @reviewSignOff.
  ///
  /// In en, this message translates to:
  /// **'Review & Sign Off'**
  String get reviewSignOff;

  /// No description provided for @blockchainVerification.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Verification'**
  String get blockchainVerification;

  /// No description provided for @verifyNow.
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get verifyNow;

  /// No description provided for @auditHistory.
  ///
  /// In en, this message translates to:
  /// **'Audit History'**
  String get auditHistory;

  /// No description provided for @noAuditEntries.
  ///
  /// In en, this message translates to:
  /// **'No audit entries found.'**
  String get noAuditEntries;

  /// No description provided for @blockchainAnchored.
  ///
  /// In en, this message translates to:
  /// **'This report is anchored on the blockchain. Click verify to perform a live integrity check.'**
  String get blockchainAnchored;

  /// No description provided for @blockchainPending.
  ///
  /// In en, this message translates to:
  /// **'This report is pending blockchain synchronization.'**
  String get blockchainPending;

  /// No description provided for @integrityVerified.
  ///
  /// In en, this message translates to:
  /// **'Integrity Verified'**
  String get integrityVerified;

  /// No description provided for @contentVerified.
  ///
  /// In en, this message translates to:
  /// **'Content Verified'**
  String get contentVerified;

  /// No description provided for @notYetAnchored.
  ///
  /// In en, this message translates to:
  /// **'Not Yet Anchored'**
  String get notYetAnchored;

  /// No description provided for @recordNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record Not Found'**
  String get recordNotFound;

  /// No description provided for @blockchainUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Blockchain Unavailable'**
  String get blockchainUnavailable;

  /// No description provided for @integrityBreach.
  ///
  /// In en, this message translates to:
  /// **'Integrity Breach Detected'**
  String get integrityBreach;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed. Please try again later.'**
  String get verificationFailed;

  /// No description provided for @byActor.
  ///
  /// In en, this message translates to:
  /// **'By {actor}'**
  String byActor(String actor);

  /// No description provided for @statusTransition.
  ///
  /// In en, this message translates to:
  /// **'Status: {oldStatus} → {newStatus}'**
  String statusTransition(String oldStatus, String newStatus);

  /// No description provided for @reviewResolution.
  ///
  /// In en, this message translates to:
  /// **'Review Resolution'**
  String get reviewResolution;

  /// No description provided for @reviewAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review Already Submitted'**
  String get reviewAlreadySubmitted;

  /// No description provided for @reviewNoFurtherAction.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted your review and digital signature for this report. No further action is needed.'**
  String get reviewNoFurtherAction;

  /// No description provided for @resolutionSummary.
  ///
  /// In en, this message translates to:
  /// **'Department resolution summary'**
  String get resolutionSummary;

  /// No description provided for @rateResponse.
  ///
  /// In en, this message translates to:
  /// **'Rate the Response (optional)'**
  String get rateResponse;

  /// No description provided for @veryDissatisfied.
  ///
  /// In en, this message translates to:
  /// **'Very Dissatisfied'**
  String get veryDissatisfied;

  /// No description provided for @dissatisfied.
  ///
  /// In en, this message translates to:
  /// **'Dissatisfied'**
  String get dissatisfied;

  /// No description provided for @neutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get neutral;

  /// No description provided for @satisfied.
  ///
  /// In en, this message translates to:
  /// **'Satisfied'**
  String get satisfied;

  /// No description provided for @verySatisfied.
  ///
  /// In en, this message translates to:
  /// **'Very Satisfied'**
  String get verySatisfied;

  /// No description provided for @additionalComments.
  ///
  /// In en, this message translates to:
  /// **'Additional Comments (optional)'**
  String get additionalComments;

  /// No description provided for @resolutionCommentsHint.
  ///
  /// In en, this message translates to:
  /// **'Describe how the issue was resolved or any remaining concerns…'**
  String get resolutionCommentsHint;

  /// No description provided for @digitalSignature.
  ///
  /// In en, this message translates to:
  /// **'Digital Signature'**
  String get digitalSignature;

  /// No description provided for @signatureInstructions.
  ///
  /// In en, this message translates to:
  /// **'Draw your signature in the box below, then type your full name to confirm your identity and authenticate this review.'**
  String get signatureInstructions;

  /// No description provided for @signHere.
  ///
  /// In en, this message translates to:
  /// **'Sign here'**
  String get signHere;

  /// No description provided for @signatureRequired.
  ///
  /// In en, this message translates to:
  /// **'Please draw your signature above.'**
  String get signatureRequired;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Juan dela Cruz'**
  String get fullNameHint;

  /// No description provided for @registeredNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your registered full name.'**
  String get registeredNameRequired;

  /// No description provided for @confirmResolved.
  ///
  /// In en, this message translates to:
  /// **'Confirm resolution'**
  String get confirmResolved;

  /// No description provided for @disputeUnresolved.
  ///
  /// In en, this message translates to:
  /// **'Dispute resolution'**
  String get disputeUnresolved;

  /// No description provided for @disputeNotice.
  ///
  /// In en, this message translates to:
  /// **'Disputing returns the report to the City for review.'**
  String get disputeNotice;

  /// No description provided for @disputeResolution.
  ///
  /// In en, this message translates to:
  /// **'Dispute resolution'**
  String get disputeResolution;

  /// No description provided for @disputeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Explain what remains unresolved. The report will return to the City for review.'**
  String get disputeConfirmation;

  /// No description provided for @disputeReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for dispute'**
  String get disputeReasonLabel;

  /// No description provided for @disputeReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what still needs attention'**
  String get disputeReasonHint;

  /// No description provided for @disputeReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please explain what remains unresolved.'**
  String get disputeReasonRequired;

  /// No description provided for @disputeSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit. Check your connection and try again.'**
  String get disputeSubmitFailed;

  /// No description provided for @yesDispute.
  ///
  /// In en, this message translates to:
  /// **'Submit dispute'**
  String get yesDispute;

  /// No description provided for @resolvedDefaultNote.
  ///
  /// In en, this message translates to:
  /// **'The barangay has marked this report as resolved.'**
  String get resolvedDefaultNote;

  /// No description provided for @reportConfirmedResolved.
  ///
  /// In en, this message translates to:
  /// **'Report confirmed as resolved.'**
  String get reportConfirmedResolved;

  /// No description provided for @reportReopenedEscalated.
  ///
  /// In en, this message translates to:
  /// **'Report has been re-opened and escalated.'**
  String get reportReopenedEscalated;

  /// No description provided for @resubmitUserVerification.
  ///
  /// In en, this message translates to:
  /// **'Resubmit User Verification'**
  String get resubmitUserVerification;

  /// No description provided for @submitUserVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit User Verification'**
  String get submitUserVerification;

  /// No description provided for @basicIdentity.
  ///
  /// In en, this message translates to:
  /// **'Basic Identity'**
  String get basicIdentity;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInformation;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfo;

  /// No description provided for @emailPhone.
  ///
  /// In en, this message translates to:
  /// **'Email & phone'**
  String get emailPhone;

  /// No description provided for @currentResidence.
  ///
  /// In en, this message translates to:
  /// **'Current residence'**
  String get currentResidence;

  /// No description provided for @governmentId.
  ///
  /// In en, this message translates to:
  /// **'Government ID'**
  String get governmentId;

  /// No description provided for @idTypeNumber.
  ///
  /// In en, this message translates to:
  /// **'ID type & number'**
  String get idTypeNumber;

  /// No description provided for @idPhotos.
  ///
  /// In en, this message translates to:
  /// **'ID Photos'**
  String get idPhotos;

  /// No description provided for @uploadIdImages.
  ///
  /// In en, this message translates to:
  /// **'Upload ID images'**
  String get uploadIdImages;

  /// No description provided for @selfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get selfie;

  /// No description provided for @faceVerification.
  ///
  /// In en, this message translates to:
  /// **'Face verification'**
  String get faceVerification;

  /// No description provided for @declaration.
  ///
  /// In en, this message translates to:
  /// **'Declaration'**
  String get declaration;

  /// No description provided for @confirmSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm & submit'**
  String get confirmSubmit;

  /// No description provided for @middleName.
  ///
  /// In en, this message translates to:
  /// **'Middle Name'**
  String get middleName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @sex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get sex;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @nationalityExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Filipino'**
  String get nationalityExample;

  /// No description provided for @civilStatus.
  ///
  /// In en, this message translates to:
  /// **'Civil Status'**
  String get civilStatus;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @mobileNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumberRequired;

  /// No description provided for @mobileNumberDigits.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Philippine mobile number (09xxxxxxxxx or +639xxxxxxxxx)'**
  String get mobileNumberDigits;

  /// No description provided for @houseStreet.
  ///
  /// In en, this message translates to:
  /// **'House No. / Street'**
  String get houseStreet;

  /// No description provided for @houseStreetHint.
  ///
  /// In en, this message translates to:
  /// **'House No., Street'**
  String get houseStreetHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get zipCode;

  /// No description provided for @idType.
  ///
  /// In en, this message translates to:
  /// **'ID Type'**
  String get idType;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @idExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'ID Expiry Date (if applicable)'**
  String get idExpiryDate;

  /// No description provided for @selectOptionalDate.
  ///
  /// In en, this message translates to:
  /// **'Select date (optional)'**
  String get selectOptionalDate;

  /// No description provided for @uploadGovId.
  ///
  /// In en, this message translates to:
  /// **'Upload clear photos of your Government ID'**
  String get uploadGovId;

  /// No description provided for @scanId.
  ///
  /// In en, this message translates to:
  /// **'Scan ID'**
  String get scanId;

  /// No description provided for @scanIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a clear front photo. Text recognition runs on this device.'**
  String get scanIdDescription;

  /// No description provided for @fitIdInsideFrame.
  ///
  /// In en, this message translates to:
  /// **'Fit your ID inside the frame'**
  String get fitIdInsideFrame;

  /// No description provided for @keepIdFlatReadable.
  ///
  /// In en, this message translates to:
  /// **'Keep it flat and readable'**
  String get keepIdFlatReadable;

  /// No description provided for @chooseVerificationMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose how to verify'**
  String get chooseVerificationMethod;

  /// No description provided for @chooseVerificationMethodDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose whether to scan an ID for review or enter your details yourself.'**
  String get chooseVerificationMethodDescription;

  /// No description provided for @scanIdOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan an ID'**
  String get scanIdOptionTitle;

  /// No description provided for @scanIdOptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Extract details from your ID for review, then complete the rest of the form.'**
  String get scanIdOptionDescription;

  /// No description provided for @manualEntryOptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter details manually'**
  String get manualEntryOptionTitle;

  /// No description provided for @manualEntryOptionDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in your identity details yourself. OCR is skipped.'**
  String get manualEntryOptionDescription;

  /// No description provided for @maxImageFormats.
  ///
  /// In en, this message translates to:
  /// **'Max 10MB each • JPG, PNG formats'**
  String get maxImageFormats;

  /// No description provided for @idFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'ID Front Photo'**
  String get idFrontPhoto;

  /// No description provided for @idBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'ID Back Photo'**
  String get idBackPhoto;

  /// No description provided for @backPhotoRecommended.
  ///
  /// In en, this message translates to:
  /// **'Back photo recommended for {idType}'**
  String backPhotoRecommended(String idType);

  /// No description provided for @selfieInstructions.
  ///
  /// In en, this message translates to:
  /// **'Take a clear selfie for face verification'**
  String get selfieInstructions;

  /// No description provided for @selfiePhoto.
  ///
  /// In en, this message translates to:
  /// **'Selfie Photo'**
  String get selfiePhoto;

  /// No description provided for @selfieHoldingId.
  ///
  /// In en, this message translates to:
  /// **'Selfie Holding ID (Recommended)'**
  String get selfieHoldingId;

  /// No description provided for @holdIdInstruction.
  ///
  /// In en, this message translates to:
  /// **'Hold your ID next to your face for stronger verification'**
  String get holdIdInstruction;

  /// No description provided for @submissionSummary.
  ///
  /// In en, this message translates to:
  /// **'Submission Summary'**
  String get submissionSummary;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @previousRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Previous Rejection Reason:'**
  String get previousRejectionReason;

  /// No description provided for @tapAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapAddPhoto;

  /// No description provided for @imageAccessError.
  ///
  /// In en, this message translates to:
  /// **'Could not access the image. Please try again.'**
  String get imageAccessError;

  /// No description provided for @verificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'User verification submitted successfully!'**
  String get verificationSubmitted;

  /// No description provided for @verificationResubmitted.
  ///
  /// In en, this message translates to:
  /// **'User verification resubmitted successfully!'**
  String get verificationResubmitted;

  /// No description provided for @verificationSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit user verification. Please try again.'**
  String get verificationSubmitFailed;

  /// No description provided for @reviewExtractedDetails.
  ///
  /// In en, this message translates to:
  /// **'Review extracted details'**
  String get reviewExtractedDetails;

  /// No description provided for @reviewExtractedDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'Check each suggestion and edit anything before continuing.'**
  String get reviewExtractedDetailsDescription;

  /// No description provided for @ocrScanning.
  ///
  /// In en, this message translates to:
  /// **'Reading your ID on this device…'**
  String get ocrScanning;

  /// No description provided for @ocrPartial.
  ///
  /// In en, this message translates to:
  /// **'Some details were found. Check them and fill any blanks.'**
  String get ocrPartial;

  /// No description provided for @ocrUnreadable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read this image. Retake the photo or enter details manually.'**
  String get ocrUnreadable;

  /// No description provided for @ocrUnsupported.
  ///
  /// In en, this message translates to:
  /// **'OCR is not available for this ID type yet. Enter details manually.'**
  String get ocrUnsupported;

  /// No description provided for @ocrManualReview.
  ///
  /// In en, this message translates to:
  /// **'Check this field'**
  String get ocrManualReview;

  /// No description provided for @ocrHighConfidence.
  ///
  /// In en, this message translates to:
  /// **'Clear text match'**
  String get ocrHighConfidence;

  /// No description provided for @ocrAuthenticityNotice.
  ///
  /// In en, this message translates to:
  /// **'OCR only helps fill the form. It does not verify that the ID is authentic.'**
  String get ocrAuthenticityNotice;

  /// No description provided for @fixFormErrors.
  ///
  /// In en, this message translates to:
  /// **'Please fix the highlighted errors in the form'**
  String get fixFormErrors;

  /// No description provided for @completeRequiredUploadImages.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields and upload images'**
  String get completeRequiredUploadImages;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @nationalityRequired.
  ///
  /// In en, this message translates to:
  /// **'Nationality is required'**
  String get nationalityRequired;

  /// No description provided for @mobileNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Mobile number is required'**
  String get mobileNumberRequiredError;

  /// No description provided for @emailAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get emailAddressRequired;

  /// No description provided for @selectIdType.
  ///
  /// In en, this message translates to:
  /// **'Please select an ID type'**
  String get selectIdType;

  /// No description provided for @idNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'ID number is required'**
  String get idNumberRequired;

  /// No description provided for @idFrontRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload a photo of your ID (front side)'**
  String get idFrontRequired;

  /// No description provided for @idBackRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload a photo of your ID (back side)'**
  String get idBackRequired;

  /// No description provided for @selfieRequired.
  ///
  /// In en, this message translates to:
  /// **'Please upload a selfie photo'**
  String get selfieRequired;

  /// No description provided for @declarationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the declaration to submit'**
  String get declarationRequired;

  /// No description provided for @allRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please complete all required fields'**
  String get allRequiredFields;

  /// No description provided for @declarationFullText.
  ///
  /// In en, this message translates to:
  /// **'I declare that all information provided is true and accurate. I consent to the processing of my personal data for identity verification purposes.'**
  String get declarationFullText;

  /// No description provided for @acceptDeclaration.
  ///
  /// In en, this message translates to:
  /// **'* You must accept the declaration to submit'**
  String get acceptDeclaration;

  /// No description provided for @reviewDetails.
  ///
  /// In en, this message translates to:
  /// **'Please review feedback'**
  String get reviewDetails;

  /// No description provided for @adminFeedback.
  ///
  /// In en, this message translates to:
  /// **'Admin Feedback'**
  String get adminFeedback;

  /// No description provided for @reviewAndResubmit.
  ///
  /// In en, this message translates to:
  /// **'Review the feedback and resubmit with corrected documents'**
  String get reviewAndResubmit;

  /// No description provided for @qualityCheckNotes.
  ///
  /// In en, this message translates to:
  /// **'Quality Check Notes'**
  String get qualityCheckNotes;

  /// No description provided for @submittedInformation.
  ///
  /// In en, this message translates to:
  /// **'Submitted Information'**
  String get submittedInformation;

  /// No description provided for @noVerificationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'No verification submitted yet'**
  String get noVerificationSubmitted;

  /// No description provided for @resubmissions.
  ///
  /// In en, this message translates to:
  /// **'Resubmissions'**
  String get resubmissions;

  /// No description provided for @kycResubmitRequested.
  ///
  /// In en, this message translates to:
  /// **'Additional information is required. Please resubmit your documents.'**
  String get kycResubmitRequested;

  /// No description provided for @kycSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your account verification has been suspended. Please contact support.'**
  String get kycSuspended;

  /// No description provided for @unverifiedLabel.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get unverifiedLabel;

  /// No description provided for @pendingReview.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get pendingReview;

  /// No description provided for @resubmitRequestedLabel.
  ///
  /// In en, this message translates to:
  /// **'Resubmit Requested'**
  String get resubmitRequestedLabel;

  /// No description provided for @suspendedLabel.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get suspendedLabel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @verificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get verificationRequired;

  /// No description provided for @verifyIdentityTo.
  ///
  /// In en, this message translates to:
  /// **'You need to verify your identity to {action}.'**
  String verifyIdentityTo(String action);

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @verificationNotice.
  ///
  /// In en, this message translates to:
  /// **'You can report now. Verification improves trust and unlocks account features.'**
  String get verificationNotice;

  /// No description provided for @switchManualPin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Manual Pin'**
  String get switchManualPin;

  /// No description provided for @waitingIncidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for an incident location…'**
  String get waitingIncidentLocation;

  /// No description provided for @tapMapIncident.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to choose an incident location.'**
  String get tapMapIncident;

  /// No description provided for @chooseIncidentLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose an incident location to continue.'**
  String get chooseIncidentLocation;

  /// No description provided for @incidentLocationSelected.
  ///
  /// In en, this message translates to:
  /// **'Incident location selected'**
  String get incidentLocationSelected;

  /// No description provided for @locationOutsideCity.
  ///
  /// In en, this message translates to:
  /// **'Location is outside {city}'**
  String locationOutsideCity(String city);

  /// No description provided for @phoneOutsideBoundary.
  ///
  /// In en, this message translates to:
  /// **'Your phone may be outside the city; the incident pin is inside the boundary.'**
  String get phoneOutsideBoundary;

  /// No description provided for @selectIncidentInside.
  ///
  /// In en, this message translates to:
  /// **'You do not need to be in the city. Select the incident inside {city}.'**
  String selectIncidentInside(String city);

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locating;

  /// No description provided for @tapMapPlaceIncident.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the incident pin'**
  String get tapMapPlaceIncident;

  /// No description provided for @gpsLocationFound.
  ///
  /// In en, this message translates to:
  /// **'GPS location found'**
  String get gpsLocationFound;

  /// No description provided for @chooseIncidentLocationShort.
  ///
  /// In en, this message translates to:
  /// **'Choose an incident location'**
  String get chooseIncidentLocationShort;

  /// No description provided for @incidentLocationMethod.
  ///
  /// In en, this message translates to:
  /// **'Incident location method'**
  String get incidentLocationMethod;

  /// No description provided for @tapInsideBoundary.
  ///
  /// In en, this message translates to:
  /// **'Tap inside the boundary to place the incident pin.'**
  String get tapInsideBoundary;

  /// No description provided for @showsDeviceLocations.
  ///
  /// In en, this message translates to:
  /// **'Shows device and selected incident locations.'**
  String get showsDeviceLocations;

  /// No description provided for @incidentLocationMap.
  ///
  /// In en, this message translates to:
  /// **'Incident location map'**
  String get incidentLocationMap;

  /// No description provided for @refreshDeviceLocation.
  ///
  /// In en, this message translates to:
  /// **'Refresh device location'**
  String get refreshDeviceLocation;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description'**
  String get shortDescription;

  /// No description provided for @shortDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what is happening. 500 characters maximum.'**
  String get shortDescriptionHint;

  /// No description provided for @shortDescriptionSemantics.
  ///
  /// In en, this message translates to:
  /// **'Describe what is happening in 500 characters or fewer.'**
  String get shortDescriptionSemantics;

  /// No description provided for @submissionError.
  ///
  /// In en, this message translates to:
  /// **'Submission error. {error}'**
  String submissionError(String error);

  /// No description provided for @submitDisabled.
  ///
  /// In en, this message translates to:
  /// **'Submit disabled. {reason}'**
  String submitDisabled(String reason);

  /// No description provided for @shortDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a short description to continue.'**
  String get shortDescriptionRequired;

  /// No description provided for @descriptionMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Description must be {count} characters or fewer.'**
  String descriptionMaxLength(int count);

  /// No description provided for @incidentPinInside.
  ///
  /// In en, this message translates to:
  /// **'Incident pin must be inside {city}.'**
  String incidentPinInside(String city);

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityVeryLow.
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get priorityVeryLow;

  /// No description provided for @priorityAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Priority Analysis'**
  String get priorityAnalysis;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(int score);

  /// No description provided for @baseScore.
  ///
  /// In en, this message translates to:
  /// **'Base: {score}'**
  String baseScore(int score);

  /// No description provided for @hotspotScore.
  ///
  /// In en, this message translates to:
  /// **'Hotspot: {score}'**
  String hotspotScore(int score);

  /// No description provided for @reasons.
  ///
  /// In en, this message translates to:
  /// **'Reasons:'**
  String get reasons;

  /// No description provided for @idPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get idPassport;

  /// No description provided for @idNational.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get idNational;

  /// No description provided for @idDriversLicense.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get idDriversLicense;

  /// No description provided for @idPhilsys.
  ///
  /// In en, this message translates to:
  /// **'PhilSys ID'**
  String get idPhilsys;

  /// No description provided for @idSss.
  ///
  /// In en, this message translates to:
  /// **'SSS ID'**
  String get idSss;

  /// No description provided for @idUmid.
  ///
  /// In en, this message translates to:
  /// **'UMID'**
  String get idUmid;

  /// No description provided for @idPostal.
  ///
  /// In en, this message translates to:
  /// **'Postal ID'**
  String get idPostal;

  /// No description provided for @idVoters.
  ///
  /// In en, this message translates to:
  /// **'Voter\'s ID'**
  String get idVoters;

  /// No description provided for @idGsisECard.
  ///
  /// In en, this message translates to:
  /// **'GSIS eCard'**
  String get idGsisECard;

  /// No description provided for @idPhilHealth.
  ///
  /// In en, this message translates to:
  /// **'PhilHealth ID'**
  String get idPhilHealth;

  /// No description provided for @idPrc.
  ///
  /// In en, this message translates to:
  /// **'PRC Professional ID'**
  String get idPrc;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @widowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get widowed;

  /// No description provided for @separated.
  ///
  /// In en, this message translates to:
  /// **'Separated'**
  String get separated;

  /// No description provided for @divorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get divorced;
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
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
