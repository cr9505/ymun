class CollectionInput < SimpleForm::Inputs::CollectionInput
  def input_html_classes
    super.push('chosen')
  end
end