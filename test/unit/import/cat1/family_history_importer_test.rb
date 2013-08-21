require 'test_helper'

class FamilyHistoryImporterTest < MiniTest::Unit::TestCase
  def test_family_history_importing
    doc = Nokogiri::XML(File.new('test/fixtures/cat1_fragments/family_history_fragment.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    nrh = HealthDataStandards::Import::CDA::NarrativeReferenceHandler.new
    nrh.build_id_map(doc)
    fh = HealthDataStandards::Import::Cat1::EntryPackage.new(HealthDataStandards::Import::Cat1::FamilyHistoryImporter.new, '2.16.840.1.113883.3.560.1.50')
    histories = fh.package_entries(doc, nrh)
    assert_equal 2, histories.length
    history = histories[0]
    assert history.subject , "History should contain a subject"
    assert_equal "FTH", history.subject["code"], "History subject code should be FTH"
    assert_equal "HL7RoleCode", history.subject["code_system"], "History subject codeSystem should be HL7RoleCode"
    assert_equal "M", history.gender, "History Gender should be M"
    assert_equal nil, history.age , "History age should be nil"
    assert_equal 1912, history.birthtime, "History Birth time should be 1912"
    assert_equal false, history.cause_of_death, "History cause of death should be false"

    history = histories[1]
    expected_age = {"value" => "77", "unit" => "years"} 
    assert history.subject , "History should contain a subject"
    assert_equal "FTH", history.subject["code"], "History subject code should be FTH"
    assert_equal "HL7RoleCode", history.subject["code_system"], "History subject codeSystem should be HL7RoleCode"
    assert_equal "M", history.gender, "History Gender should be M"
    assert_equal expected_age , history.age , "History age should be nil"
    assert_equal 1912, history.birthtime, "History Birth time should be 1912"
    assert_equal true, history.cause_of_death, "History cause of death should be false"

  end
end