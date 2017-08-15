class CareGoal < Entry
  field :relatedTo,     type: Hash, as: :related_to # TODO(BONNIE-965): remove as this will be Entry.references
  field :targetOutcome, type: Hash, as: :target_outcome
end
