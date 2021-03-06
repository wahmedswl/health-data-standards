class Procedure < Entry

  field :incisionTime,        type: Integer,      as: :incision_time 
  field :ordinality,          type: Hash
  field :source,              type: Hash
  # anatomical approach deprecated as of QDM 5.4
  field :anatomical_approach, type: Hash
  field :anatomical_target,   type: Hash
  field :anatomical_location, type: Hash
  # method deprecated for "Procedure, Recommended" and "Procedure, Order" in QDM 5.4. Remains for "Procedure, Performed".
  # method deprecated for "Diagnostic Study, Recommended" and "Diagnostic Study, Order" in QDM 5.4. Remains for "Diagnostic Study, Performed".
  # method deprecated for "Physical Exam, Recommended" and "Physical Exam, Order" in QDM 5.4. Remains for "Physical Exam, Performed".
  field :method,              type: Hash
  field :reaction,            type: Hash 
  # The resulting status of a procedure as defined in the QDM documentation. This is different
  # than the status associated with the `Entry` object, which relates to the data criteria
  # status as defined in health-data-standards/lib/hqmf-model/data_criteria.json.
  field :qdm_status,          type: Hash

  field :radiation_dose,      type: Hash 
  field :radiation_duration,  type: Hash

  # QDM 5.0 addition to Diagnostic Study, Performed
  field :result_date_time,    type: Integer
  # Component attribute is for Diagnostic, Performed which is classified as a procedure
  field :components,          type: Hash
 
  field :facility, type: Hash

  belongs_to :performer, class_name: "Provider"

  def shift_dates(date_diff)
  	super
  	self.incisionTime = self.incisionTime.nil? ? nil : self.incisionTime + date_diff
  end
end
