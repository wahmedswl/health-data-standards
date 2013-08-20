class FamilyHistory < Entry

 include Mongoid::Document

 field :gender, type: String
 field :subject, type: Hash
 field :birthtime, type: Integer
 field :age, type: Hash
 
end
