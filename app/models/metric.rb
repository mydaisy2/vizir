class Metric < ActiveRecord::Base
  extend StiHelpers

  attr_accessible :name, :type, :details
  attr_custom :title, :unit
  attr_accessor :instance_details

  serialize :details, JSON

  validates :name,
    :uniqueness => true,
    :presence => true

  validates :details,
    :presence => true

  # TODO: use descendants/subclasses
  validates :type,
    :inclusion => {:in => ["CollectdMetric"]}

  has_many :instances
  has_many :entities, :through => :instances

  after_initialize do |metric|
    metric.dsl_override
  end

  def ==(metric)
    self.name == metric.name
  end

  protected

  def dsl_override
    if metric_defs = Vizir::DSL.data[:metric][self.class.to_s]
      select_proc = nil
      matches = {}

      if self.new_record?
        unless self.details.nil? or @check_fields.nil?
          select_proc = Proc.new do |dsl|
            matched = true
            @check_fields.each do |field|
              if dsl[field].is_a? Regexp
                matched = false unless (dsl_match = dsl[field].match(self.send(field)))
                matches.merge!(dsl_match.to_hash(field.to_s)) if dsl_match
              else
                matched = false unless (dsl[field] == self.send(field))
              end
            end
            matched
          end
        end
      else
        select_proc = Proc.new {|dsl| dsl[:name] == self.name}
      end

      metric_def = metric_defs.select {|m| select_proc.call(m)}
      self.assign_attributes(metric_def.first, :without_protection => true) unless metric_def.empty?
      self.instance_details = matches unless matches.empty?
    end
  end
end
