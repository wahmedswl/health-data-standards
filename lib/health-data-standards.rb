require 'erubis'
require 'active_support'
require 'mongoid'
require 'mongoid/tree'
require 'uuid'
require 'builder'
require 'csv'
require 'nokogiri'
require 'ostruct'
require 'log4r'
require 'memoist'
require 'protected_attributes'

# Freedom patches
require_relative 'health-data-standards/ext/symbol'
require_relative 'health-data-standards/ext/string'
require_relative 'health-data-standards/ext/node'

require_relative 'health-data-standards/util/nlm_helper'
require_relative 'health-data-standards/util/hl7_helper'
require_relative 'health-data-standards/util/code_system_helper'
require_relative 'health-data-standards/util/hqmf_template_helper'
require_relative 'health-data-standards/util/vs_api'

require_relative 'health-data-standards/export/template_helper'
require_relative 'health-data-standards/export/view_helper'
require_relative 'health-data-standards/export/rendering_context'
require_relative 'health-data-standards/export/c32'
require_relative 'health-data-standards/export/ccda'
require_relative 'health-data-standards/export/csv'
require_relative 'health-data-standards/export/hdata/metadata'
require_relative 'health-data-standards/export/exceptions'

require_relative 'health-data-standards/import/provider_import_utils'
require_relative 'health-data-standards/import/hdata/metadata_importer'

require_relative 'health-data-standards/models/thing_with_codes'
require_relative 'health-data-standards/models/result_value'
require_relative 'health-data-standards/models/coded_result_value'
require_relative 'health-data-standards/models/physical_quantity_result_value'
require_relative 'health-data-standards/models/cda_identifier'
require_relative 'health-data-standards/models/reference'
require_relative 'health-data-standards/models/entry'
require_relative 'health-data-standards/models/allergy'
require_relative 'health-data-standards/models/encounter'
require_relative 'health-data-standards/models/condition'
require_relative 'health-data-standards/models/communication'
require_relative 'health-data-standards/models/immunization'
require_relative 'health-data-standards/models/fulfillment_history'
require_relative 'health-data-standards/models/order_information'
require_relative 'health-data-standards/models/medication'
require_relative 'health-data-standards/models/procedure'
require_relative 'health-data-standards/models/lab_result'
require_relative 'health-data-standards/models/family_history'
require_relative 'health-data-standards/models/functional_status'
require_relative 'health-data-standards/models/medical_equipment'
require_relative 'health-data-standards/models/record'
require_relative 'health-data-standards/models/personable'
require_relative 'health-data-standards/models/provider'
require_relative 'health-data-standards/models/provider_performance'
require_relative 'health-data-standards/models/support'
require_relative 'health-data-standards/models/vital_sign'
require_relative 'health-data-standards/models/insurance_provider'
require_relative 'health-data-standards/models/guarantor'
require_relative 'health-data-standards/models/person'
require_relative 'health-data-standards/models/organization'
require_relative 'health-data-standards/models/address'
require_relative 'health-data-standards/models/telecom'
require_relative 'health-data-standards/models/transfer'
require_relative 'health-data-standards/models/svs/value_set'
require_relative 'health-data-standards/models/svs/concept'
require_relative 'health-data-standards/models/facility'
require_relative 'health-data-standards/models/metadata/base'
require_relative 'health-data-standards/models/metadata/author'
require_relative 'health-data-standards/models/metadata/change_info'
require_relative 'health-data-standards/models/metadata/link_info'
require_relative 'health-data-standards/models/metadata/pedigree'
require_relative 'health-data-standards/models/provider_preference'
require_relative 'health-data-standards/models/patient_preference'
require_relative 'health-data-standards/models/care_goal'
require_relative 'health-data-standards/models/encounter_principal_diagnosis'

require_relative 'health-data-standards/models/qrda/id'
require_relative 'health-data-standards/models/qrda/device'
require_relative 'health-data-standards/models/qrda/person'
require_relative 'health-data-standards/models/qrda/organization'
require_relative 'health-data-standards/models/qrda/custodian'
require_relative 'health-data-standards/models/qrda/legal_authenticator'
require_relative 'health-data-standards/models/qrda/author'
require_relative 'health-data-standards/models/qrda/header'

require_relative 'health-data-standards/models/cqm/aggregate_objects'
require_relative 'health-data-standards/models/cqm/query_cache'
require_relative 'health-data-standards/models/cqm/bundle'
require_relative 'health-data-standards/models/cqm/prefilter'
require_relative 'health-data-standards/models/cqm/measure'
require_relative 'health-data-standards/models/cqm/patient_cache'

require_relative 'health-data-standards/export/qrda/entry_template_resolver'
require_relative 'health-data-standards/export/helper/scooped_view_helper'
require_relative 'health-data-standards/export/helper/html_view_helper'
require_relative 'health-data-standards/export/html'
require_relative 'health-data-standards/export/helper/cat1_view_helper'
require_relative 'health-data-standards/export/cat_1'
require_relative 'health-data-standards/export/cat_1_r2'
require_relative 'health-data-standards/export/cat_3'

require_relative 'health-data-standards/import/cda/narrative_reference_handler'
require_relative 'health-data-standards/import/cda/entry_finder'
require_relative 'health-data-standards/import/cda/locatable_import_utils'
require_relative 'health-data-standards/import/cda/section_importer'
require_relative 'health-data-standards/import/cda/provider_importer'
require_relative 'health-data-standards/import/cda/organization_importer'
require_relative 'health-data-standards/import/cda/allergy_importer'
require_relative 'health-data-standards/import/cda/condition_importer'
require_relative 'health-data-standards/import/cda/encounter_importer'
require_relative 'health-data-standards/import/cda/medical_equipment_importer'
require_relative 'health-data-standards/import/cda/medication_importer'
require_relative 'health-data-standards/import/cda/procedure_importer'
require_relative 'health-data-standards/import/cda/result_importer'
require_relative 'health-data-standards/import/cda/vital_sign_importer'
require_relative 'health-data-standards/import/cda/communication_importer'

require_relative 'health-data-standards/import/c32/condition_importer'
require_relative 'health-data-standards/import/c32/immunization_importer'
require_relative 'health-data-standards/import/c32/patient_importer'
require_relative 'health-data-standards/import/c32/insurance_provider_importer'
require_relative 'health-data-standards/import/c32/care_goal_importer'

require_relative 'health-data-standards/import/ccda/patient_importer'
require_relative 'health-data-standards/import/ccda/allergy_importer'
require_relative 'health-data-standards/import/ccda/condition_importer'
require_relative 'health-data-standards/import/ccda/encounter_importer'
require_relative 'health-data-standards/import/ccda/immunization_importer'
require_relative 'health-data-standards/import/ccda/procedure_importer'
require_relative 'health-data-standards/import/ccda/result_importer'
require_relative 'health-data-standards/import/ccda/vital_sign_importer'
require_relative 'health-data-standards/import/ccda/medication_importer'
require_relative 'health-data-standards/import/ccda/care_goal_importer'
require_relative 'health-data-standards/import/ccda/medical_equipment_importer'
require_relative 'health-data-standards/import/ccda/insurance_provider_importer'

require_relative 'health-data-standards/import/cat1/device_order_importer'
require_relative 'health-data-standards/import/cat1/gestational_age_importer'
require_relative 'health-data-standards/import/cat1/procedure_intolerance_importer'
require_relative 'health-data-standards/import/cat1/procedure_performed_importer'
require_relative 'health-data-standards/import/cat1/procedure_order_importer'
require_relative 'health-data-standards/import/cat1/diagnosis_active_importer'
require_relative 'health-data-standards/import/cat1/diagnosis_importer'
require_relative 'health-data-standards/import/cat1/diagnosis_inactive_importer'
require_relative 'health-data-standards/import/cat1/patient_importer'
require_relative 'health-data-standards/import/cat1/lab_order_importer'
require_relative 'health-data-standards/import/cat1/immunization_administered_importer'
require_relative 'health-data-standards/import/cat1/medication_active_importer'
require_relative 'health-data-standards/import/cat1/medication_dispensed_importer'
require_relative 'health-data-standards/import/cat1/medication_dispensed_act_importer'
require_relative 'health-data-standards/import/cat1/encounter_order_importer'
require_relative 'health-data-standards/import/cat1/encounter_order_act_importer'
require_relative 'health-data-standards/import/cat1/encounter_performed_importer'
require_relative 'health-data-standards/import/cat1/encounter_performed_act_importer'
require_relative 'health-data-standards/import/cat1/diagnostic_study_order_importer'
require_relative 'health-data-standards/import/cat1/tobacco_use_importer'
require_relative 'health-data-standards/import/cat1/entry_package'
require_relative 'health-data-standards/import/cat1/lab_result_importer'
require_relative 'health-data-standards/import/cat1/ecog_status_importer'
require_relative 'health-data-standards/import/cat1/symptom_active_importer'
require_relative 'health-data-standards/import/cat1/insurance_provider_importer'
require_relative 'health-data-standards/import/cat1/clinical_trial_participant_importer'
require_relative 'health-data-standards/import/cat1/transfer_from_importer.rb'
require_relative 'health-data-standards/import/cat1/transfer_to_importer.rb'
require_relative 'health-data-standards/import/cat1/transfer_from_act_importer.rb'
require_relative 'health-data-standards/import/cat1/transfer_to_act_importer.rb'

require_relative 'health-data-standards/import/bundle/importer'

require_relative 'health-data-standards/import/bulk_record_importer'

require_relative 'health-data-standards/validate/validators'

module HealthDataStandards
  class << self
    attr_accessor :logger
  end
end

if defined?(Rails)
  require_relative 'health-data-standards/railtie'
else
  HealthDataStandards.logger = Log4r::Logger.new("Health Data Standards")
  HealthDataStandards.logger.outputters = Log4r::Outputter.stdout
end
