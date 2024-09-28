class AddEmailTemplateIdToEmailServices < ActiveRecord::Migration[7.0]
  def change
    add_column :email_services, :email_template_id, :integer
  end
end
