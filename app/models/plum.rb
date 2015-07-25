class Plum < ActiveRecord::Base
  belongs_to :user
  attr_accessible :icp_path, :mns_path, :third_party_path, :user_id
end
