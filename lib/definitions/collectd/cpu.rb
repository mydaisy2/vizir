cpu_metrics = %w(system interrupt softirq wait steal user nice idle)
cpu_metrics.each do |type|
  metric "cpu_#{type}" do
    rrd %r{cpu-(?<cpu_id>\d+)/cpu-#{type}.rrd}
    ds "value"
    title "CPU $cpu_id #{type.capitalize}"
  end
end

graph "cpu" do
  metrics cpu_metrics.map {|m| "cpu_#{m}"}
  layout :area
  title "CPU $cpu_id"
  scope "cpu_id"
end