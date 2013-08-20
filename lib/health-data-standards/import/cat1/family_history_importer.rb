module HealthDataStandards
  module Import
    module Cat1

      class FamilyHistoryImporter < CDA::SectionImporter
       
        def initialize(entry_finder = CDA::EntryFinder.new("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.46']"))
          @entry_finder = entry_finder
          @code_xpath = "./cda:code"
          @id_xpath = "./cda:id"
          @entry_class = FamilyHistory
          @value_xpath = "./cda:value"
          @age_xpath= "./cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.31']"
          @cause_of_death_xpath = "./cda:entryRelationship[cda:templateId/@root='2.16.840.1.113883.10.20.22.4.47']"
          @subject_xpath = "../../cda:subject/cda:realtedSubject"
          @gender_xpath = "./cda:subject/cda:administrativeGenderCode"
          @btime_xpath = "./cda:subject/cda:birthtime"
        end

        def create_entry(element, nrh = CDA::NarrativeReferenceHandler.new)
           entry = super(element,nrh)
           extract_subject(entry,element)
           extract_age(entry, element)
           extract_cause_of_death(entry,element)
           entry
        end

        def extract_subject(parent_entry, element)
            subject = element.at_xpath(@subject_xpath)
            if subject
              code_element = subject.at_xpath("./cda:code")
              if code_element
                parent_entry.subject = {"code" => code_element["code"], 
                                        "code_system" => HealthDataStandards::Util::CodeSystemHelper.code_system_for_oid(code_element["codeSystem"])}

              end
              extract_gender(parent_entry, element)
              extract_birth_time(parent_entry,element)
            end
        end

        def extract_gender(parent_entry, element)
          gender = element.at_xpath(@gender_xpath)
          if gender
            parent_entry.gender = gender["code"]
          end
        end

        def extract_birth_time(parent_entry, element)
          btime = element.at_xpath(@btime_xpath)
          if btime
            parent_entry.birthtime = btime["value"]
          end
        end

        def extract_age(parent_entry, element)
          age = element.at_xpath(@age_xpath)
          if age
            parent_entry.age = age["value"]
          end
        end

        def extract_cause_of_death(parent_entry, element)
          cofd = element.at_xpath(@cause_of_death_xpath)
          if cofd
            parent_entry.cause_of_death = true
          end    
        end

      end
    end
  end
end