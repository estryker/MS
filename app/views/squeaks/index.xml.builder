xml.squeaks do
  @squeaks.each do |s|
     xml << render(:partial => 'squeaks/squeak')
  end
end