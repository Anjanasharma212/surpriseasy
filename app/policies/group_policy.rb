class GroupPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.for_user(user)
    end
  end

  def index?
    true
  end

  def show?
    participant?
  end

  def create?
    user.present?
  end

  def update?
    owner? || participant?
  end

  def destroy?
    user.present? && (record.user_id == user.id || record.participants.exists?(user_id: user.id))
  end

  def draw_names?
    owner? && record.participants.count > 1
  end

  def manage_participants?
    owner?
  end

  private

  def group_ready_for_draw?
    record.participants.count > 1 && 
    record.participants.all? { |p| p.wishlists.any? }
  end
end 
