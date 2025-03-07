class WishlistPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?    
    owner? || drawn_for_user? || same_group_participant?
  end

  def update?
    owner?
  end

  def create?
    owner?
  end

  def destroy?
    owner?
  end

  private

  def owner?
    return false unless user && record.participant
    user.id == record.participant.user_id
  end

  def drawn_for_user?
    return false unless user && record.participant&.group
    participant = record.participant
    group = participant.group
    drawer = group.participants.find_by(user_id: user.id)
    drawer&.drawn_name_id == participant.id
  end

  def same_group_participant?
    return false unless user && record.participant&.group
    group = record.participant.group
    group.participants.exists?(user_id: user.id)
  end
end 
