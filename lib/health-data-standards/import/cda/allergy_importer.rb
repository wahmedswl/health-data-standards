module HealthDataStandards
  module Import
    module CDA
      class AllergyImporter < SectionImporter
    
        def initialize(entry_finder=EntryFinder.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.18']"))
          @entry_finder = entry_finder
          @code_xpath = "./cda:participant/cda:participantRole/cda:playingEntity/cda:code"
          @description_xpath = "./cda:code/cda:originalText/cda:reference[@value] | ./cda:text/cda:reference[@value]"
          @type_xpath = "./cda:code"
          @reaction_xpath = "./cda:entryRelationship[@typeCode='MFST']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.54']/cda:value"
          @severity_xpath = "./cda:entryRelationship[@typeCode='SUBJ']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.55']/cda:value"
          @status_xpath   = "./cda:entryRelationship[@typeCode='REFR']/cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.1.39']/cda:value"
          @entry_class = Allergy
        end
    
        def create_entry(entry_element, nrh = NarrativeReferenceHandler.new)
          allergy = super
          extract_reason_or_negation(entry_element, allergy)
          allergy.type = extract_code(entry_element, @type_xpath)
          allergy.reaction = extract_code(entry_element, @reaction_xpath)
          allergy.severity = extract_code(entry_element, @severity_xpath)

          description_reference = entry_element.at_xpath(@reaction_xpath + "/cda:originalText/cda:reference/@value").try("text")
          if !description_reference.blank?
            allergy.reaction[:description] = nrh.lookup_tag(description_reference)
          end
          if !allergy.description? && !entry_element.search("playingEntity/code").blank?
            allergy.description = entry_element.search("playingEntity/code").attr("displayName").try("text")
          end
          if !allergy.type? || allergy.type["code"] == "ASSERTION"
            allergy.type = extract_code(entry_element, "./cda:value")
          end          
          if !allergy.start_time?
            extract_dates(entry_element.parent.parent, allergy)
          end

          allergy
        end
        
      end
    end
  end
end