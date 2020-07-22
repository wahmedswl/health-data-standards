module HealthDataStandards
  module Import
    module C32
      class InsuranceProviderImporter < CDA::SectionImporter

        def initialize(entry_finder=CDA::EntryFinder.new("//cda:act[cda:templateId/@root='2.16.840.1.113883.10.20.1.26']"))
          super(entry_finder)
          @check_for_usable = false # needs to be this way becase InsuranceProvider does not respond
                                    # to usable?
        end

        def create_entry(payer_element, nrh = CDA::NarrativeReferenceHandler.new)
          ip = InsuranceProvider.new
          extract_codes(payer_element, ip)
          type = extract_code(payer_element, "./cda:code")
          ip.type = type['code'] if type
          ip.payer = import_organization(payer_element.at_xpath("./cda:performer/cda:assignedEntity[cda:code[@code='PAYOR']]"))
          ip.guarantors = extract_guarantors(payer_element.xpath("./cda:performer[cda:assignedEntity[cda:code[@code='GUAR']]]"))
          ip.subscriber = import_person(payer_element.at_xpath("./cda:participant[@typeCode='HLD']/cda:participantRole"))
          member_info_element = payer_element.at_xpath("cda:participant[@typeCode='COV']")
          extract_dates(member_info_element, ip, "time")
          covered_party_element = payer_element.at_xpath("./cda:entryRelationship[@typeCode='REFR']/cda:act[@classCode='ACT' and @moodCode='DEF']")
          ip[:covered_party_id] = covered_party_element.at_xpath("./cda:id")['extension'] if covered_party_element.at_xpath("./cda:id")
          name = covered_party_element.at_xpath("./cda:text")
          ip.name = name.try(:text)
          if member_info_element
            patient_element = member_info_element.at_xpath("./cda:participantRole[@classCode='PAT']")
            if patient_element
              ip.member_id = patient_element.at_xpath("./cda:id")
              ip.relationship = extract_code(patient_element, "./cda:code")
            else
              patient_element = member_info_element.at_xpath("./cda:participantRole")
              if patient_element
                ip.member_id = patient_element.at_xpath("./cda:id")['extension'] if patient_element.at_xpath("./cda:id")
                ip.relationship = extract_code(patient_element, "./cda:code")
              end
            end
          end
          ip.financial_responsibility_type = extract_code(payer_element, "./cda:performer/cda:assignedEntity/cda:code")
          ip
        end

        def extract_guarantors(guarantor_elements)
          guarantor_elements.map do |guarantor_element|
            guarantor = Guarantor.new
            extract_dates(guarantor_element, guarantor, "time")
            guarantor_entity = guarantor_element.at_xpath("./cda:assignedEntity")
            guarantor.person = import_person(guarantor_entity.at_xpath("./cda:assignedPerson"))
            guarantor.organization = import_organization(guarantor_entity.at_xpath("./cda:representedOrganization"))
            guarantor
          end
        end

      end
    end
  end

end