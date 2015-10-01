module HealthDataStandards
  module CQM
    class Prefilter
      include Mongoid::Document
      # What field on the Record do we want to compare against
      field :record_field, type: String
      # greater than, less than, etc.
      field :comparison, type: String
      # Is it based on the effective_time, like 65yo during measure period
      field :effective_time_based, type: Boolean, default: false
      # If effective_time_based, what is the offset from effective_time in years
      field :effective_time_offset, type: Integer
      field :effective_time_quantity, type: String, default: "a"
      field :effective_time_compare , type: String, default: "SBS"
      # Comparison to a plain old value, like gender == 'F'
      field :desired_value

      field :negated, type: Boolean , default: false

      embedded_in :filterable, polymorphic: true

      def measure
        if filterable
          if filterable.kind_of? Measure 
            filterable
          else
            filterable.measure 
          end
        end
      end

      def build_query_hash(effective_time)
        filter_value = if self.effective_time_based
          et = Time.at(effective_time)
          case effective_time_compare
          when "SBS" 
            et = et.years_ago(1)
          end

          case effective_time_quantity
          when 'mo'
            et.months_ago(effective_time_offset).to_i
          when 'd' 
            et.days_ago(effective_time_offset).to_i
          when 'day' 
            et.days_ago(effective_time_offset).to_i
          when 'wk' 
            et.weeks_ago(effective_time_offset).to_i
          else
            et.years_ago(effective_time_offset).to_i
          end
          
        else
          self.desired_value
        end

        if self.comparison == '$eq'
          {self.record_field => desired_value}
        else
          {self.record_field => {self.comparison => filter_value}}
        end
      end
    end


    class AggregatePrefilter
      include Mongoid::Document
      field :prefilters, type: Array, default: []
      field :conjuntion, type: String
      embedded_in :filterable, polymorphic: true
      embeds_many :prefilters,  as: :filterable

      
      def measure
        if filterable
          if filterable.kind_of? Measure 
            filterable
          else
            filterable.measure 
          end
        end
      end
      
      def build_query_hash(effective_time)
        prefs = prefilters.compact.collect {|pf| pf.build_query_hash(effective_time)}
        prefs.compact!
        prefs.length ==0 ? nil : {"$#{conjuntion}" => prefs}
      end
    
    end

    class CodedPrefilter
      include Mongoid::Document
      field :record_field, type: String 
      field :code_list_id, type: String
      embedded_in :filterable, polymorphic: true
      
      def measure
        if filterable
          if filterable.kind_of? Measure 
            filterable
          else
            filterable.measure 
          end
        end
      end

      def build_query_hash(effective_time)
        possibles = []
        vs_filter = {oid: code_list_id}
        if measure && measure["bundle_id"]
          vs_filter["bundle_id"] = measure["bundle_id"]
        end
        code_list_map = HealthDataStandards::SVS::ValueSet.where(vs_filter).first.code_set_map
        code_list_map.each do |csm|
         possibles <<  {"#{record_field}.codes.#{csm['set']}" => {"$in" => csm['values']}}
        end
        {"$or" => possibles}
      end
    end
  end
end
