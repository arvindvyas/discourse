class Admin::GroupsController < Admin::AdminController
  def index
    groups = Group.order(:name).to_a
    render_serialized(groups, BasicGroupSerializer)
  end

  def refresh_automatic_groups
    Group.refresh_automatic_groups!
    render json: success_json
  end

  def update
    group = Group.find(params[:id].to_i)

    if group.automatic
      # we can only change the alias level on automatic groups
      group.alias_level = params[:group][:alias_level]
    else
      group.usernames = params[:group][:usernames]
      group.alias_level = params[:group][:alias_level]
      group.name = params[:group][:name] if params[:group][:name]
    end

    if group.save
      render json: success_json
    else
      render_json_error group
    end
  end

  def create
    group = Group.new
    group.name = params[:group][:name].strip
    group.usernames = params[:group][:usernames] if params[:group][:usernames]
    if group.save
      render_serialized(group, BasicGroupSerializer)
    else
      render_json_error group
    end
  end

  def destroy
    group = Group.find(params[:id].to_i)
    if group.automatic
      can_not_modify_automatic
    else
      group.destroy
      render json: success_json
    end
  end

  protected

  def can_not_modify_automatic
    render json: {errors: I18n.t('groups.errors.can_not_modify_automatic')}, status: 422
  end
end
