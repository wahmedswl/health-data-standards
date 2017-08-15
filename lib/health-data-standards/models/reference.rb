class Reference
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  embedded_in :entry
  field :type, type: String # TODO(BONNIE-965): use for code_system when generating the fake code in cql_qdm_patientapi?
  field :referenced_type, type: String
  field :referenced_id # TODO(BONNIE-965) Use for code in cql_qdm_patientapi

  def resolve_reference
    entry.record.entries.find do |e|
      e.class.to_s == referenced_type &&
      e.identifier.to_s == referenced_id.to_s
    end
  end

  def resolve_referenced_id
    resolved_reference = entry.record.entries.find do |e|
      e.class.to_s == referenced_type &&
      e.identifier == referenced_id
    end
    self.referenced_id = resolved_reference.id.to_s
  end
end
