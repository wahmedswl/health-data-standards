require 'ffi'

module HealthDataStandards
  module Import
    module Cat1
      class ExternalCat1Importer
        include Singleton
        extend FFI::Library
        ffi_lib File.expand_path("./libpatient.so", File.dirname(__FILE__))
        attach_function :read_patient, [:string], :string

        def parse_with_ffi(path)
          patient_json_string = read_patient(path)
          patient = Record.new(JSON.parse(patient_json_string))
          patient
        end
      end
    end
  end
end
