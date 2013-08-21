class FamilyHistory < Entry

 include Mongoid::Document


 field :gender, type: String
 field :subject, type: Hash
 field :birthtime, type: Integer
 field :age, type: Hash
 field :cause_of_death, type: Boolean, default: false

end
