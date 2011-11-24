xml.squeeks do
  @squeeks.each do |s|
     xml << render(:partial => 'squeeks/squeek')
  end
end