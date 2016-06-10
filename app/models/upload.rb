class Upload < ActiveRecord::Base

  attr_accessible :job_id, :upload
  has_attached_file :upload
  do_not_validate_attachment_file_type :upload

  belongs_to :job
  has_many :data_associations

  def name= n
    self.upload_file_name = n
  end

  def name
    self.upload_file_name
  end

  def url
    self.upload.url
  end

  def path
    self.upload.path
  end

  def export
    attributes
  end

end
