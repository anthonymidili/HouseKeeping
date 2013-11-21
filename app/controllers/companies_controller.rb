class CompaniesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin
  before_filter :redirect_if_company?, only: [ :new, :create ]

  def show
    @company = current_user.company
  end

  def new
    @company = current_user.build_company
  end

  def create
    @company = current_user.build_company(params[:company])

    if @company.save && current_user.save
      redirect_to @company, notice: 'Company was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @company = current_user.company
  end

  def update
    @company = current_user.company

      if @company.update_attributes(params[:company])
        redirect_to @company, notice: 'Company was successfully updated.'
      else
        render action: 'edit'
      end
  end

  def destroy
    @company = current_user.company
    @company.destroy

    redirect_to new_company_path
  end

private

  def redirect_if_company?
    if current_user.company
      @company = current_user.company
      redirect_to edit_company_path(@company)
    end
  end

  def require_admin
    redirect_to account_path(current_user.account) unless current_user.is_admin?
  end
end
