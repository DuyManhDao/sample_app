module RelationshipsHelper
  def find_active_relationship user, followed_user
    user.active_relationships.find_by(followed_id: followed_user.id)
  end
end
