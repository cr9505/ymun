df = DelegationField.where(slug: 'delegation_size').first
if df
  df.class_name = 'DelegationSize'
  df.save

  Delegation.find_each do |d|
    dfvs = d.get_fields(df)
    d.delegation_size = dfvs.first.andand.value
    dfvs.destroy_all
    d.save
  end
else
  puts "[WARN] No DelegationField with slug=delegation_size found."
end


