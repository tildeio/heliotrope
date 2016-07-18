module Import
  extend ActiveSupport::Autoload
  autoload :DummyUser
  autoload :MonographBuilder
  autoload :SectionBuilder
  autoload :FileSetBuilder
  autoload :Importer
  autoload :CSVParser
  autoload :RowData

  FIELDS =
    [
      # for now leave File Name separate, but eventually when external resources are figured out it should go in here too with required => false
      # { 'field_name' => 'File Name', 'metadata_name' => 'title', 'required' => true, 'multi_value' => false },
      { 'field_name' => 'Title', 'metadata_name' => 'title', 'required' => true, 'multi_value' => true },
      { 'field_name' => 'Resource Type', 'metadata_name' => 'resource_type', 'required' => true, 'multi_value' => true, 'acceptable_values' => ['audio', 'image', 'dataset', 'table', '3D model', 'text', 'video'] },
      { 'field_name' => 'Externally Hosted Resource', 'metadata_name' => 'external_resource', 'required' => true, 'multi_value' => false, 'acceptable_values' => ['yes', 'no'] },
      { 'field_name' => 'Caption', 'metadata_name' => 'caption', 'required' => true, 'multi_value' => true },
      { 'field_name' => 'Alternative Text', 'metadata_name' => 'alt_text', 'required' => true, 'multi_value' => true },
      { 'field_name' => 'Book and Platform (BP) or Platform-only (P)', 'metadata_name' => 'exclusive_to_platform', 'required' => true, 'multi_value' => false, 'acceptable_values' => ['BP', 'P'] },
      { 'field_name' => 'Copyright Holder', 'metadata_name' => 'copyright_holder', 'required' => true, 'multi_value' => false },
      { 'field_name' => 'Allow High-Res Display?', 'metadata_name' => 'allow_hi_res', 'required' => true, 'multi_value' => false, 'acceptable_values' => ['yes', 'no', 'Not hosted on the platform'] },
      { 'field_name' => 'Allow Download?', 'metadata_name' => 'allow_download', 'required' => true, 'multi_value' => false, 'acceptable_values' => ['yes', 'no', 'Not hosted on the platform'] },
      { 'field_name' => 'Copyright Status', 'metadata_name' => 'copyright_status', 'required' => true, 'multi_value' => false, 'acceptable_values' => ['in-copyright', 'public domain', 'status unknown'] },
      { 'field_name' => 'Rights Granted', 'metadata_name' => 'rights_granted', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Rights Granted - Creative Commons',
        'metadata_name' => 'rights_granted_creative_commons',
        'required' => false,
        'multi_value' => false,
        'acceptable_values' => [
          'Creative Commons Attribution license, 3.0 Unported',
          'Creative Commons Attribution-NoDerivatives license, 3.0 Unported',
          'Creative Commons Attribution-NonCommercial-NoDerivatives license, 3.0 Unported',
          'Creative Commons Attribution-NonCommercial license, 3.0 Unported',
          'Creative Commons Attribution-NonCommercial-ShareAlike license, 3.0 Unported',
          'Creative Commons Attribution-ShareAlike license, 3.0 Unported',
          'Creative Commons Zero license (implies pd)',
          'Creative Commons Attribution 4.0 International license',
          'Creative Commons Attribution-NoDerivatives 4.0 International license',
          'Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International license',
          'Creative Commons Attribution-NonCommercial 4.0 International license',
          'Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International license',
          'Creative Commons Attribution-ShareAlike 4.0 International license'] },
      { 'field_name' => 'Permissions Expiration Date', 'metadata_name' => 'permissions_expiration_date', 'required' => false, 'multi_value' => false, 'date_format' => true },
      { 'field_name' => 'After Expiration: Allow Display?', 'metadata_name' => 'allow_display_after_expiration', 'required' => false, 'multi_value' => false, 'acceptable_values' => ['none', 'high-res', 'low-res', 'Not hosted on the platform'] },
      { 'field_name' => 'After Expiration: Allow Download?', 'metadata_name' => 'allow_download_after_expiration', 'required' => false, 'multi_value' => false, 'acceptable_values' => ['yes', 'no', 'Not hosted on the platform'] },
      { 'field_name' => 'Credit Line', 'metadata_name' => 'credit_line', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Holding Contact', 'metadata_name' => 'holding_contact', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Persistent ID - Display on Platform', 'metadata_name' => 'ext_url_doi_or_handle', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Persistent ID - XML for CrossRef', 'metadata_name' => 'use_crossref_xml', 'required' => false, 'multi_value' => false, 'acceptable_values' => ['yes', 'no'] },
      { 'field_name' => 'Persistent ID - Handle', 'metadata_name' => 'book_needs_handles', 'required' => false, 'multi_value' => false, 'acceptable_values' => ['yes', 'no'] },
      { 'field_name' => 'Content Type', 'metadata_name' => 'content_type', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Primary Creator Role', 'metadata_name' => 'primary_creator_role', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Additional Creator(s)', 'metadata_name' => 'contributor', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Sort Date', 'metadata_name' => 'sort_date', 'required' => false, 'multi_value' => false, 'date_format' => true },
      { 'field_name' => 'Display Date', 'metadata_name' => 'display_date', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Description', 'metadata_name' => 'description', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Keywords', 'metadata_name' => 'keywords', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Language', 'metadata_name' => 'language', 'required' => false, 'multi_value' => true },
      { 'field_name' => 'Transcript', 'metadata_name' => 'transcript', 'required' => false, 'multi_value' => false },
      { 'field_name' => 'Translation', 'metadata_name' => 'translation', 'required' => false, 'multi_value' => true }
    ].freeze
end
