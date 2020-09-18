class Api::V2::UsersController < ApplicationController
  include ApiHelper

  def index
    # TODO: ADD PERMISSIONS

    res = User.find_by_sql "select * from users"

    # HACK TO PREVENT AS_JSON OVERRIDE (DEF AS_JSON IN USER.RB)
    # TODO: REMOVE ONCE DEF AS_JSON IS FIXED
    result = []
    res.each do |r|
      result << { :id => r.id, :name => r.name, :login => r.login }
    end

    render json: api_ok(result) and return
  end

  def user
    # TODO: ADD PERMISSIONS

    # GET USER
    id = params[:id].to_i
    user = User.find(id) rescue nil
    render json: api_error( { "user_id" => ["invalid user"] } ) and return if !user

    # HACK TO PREVENT AS_JSON OVERRIDE (WHICH IS REALLY INEFFICENT BY THE WAY)
    result = []
    result << { :id => user.id, :name => user.name, :login => user.login }

    render json: api_ok(result)
  end

  def jobs
    # TODO: ADD PERMISSIONS

    # GET USER
    id = params[:id].to_i
    user = User.find(id) rescue nil
    render json: api_error( { "user_id" => ["invalid user"] } ) and return if !user

    render json: api_ok(user.jobs)
  end

  def assigned_jobs
    # TODO: ADD PERMISSIONS

    # GET USER
    id = params[:id].to_i
    user = User.find(id) rescue nil
    render json: api_error( { "user_id" => ["invalid user"] } ) and return if !user

    # GET RESULTS
    # TODO: FILTER FOR "OPEN" JOBS
    res = user.jobs_assigned_to

    # CUSTOMIZE RESULTS
    result = []
    res.each do |r|
      result << {
        :job_id       => r.job_id,
        :assigned_by  => r.assigned_by,
        :by_name      => r.by_name,
        :by_login     => r.by_login,
        :assigned_to  => r.assigned_to,
        :to_name      => r.to_name,
        :to_login     => r.to_login,
        :created_at   => r.created_at
      }
    end

    render json: api_ok(result)
  end

end
