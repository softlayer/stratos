module FormHelper
  def error_tag(model, field)
    errors = model.errors[field]
    if errors.any?
      render("shared/form_helper/error_tag", errors: errors)
    else
      nil
    end
  end
end
