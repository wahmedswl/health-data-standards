require 'test_helper'

class FamilyHistoryImporterTest < MiniTest::Unit::TestCase
  def test_family_history_importing
    doc = Nokogiri::XML(File.new('test/fixtures/cat1_fragments/family_history_fragment.xml'))
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    nrh = HealthDataStandards::Import::CDA::NarrativeReferenceHandler.new
    nrh.build_id_map(doc)
    lo = HealthDataStandards::Import::Cat1::EntryPackage.new(HealthDataStandards::Import::Cat1::FamilyHistoryImporter.new, '2.16.840.1.113883.3.560.1.50')
    lab_orders = lo.package_entries(doc, nrh)
    lab_order = lab_orders[0]
    # expected_start = HealthDataStandards::Util::HL7Helper.timestamp_to_integer('19910519162436')
    # assert lab_order.codes['SNOMED-CT'].include?('8879006')
    # assert_equal expected_start, lab_order.time
  end
end