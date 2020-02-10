module HealthDataStandards
  module Import
    module CCDA
      class VitalSignImporter < CDA::ResultImporter
        def initialize
          super(CDA::EntryFinder.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.27' or cda:templateId/@root='2.16.840.1.113883.3.88.11.83.14']"))
        end
      end
    end
  end
end