module HealthDataStandards
  module Import
    module CCDA
      class ResultImporter < CDA::ResultImporter
        def initialize
          super(CDA::EntryFinder.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.2' or cda:templateId/@root='1.3.6.1.4.1.19376.1.5.3.1.4.13']"))
        end
      end
    end
  end
end